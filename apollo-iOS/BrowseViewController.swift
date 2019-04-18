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
    
    private lazy var recordingsTableView = UITableView()
    private lazy var searchBar = UISearchBar()
    private lazy var refreshControl = UIRefreshControl()
    private lazy var loadingView = UIView()
    private var filteredRecordings: [Recording] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Util.Color.backgroundColor
        
        setupTableView()
        setupLoadingView()

        getData(completionHandler: { success in
            DispatchQueue.main.async {
                if success {
                    self.populateRecordings()
                    LocalNotif.update()
                    self.reloadTableView()
                    self.hideLoadingView()
                } else {
                    // TODO - Load from cache?
                }
            }
        })
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func hideLoadingView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.loadingView.alpha = 0
        }) { _ in
            UIView.animate(withDuration: 0.4) {
                self.tabBarController?.tabBar.isHidden = false
                self.navigationController?.navigationBar.isHidden = false
                self.tabBarController?.tabBar.alpha = 1
                self.navigationController?.navigationBar.alpha = 1
            }
        }
    }
    
    func setupLoadingView() {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.alpha = 0
        navigationController?.navigationBar.alpha = 0
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        
        
        view.addConstraints([NSLayoutConstraint(item: loadingView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: loadingView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: loadingView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: loadingView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)])
        loadingView.backgroundColor = Util.Color.backgroundColor
        
        let apolloLabel = UILabel()
        apolloLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(apolloLabel)
        loadingView.addConstraints([NSLayoutConstraint(item: apolloLabel, attribute: .top, relatedBy: .equal, toItem: loadingView, attribute: .top, multiplier: 1.0, constant: 180),
                                NSLayoutConstraint(item: apolloLabel, attribute: .left, relatedBy: .equal, toItem: loadingView, attribute: .left, multiplier: 1.0, constant: 8),
                                NSLayoutConstraint(item: apolloLabel, attribute: .right, relatedBy: .equal, toItem: loadingView, attribute: .right, multiplier: 1.0, constant: -8),
                                NSLayoutConstraint(item: apolloLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 58)])
        apolloLabel.text = "apollo"
        apolloLabel.font = UIFont(name: "Arial-BoldMT", size: 46)
        apolloLabel.textAlignment = .center
        apolloLabel.textColor = Util.Color.main
        
        let upcomingLabel = UILabel()
        upcomingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(upcomingLabel)
        loadingView.addConstraints([NSLayoutConstraint(item: upcomingLabel, attribute: .top, relatedBy: .equal, toItem: apolloLabel, attribute: .bottom, multiplier: 1.0, constant: 8),
                                NSLayoutConstraint(item: upcomingLabel, attribute: .left, relatedBy: .equal, toItem: loadingView, attribute: .left, multiplier: 1.0, constant: 8),
                                NSLayoutConstraint(item: upcomingLabel, attribute: .right, relatedBy: .equal, toItem: loadingView, attribute: .right, multiplier: 1.0, constant: -8),
                                NSLayoutConstraint(item: upcomingLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 21)])
        upcomingLabel.text = "Upcoming Music Releases"
        upcomingLabel.font = UIFont.systemFont(ofSize: 17)
        upcomingLabel.textAlignment = .center
        upcomingLabel.textColor = UIColor.white
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
                // Store found recording IDs to be used during removing not found recordings
                var existingRecordings: [String] = []
                let jsonData = try JSONDecoder().decode(RecordingData.self, from: data)
                for var recording in jsonData.recordings {
                    DispatchQueue.main.async {
                        existingRecordings.append(recording.recording_id)
                        recording.save()
                    }
                }
                DispatchQueue.main.async {
                    let request: NSFetchRequest<Recording> = Recording.fetchRequest()
                    do {
                        let storedRecordings = try AppDelegate.viewContext.fetch(request)
                        for recording in storedRecordings {
                            if existingRecordings.firstIndex(of: recording.id) == nil {
                                AppDelegate.viewContext.delete(recording)
                                try AppDelegate.viewContext.save()
                            }
                        }
                    } catch let error as NSError {
                        print("ERROR - \(error)\n--\(error.userInfo)")
                    }
                }
                completionHandler(true)
            } catch let error as NSError {
                print("ERROR - \(error)\n--\(error.userInfo)")
                completionHandler(false)
            }
        }
        task.resume()
    }
    
    func setupTableView() {
        recordingsTableView = UITableView(frame: CGRect(), style: .plain)
        view.addSubview(recordingsTableView)
        recordingsTableView.translatesAutoresizingMaskIntoConstraints = false
        let top = navigationController?.navigationBar.frame.maxY ?? 0.0
        let bottom = tabBarController?.tabBar.frame.height ?? 0.0
        view.addConstraints([NSLayoutConstraint(item: recordingsTableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: top),
                             NSLayoutConstraint(item: recordingsTableView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: recordingsTableView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: recordingsTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -bottom)])
        recordingsTableView.backgroundColor = Util.Color.backgroundColor
        recordingsTableView.delegate = self
        recordingsTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(ref(_:)), for: .valueChanged)
        recordingsTableView.refreshControl = refreshControl
    }
    
    @objc func ref(_ sender: UIRefreshControl) {
        getData(completionHandler: { success in
            DispatchQueue.main.async {
                if success {
                    self.populateRecordings()
                    LocalNotif.update()
                    self.reloadTableView()
                }
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func filterRecordings() {
        if let filterString = searchBar.text?.lowercased() {
            filteredRecordings = AppDelegate.recordings.filter {
                $0.name.lowercased().contains(filterString) || $0.artists.first?.name.lowercased().contains(filterString) ?? false
            }
            if filteredRecordings.count == 0 {
                // TODO : Display a "none found" popup
            }
        } else {
            filteredRecordings = []
        }
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

    /// Needed to reload the table view from AppDelegate
    func reloadTableView() {
        self.recordingsTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BrowseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecordings.count == 0 ? AppDelegate.recordings.count : filteredRecordings.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "upcoming recordings"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = Util.Color.backgroundColor
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([NSLayoutConstraint(item: searchBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 8),
                             NSLayoutConstraint(item: searchBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: searchBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: searchBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 32)])
        searchBar.barStyle = .blackTranslucent
        searchBar.barTintColor = Util.Color.backgroundColor
        searchBar.showsCancelButton = true
        searchBar.tintColor = Util.Color.secondary
        (searchBar.value(forKey: "searchField") as? UITextField)?.textColor = UIColor.white
        searchBar.delegate = self

        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recording = filteredRecordings.count == 0 ? AppDelegate.recordings[indexPath.row] : filteredRecordings[indexPath.row]
        let cell = RecordingCell(recording: recording)
        cell.artistLabelFontSize = 28.0
        cell.recordingLabelFontSize = 20.0
        cell.dateLabelFontSize = 16.0
        return cell
    }
        
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if UserDefaults.standard.array(forKey: Util.Constant.followedRecordingsKey) == nil {
            UserDefaults.standard.set([], forKey: Util.Constant.followedRecordingsKey)
        }

        guard let followedRecordings = UserDefaults.standard.array(forKey: Util.Constant.followedRecordingsKey) as? [String] else { return [] }
        let cell = tableView.cellForRow(at: indexPath) as! RecordingCell
        
        if followedRecordings.contains(cell.recording.id) {
            let unfollow = UITableViewRowAction(style: .default, title: "Unfollow") { (_, _) in
                Util.unfollowRecording(id: cell.recording.id)
                DispatchQueue.main.async {
                    cell.updateButtonImage()
                }
            }
            unfollow.backgroundColor = UIColor.red
            return [unfollow]
        } else {
            let follow = UITableViewRowAction(style: .default, title: "Follow") { (_, _) in
                Util.followRecording(recording: cell.recording)
                cell.updateButtonImage()
            }
            follow.backgroundColor = Util.Color.secondary
            return [follow]
        }
    }
}

extension BrowseViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        dismissKeyboard()
        filterRecordings()
        reloadTableView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterRecordings()
        reloadTableView()
    }
}
