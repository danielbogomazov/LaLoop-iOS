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
    private lazy var refreshControl = UIRefreshControl()
    
    var followingViewController: FollowingViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Util.Color.backgroundColor
        
        setupTableView()

        getData(completionHandler: { success in
            DispatchQueue.main.async {
                if success {
                    self.populateRecordings()
                    self.reloadTableView()
                } else {
                    // TODO - Load from cache?
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getData(completionHandler: @escaping (Bool) -> ()) {
        
        guard let url = URL(string: Util.Constant.url) else { completionHandler(false); return }
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
    
    func setupTableView() {
        
        // Safe Area
        let y: CGFloat = navigationController?.navigationBar.frame.maxY ?? 0
        let height: CGFloat = view.frame.height - y - (tabBarController?.tabBar.frame.height ?? 0)
        
        let frame = CGRect(x: 0, y: y, width: view.bounds.width, height: height)

        recordingsTableView = UITableView(frame: frame, style: .grouped)
        recordingsTableView.backgroundColor = Util.Color.backgroundColor
        recordingsTableView.delegate = self
        recordingsTableView.dataSource = self
        view.addSubview(recordingsTableView)
        refreshControl.addTarget(self, action: #selector(ref(_:)), for: .valueChanged)
        recordingsTableView.refreshControl = refreshControl
    }
    
    @objc func ref(_ sender: UIRefreshControl) {
        getData(completionHandler: { success in
            DispatchQueue.main.async {
                if success {
                    self.reloadTableView()
                }
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    func populateRecordings() {
        let request: NSFetchRequest<Recording> = Recording.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "release_date", ascending: true)]
        request.predicate = NSPredicate(format: "release_date >= %@ OR release_date == nil", Date() as NSDate)
        do {
            AppDelegate.recordings = try AppDelegate.viewContext.fetch(request)
            AppDelegate.recordings.sort {
                guard let first = $0.release_date, let second = $1.release_date else {
                    return ($0.release_date != nil && $1.release_date == nil) }
                return first < second
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func reloadTableView() {
        DispatchQueue.main.async {
            self.recordingsTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BrowseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Util.Constant.cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.recordings.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "upcoming recordings"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return RecordingCell(recording: AppDelegate.recordings[indexPath.row])
    }
        
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) == nil {
            UserDefaults.standard.set([], forKey: Util.Constant.followedArtistsKey)
        }
        
        guard let followedArtists = UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) as? [String] else { return [] }
        let cell = tableView.cellForRow(at: indexPath) as! RecordingCell
        guard let artistID = cell.recording.artists.first?.id else { return [] }

        if followedArtists.contains(artistID) {
            let unfollow = UITableViewRowAction(style: .default, title: "Unfollow") { (_, _) in
                Util.unfollowArtist(id: artistID)
                cell.updateButtonImage()
            }
            unfollow.backgroundColor = Util.Color.secondaryDark
            return [unfollow]
        } else {
            let follow = UITableViewRowAction(style: .default, title: "Follow") { (_, _) in
                Util.followArtist(id: artistID, recording: cell.recording)
                cell.updateButtonImage()
            }
            follow.backgroundColor = Util.Color.secondary
            return [follow]
        }
    }
}

class RecordingCell: UITableViewCell {
    private let followingButton = UIButton()
    private let dateLabel = UILabel()
    private let recordingLabel = UILabel()
    private let artistLabel = UILabel()
    private var recordingObj: Recording!
    private var artist: Artist?
    
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
    var bgColor: UIColor? {
        get { return backgroundColor }
        set { backgroundColor = newValue }
    }
    
    init(recording: Recording, excludeArtist: Bool = false, excludeFollowingButton: Bool = false) {
        super.init(style: .default, reuseIdentifier: "recordingCell")

        recordingObj = recording

        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        if !excludeFollowingButton {
            followingButton.frame = CGRect(x: Util.Constant.cellMargin, y: Util.Constant.cellMargin, width: Util.Constant.cellMargin, height: Util.Constant.cellMargin)
            followingButton.contentMode = .scaleAspectFill
            followingButton.clipsToBounds = true
            followingButton.addTarget(self, action: #selector(followingButtonPressed(_:)), for: .touchUpInside)
            updateButtonImage()
        }

        let labelX = excludeFollowingButton ? Util.Constant.cellMargin : followingButton.frame.maxX + Util.Constant.cellMargin
        let labelWidth = contentView.frame.width - labelX
        
        if !excludeArtist {
            artistLabel.frame = CGRect(x: labelX, y: Util.Constant.cellMargin, width: labelWidth, height: Util.Constant.cellContentHeight * 0.5)
            artistLabel.setupLabel(fontWeight: .black, fontSize: 24.0, textColor: Util.Color.main)
            artist = recording.artists.first
            artistLabel.text = artist?.name
        }
        
        let margin: CGFloat = 2.0
        let recordingLabelY = excludeArtist ? Util.Constant.cellMargin : artistLabel.frame.maxY + margin
        let recordingLabelHeight = excludeArtist ? Util.Constant.cellContentHeight * 0.6 : Util.Constant.cellContentHeight * 0.5 * 0.6 - margin
        let dateLabelHeight = excludeArtist ? Util.Constant.cellContentHeight * 0.4 : Util.Constant.cellContentHeight * 0.5 * 0.4 - margin

        recordingLabel.frame = CGRect(x: labelX, y: recordingLabelY, width: labelWidth, height: recordingLabelHeight)
        dateLabel.frame = CGRect(x: labelX, y: recordingLabel.frame.maxY + margin, width: labelWidth, height: dateLabelHeight)

        let recordingLabelFontSize: CGFloat = excludeArtist ? 28.0 : 14.0
        recordingLabel.setupLabel(fontWeight: .heavy, fontSize: recordingLabelFontSize)

        let dateLabelFontSize: CGFloat = excludeArtist ? 20.0 : 10.0
        dateLabel.setupLabel(fontWeight: .regular, fontSize: dateLabelFontSize)

        addSubview(followingButton)
        addSubview(artistLabel)
        addSubview(recordingLabel)
        addSubview(dateLabel)
        
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateButtonImage() {
        DispatchQueue.main.async {
            if let artistID = self.recording.artists.first?.id,
                let artists = UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) as? [String],
                artists.contains(artistID) {
                self.followingButton.setImage(UIImage(named: "Followed"), for: .normal)
            } else {
                self.followingButton.setImage(UIImage(named: "NotFollowed"), for: .normal)
            }
        }
    }
    
    @objc func followingButtonPressed(_ sender: UIButton) {
        guard let followedArtists = UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) as? [String] else { return }
        guard let id = artist?.id else { return }
        
        if followedArtists.contains(id) {
            Util.unfollowArtist(id: id)
        } else {
            Util.followArtist(id: id, recording: recording)
        }
        updateButtonImage()
    }
}
