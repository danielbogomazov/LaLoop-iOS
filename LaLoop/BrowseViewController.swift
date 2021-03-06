//
//  BrowseViewController.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit
import CoreData

class BrowseViewController: UIViewController {
    
    private var recordingsTableView: HeaderTableView!
    private lazy var loadingView = UIView()
    private lazy var connectionView = UIView()
    private lazy var tryAgainButton = UIButton()
    
    var filteredRecordings: [Recording] = []
    var searchedRecordings: [Recording] = []
    var dateFilter: Util.DateFilter = .allTime
    var genresFilter: [String] = []

    
    var connected: Bool! {
        didSet {
            setup(connected: connected)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Util.Color.backgroundColor
        
        setupConectionView()
        setupTableView()
        recordingsTableView.delegate = self
        recordingsTableView.navigationController = navigationController
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Filter").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(filterButtonPressed(_:)))

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
        scrollTableViewToTop(animated: false)
        recordingsTableView.headerViewHeightConstraint.constant = recordingsTableView.maxHeaderHeight
        recordingsTableView.updateHeader()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scrollTableViewToTop(animated: Bool = true) {
        if recordingsTableView.tableView.numberOfSections > 0 &&
            recordingsTableView.tableView.numberOfRows(inSection: 0) > 0 {
            
            recordingsTableView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: animated)
        }
    }
    
    func setup(connected: Bool) {
        recordingsTableView.isHidden = !connected
        connectionView.isHidden = connected
        tryAgainButton.isEnabled = !connected
        
        if connected {
            self.populateRecordings()
            LocalNotif.update()
            self.reloadTableView()
        }
    }
    
    func setupConectionView() {
        
        let labelHeight: CGFloat = 24
        let margin: CGFloat = 64
        let buttonHeight: CGFloat = 75

        connectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectionView)
        view.addConstraints([NSLayoutConstraint(item: connectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: connectionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: connectionView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: connectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)])
        
        let errorLabel = UILabel()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        connectionView.addSubview(errorLabel)
        connectionView.addConstraints([NSLayoutConstraint(item: errorLabel, attribute: .left, relatedBy: .equal, toItem: connectionView, attribute: .left, multiplier: 1.0, constant: 12),
                                       NSLayoutConstraint(item: errorLabel, attribute: .right, relatedBy: .equal, toItem: connectionView, attribute: .right, multiplier: 1.0, constant: 12),
                                       NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: labelHeight),
                                       NSLayoutConstraint(item: errorLabel, attribute: .centerY, relatedBy: .equal, toItem: connectionView, attribute: .centerY, multiplier: 1.0, constant: -(buttonHeight + labelHeight + margin))])
        errorLabel.text = "Couldn't connect to the internet"
        errorLabel.textAlignment = .center
        errorLabel.textColor = .white
        
        
        tryAgainButton.translatesAutoresizingMaskIntoConstraints = false
        connectionView.addSubview(tryAgainButton)
        connectionView.addConstraints([NSLayoutConstraint(item: tryAgainButton, attribute: .top, relatedBy: .equal, toItem: errorLabel, attribute: .bottom, multiplier: 1.0, constant: margin),
                                       NSLayoutConstraint(item: tryAgainButton, attribute: .centerX, relatedBy: .equal, toItem: connectionView, attribute: .centerX, multiplier: 1.0, constant: 0),
                                       NSLayoutConstraint(item: tryAgainButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: buttonHeight),
                                       NSLayoutConstraint(item: tryAgainButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: buttonHeight * 3)])
        tryAgainButton.backgroundColor = Util.Color.main.withAlphaComponent(0.1)
        tryAgainButton.layer.borderColor = Util.Color.main.cgColor
        tryAgainButton.layer.borderWidth = 2.0
        tryAgainButton.layer.cornerRadius = buttonHeight / 2
        tryAgainButton.setTitle("Try Again", for: .normal)
        tryAgainButton.setTitle("Connecting...", for: .disabled)
        tryAgainButton.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .normal)
        tryAgainButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        tryAgainButton.addTarget(self, action: #selector(tryAgainButtonPressed(_:)), for: .touchUpInside)
        
    }
    
    @objc func tryAgainButtonPressed(_ sender: UIButton) {
        
        tryAgainButton.isEnabled = false
        Util.getData() { (success) in
            DispatchQueue.main.async {
                self.setup(connected: success)
            }
        }
    }
    
    @objc func filterButtonPressed(_ sender: UIBarButtonItem) {
        let filterVC = FilterViewController()
        filterVC.browseViewController = self
        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
            
    func setupTableView() {
        recordingsTableView = HeaderTableView(frame: .zero, style: .plain, title: "Browse", includeSearchBar: true)
        recordingsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recordingsTableView)
        view.addConstraints([NSLayoutConstraint(item: recordingsTableView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: recordingsTableView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: recordingsTableView!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: recordingsTableView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)])
        recordingsTableView.canRefresh = true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func searchRecordings() {
        if let searchString = recordingsTableView.searchBar.text?.lowercased() {

            let recordings = (dateFilter != .allTime || genresFilter != []) ? filteredRecordings : AppDelegate.recordings
            
            searchedRecordings = recordings.filter {
                $0.name.lowercased().contains(searchString) || $0.artists.first?.name.lowercased().contains(searchString) ?? false
            }
            recordingsTableView.setupErrorMessage(isHidden: searchedRecordings.count != 0 || searchString == "", searchString: searchString)
        } else {
            searchedRecordings = []
        }
    }
    
    func populateRecordings() {
        
        let currDate = Util.stripTimezone(from: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let request: NSFetchRequest<Recording> = Recording.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "release_date", ascending: true)]
        request.predicate = NSPredicate(format: "release_date >= %@ OR release_date == nil", currDate as NSDate)
        do {
            AppDelegate.recordings = try AppDelegate.viewContext.fetch(request)
            AppDelegate.recordings.sort {
                guard var first = $0.release_date, var second = $1.release_date else { return ($0.release_date != nil && $1.release_date == nil )}
                if Util.isTBA(date: first) {
                    first = Calendar.current.date(byAdding: .year, value: -1999, to: first) ?? first
                    if !Util.isTBA(date: second) && formatter.string(from: first) == formatter.string(from: second) {
                        // If first and second are in the same year/month but only first is a TBA date, push first back
                        return first > second
                    }
                }
                if Util.isTBA(date: second) {
                    second = Calendar.current.date(byAdding: .year, value: -1999, to: second) ?? second
                    if !Util.isTBA(date: first) && formatter.string(from: first) == formatter.string(from: second) {
                        // If first and second are in the same year/month but only second is a TBA date, push second back
                        return first > second
                    }
                }
                return first < second
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    /// Needed to reload the table view from AppDelegate
    func reloadTableView() {
        recordingsTableView.tableView.reloadData()
    }
}

extension BrowseViewController: HeaderViewDelegate {
    
    func refresh(completionHandler: @escaping () -> Void) {
        Util.getData() { (success) in
            DispatchQueue.main.async {
                self.setup(connected: success)
                completionHandler()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedRecordings.count != 0 ?
            searchedRecordings.count : filteredRecordings.count != 0 ?
            filteredRecordings.count : AppDelegate.recordings.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recording = searchedRecordings.count != 0 ?
            searchedRecordings[indexPath.row] : filteredRecordings.count != 0 ?
                filteredRecordings[indexPath.row] : AppDelegate.recordings[indexPath.row]
        let cell = RecordingCell()
        cell.includeArtistLabel = true
        cell.includeFollowingButton = true
        cell.recordingViewModel = RecordingViewModel(recording: recording)
        cell.artistLabelFontSize = 28.0
        cell.recordingLabelFontSize = 20.0
        cell.dateLabelFontSize = 16.0
        return cell
    }
        
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRow(at: indexPath) as! RecordingCell
        if cell.recordingViewModel.isFollowed {
            let unfollow = UITableViewRowAction(style: .default, title: "Unfollow") { (_, _) in
                DispatchQueue.main.async {
                    cell.recordingViewModel.changeFollowingStatus()
                }
            }
            unfollow.backgroundColor = .red
            return [unfollow]
        } else {
            let follow = UITableViewRowAction(style: .default, title: "Follow") { (_, _) in
                DispatchQueue.main.async {
                    cell.recordingViewModel.changeFollowingStatus()
                }
            }
            follow.backgroundColor = Util.Color.secondary
            return [follow]
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        dismissKeyboard()
        searchRecordings()
        recordingsTableView.setupErrorMessage(isHidden: true)
        reloadTableView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchRecordings()
        reloadTableView()
    }
}
