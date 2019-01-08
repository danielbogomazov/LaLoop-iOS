//
//  BrowseViewController.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit
import CoreData

class BrowseViewController: UIViewController {
    
    private var recordingsTableView: UITableView!
    private var recordings: [Recording] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Util.Color.backgroundColor
        
        setupTableView()

        getData(completionHandler: { success in
            DispatchQueue.main.async {
                if success {
                    self.reloadTableView()
                } else {
                    // TODO - Load from cache?
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func getData(completionHandler: @escaping (Bool) -> ()) {
        
        let url = URL(string: serverIP)! // Left out of repo on purpose -- will add in the future
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .ephemeral)
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error in HTTP request: \(error!)")
                completionHandler(false)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Error in HTTP response: \(response!)")
                completionHandler(false)
                return
            }
            do {
                let jsonData = try JSONDecoder().decode(RecordingData.self, from: data)
                for var recording in jsonData.recordings {
                    DispatchQueue.main.async {
                        recording.save()
                    }
                }
                completionHandler(true)
            } catch {
                print("ERROR in getData() - Couldn't decode JSON from server")
                print("-- \(error)\n")
                completionHandler(false)
            }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        let frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        recordingsTableView = UITableView(frame: frame, style: .grouped)
        recordingsTableView.backgroundColor = Util.Color.backgroundColor
        recordingsTableView.estimatedRowHeight = 100
        recordingsTableView.rowHeight = 100
        recordingsTableView.delegate = self
        recordingsTableView.dataSource = self
        view.addSubview(recordingsTableView)
    }
    
    func populateRecordings() {
        let request: NSFetchRequest<Recording> = Recording.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "release_date", ascending: true)]
        request.predicate = NSPredicate(format: "release_date >= %@ OR release_date == nil", Date() as NSDate)
        do {
            recordings = try AppDelegate.viewContext.fetch(request)
            recordings.sort {
                guard let first = $0.release_date, let second = $1.release_date else {
                    return ($0.release_date != nil && $1.release_date == nil) }
                return first < second
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func reloadTableView() {
        populateRecordings()
        recordingsTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BrowseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return RecordingTableViewCell(recording: recordings[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
        guard let artistID = cell.recording.artists.first?.id else { return [] }
        
        if var followedArtists = UserDefaults.standard.array(forKey: "Followed Artists") as? [String] {
            if followedArtists.contains(artistID), let index = followedArtists.firstIndex(of: artistID) {
                return [UITableViewRowAction(style: .default, title: "Unfollow") { (_, _) in
                    followedArtists.remove(at: index)
                    UserDefaults.standard.set(followedArtists, forKey: "Followed Artists")
                    LocalNotif.removeRecording(id: artistID)
                    cell.updateButtonImage()
                }]
            } else {
                return [UITableViewRowAction(style: .default, title: "Follow") { (_, _) in
                    followedArtists.append(artistID)
                    UserDefaults.standard.set(followedArtists, forKey: "Followed Artists")
                    LocalNotif.createNewRecording(recording: cell.recording, completionHandler: { (success, error) in
                        if let e = error {
                            print(e.localizedDescription)
                        }
                        if !success {
                            // TODO
                        }
                        cell.updateButtonImage()
                    })
                }]
            }
        } else {
            return [UITableViewRowAction(style: .default, title: "Follow") { (_, _) in
                UserDefaults.standard.set([artistID], forKey: "Followed Artists")
                LocalNotif.createNewRecording(recording: cell.recording, completionHandler: { (success, error) in
                    if let e = error {
                        print(e.localizedDescription)
                    }
                    if !success {
                        // TODO
                    }
                    cell.updateButtonImage()
                })
            }]
        }
    }
}

class RecordingTableViewCell: UITableViewCell {
    private let followingButton = UIButton()
    private let dateLabel = UILabel()
    private let recordingLabel = UILabel()
    private let artistLabel = UILabel()
    private var recordingObj: Recording!
    
    private let margin: CGFloat = 8.0
    private let labelMargin: CGFloat = 2.0

    var releaseDate: String {
        get { return dateLabel.text! }
    }
    var recordingName: String {
        get { return recordingLabel.text! }
    }
    var artistName: String {
        get { return artistLabel.text! }
    }
    var recording: Recording {
        get { return recordingObj }
    }
    
    init(recording: Recording) {
        super.init(style: .default, reuseIdentifier: "recordingTableViewCell")

        recordingObj = recording

        backgroundColor = UIColor.clear

        let margin: CGFloat = 20
        let imageSize: CGFloat = 60.0
        
        followingButton.frame = CGRect(x: margin, y: margin, width: margin, height: margin)
        followingButton.contentMode = .scaleAspectFill
        followingButton.clipsToBounds = true
        updateButtonImage()

        let labelX = followingButton.frame.maxX + margin
        let labelWidth = contentView.frame.width - labelX
        artistLabel.frame = CGRect(x: labelX, y: followingButton.frame.origin.y, width: labelWidth, height: imageSize * 0.5)
        recordingLabel.frame = CGRect(x: labelX, y: artistLabel.frame.maxY, width: labelWidth, height: imageSize * 0.5 * 0.60)
        dateLabel.frame = CGRect(x: labelX, y: recordingLabel.frame.maxY, width: labelWidth, height: imageSize * 0.5 * 0.40)
        
        setupLabel(artistLabel, fontWeight: .black, textColor: UIColor.yellow)
        setupLabel(recordingLabel, fontWeight: .heavy)
        setupLabel(dateLabel, fontWeight: .regular)

        addSubview(followingButton)
        addSubview(dateLabel)
        addSubview(recordingLabel)
        addSubview(artistLabel)
        
        recordingLabel.text = recording.name
        dateLabel.text = "TBA"
        
        if let date = recording.release_date {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, YYYY"
            dateLabel.text = formatter.string(from: date)

            guard let dateString = dateLabel.text else { return }
            
            if let year = Int(dateString.suffix(4)), let currentYear = Int(formatter.string(from: Date()).suffix(4)) {
                if year >= currentYear  + 1999 {
                    let startIndex = dateString.index(dateString.endIndex, offsetBy: -8)
                    let range = startIndex..<dateString.endIndex
                    dateLabel.text?.replaceSubrange(range, with: "\(year - 1999)")
                }
            }
        }
        for (index, artist) in recording.artists.enumerated() {
            artistLabel.text = index > 0 ? "\(artistLabel.text!) & \(artist.name!)" : artist.name
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel(_ label: UILabel, fontWeight: UIFont.Weight, textColor: UIColor = UIColor.white) {
        label.font = UIFont.monospacedDigitSystemFont(ofSize: label.bounds.height, weight: fontWeight)
        label.textColor = textColor
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
    }
    
    func updateButtonImage() {
        DispatchQueue.main.async {
            if let artistID = self.recording.artists.first?.id,
                let artists = UserDefaults.standard.array(forKey: "Followed Artists") as? [String],
                artists.contains(artistID) {
                self.followingButton.setImage(UIImage(named: "Followed"), for: .normal)
            } else {
                self.followingButton.setImage(UIImage(named: "NotFollowed"), for: .normal)
            }
        }
    }
}
