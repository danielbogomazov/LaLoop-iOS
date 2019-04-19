//
//  FollowingViewController.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2019-03-14.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit
import CoreData

class FollowingViewController: UIViewController {

    lazy private var artistsTableView = UITableView()
    lazy private var noneFollowingLabel = UILabel()
    private var artists: [ArtistStruct] = []

    struct ArtistStruct {
        var obj: Artist
        var isOpen: Bool
        var followedRecordings: [Recording]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Util.Color.backgroundColor
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNoneFollowingLabel()
        populateArtists()
        reloadTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        
        artistsTableView = UITableView(frame: CGRect(), style: .grouped)
        artistsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(artistsTableView)
        let top = navigationController?.navigationBar.frame.maxY ?? 0
        let bottom = tabBarController?.tabBar.frame.height ?? 0
        view.addConstraints([NSLayoutConstraint(item: artistsTableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: top),
                             NSLayoutConstraint(item: artistsTableView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: artistsTableView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: artistsTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -bottom)])
        artistsTableView.backgroundColor = Util.Color.backgroundColor
        artistsTableView.delegate = self
        artistsTableView.dataSource = self
    }
    
    /// Needed to reload the table view from AppDelegate
    func reloadTableView() {
        self.artistsTableView.reloadData()
    }
    
    func populateArtists() {
        artists.removeAll()
        guard let followedRecordings = UserDefaults.standard.array(forKey: Util.Constant.followedRecordingsKey) as? [String] else { return }
        for id in followedRecordings {
            guard let artistID = (AppDelegate.recordings.first { $0.id == id})?.artists.first?.id else { return}
            
            let artistRequest: NSFetchRequest<Artist> = Artist.fetchRequest()
            artistRequest.predicate = NSPredicate(format: "id == %@", artistID)
            
            let recordingRequest: NSFetchRequest<Recording> = Recording.fetchRequest()
            recordingRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let artist = try AppDelegate.viewContext.fetch(artistRequest)[0]
                let recording = try AppDelegate.viewContext.fetch(recordingRequest)[0]
                
                if let index = artists.firstIndex(where: { $0.obj == artist }) {
                    artists[index].followedRecordings.append(recording)
                } else {
                    artists.append(ArtistStruct(obj: artist, isOpen: false, followedRecordings: [recording]))
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        noneFollowingLabel.isHidden = artists.count > 0
    }
    
    func unfollowPromptForArtist(_ artist: Artist) {
        let alert = UIAlertController(title: "Unfollow Artist", message: "Unfollow all upcoming recording notifications for the artist?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { _ in
            for recording in artist.recordings {
                Util.unfollowRecording(id: recording.id)
                DispatchQueue.main.async {
                    self.artists = self.artists.filter { $0.obj != artist }
                    self.noneFollowingLabel.isHidden = self.artists.count > 0
                    self.reloadTableView()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func unfollowPromptForRecording(_ recording: Recording) {
        let alert = UIAlertController(title: "Unfollow Recording", message: "Unfollow this recording?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { _ in
            Util.unfollowRecording(id: recording.id)
            DispatchQueue.main.async {
                self.populateArtists()
                self.noneFollowingLabel.isHidden = self.artists.count > 0
                self.reloadTableView()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupNoneFollowingLabel() {
        noneFollowingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noneFollowingLabel)
        view.addConstraints([NSLayoutConstraint(item: noneFollowingLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: noneFollowingLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: noneFollowingLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)])
        noneFollowingLabel.isHidden = true
        noneFollowingLabel.textAlignment = .center
        noneFollowingLabel.textColor = Util.Color.main
        noneFollowingLabel.text = "Not following any artists"
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FollowingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        } else {
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists[section].isOpen ? artists[section].followedRecordings.count + 1 : 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = ArtistCell(artist: artists[indexPath.section].obj, isExpanded: artists[indexPath.section].isOpen)
            cell.artistLabelFontSize = 18.0
            cell.upcomingLabelFontSize = 12.0
            return cell
        } else {
            let recordings = Array(artists[indexPath.section].followedRecordings)
            let cell = RecordingCell(recording: recordings[indexPath.row - 1], excludeFollowingButton: true, excludeArtist: true)
            cell.recordingLabelFontSize = 20.0
            cell.dateLabelFontSize = 16.0
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            artists[indexPath.section].isOpen = !artists[indexPath.section].isOpen
            tableView.reloadSections([indexPath.section], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let unfollow = UITableViewRowAction(style: .default, title: "Unfollow") { (_, _) in
            indexPath.row == 0 ? self.unfollowPromptForArtist(self.artists[indexPath.section].obj) :
                self.unfollowPromptForRecording((tableView.cellForRow(at: indexPath) as! RecordingCell).recording)
        }
        unfollow.backgroundColor = UIColor.red
        return [unfollow]
    }
}
