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
    private var filteredRecordings: [Recording] = []
    
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
