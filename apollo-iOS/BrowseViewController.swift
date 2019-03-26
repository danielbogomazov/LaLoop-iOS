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
                
                guard var first = $0.release_date, var second = $1.release_date else { return ($0.release_date != nil && $1.release_date == nil )}
                
                if Util.isTBA(date: first) {
                    first = Calendar.current.date(byAdding: .year, value: -1999, to: first) ?? first
                }
                if Util.isTBA(date: second) {
                    second = Calendar.current.date(byAdding: .year, value: -1999, to: second) ?? second
                }
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
        return 100
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
        let cell = RecordingCell(recording: AppDelegate.recordings[indexPath.row])
        cell.artistLabelFontSize = 28.0
        cell.recordingLabelFontSize = 20.0
        cell.dateLabelFontSize = 16.0
        return cell
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
            unfollow.backgroundColor = UIColor.red
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
