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
    private var artists: [artistStruct] = []

    struct artistStruct {
        var obj: Artist!
        var isOpen: Bool!
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
        
        guard let followedArtists = UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) as? [String] else { return }
        
        artists.removeAll()

        let request: NSFetchRequest<Artist> = Artist.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let predicates = followedArtists.map {
            NSPredicate(format: "id == %@", $0)
        }
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        do {
            let artistsArray = try AppDelegate.viewContext.fetch(request)
            for a in artistsArray {
                artists.append(artistStruct(obj: a, isOpen: false))
            }
            noneFollowingLabel.isHidden = artists.count > 0
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func unfollowPrompt(for artist: Artist) {
        let alert = UIAlertController(title: "Unfollow Artist?", message: "This will unfollow all upcoming recording notifications for the artist.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { _ in
            Util.unfollowArtist(id: artist.id)
            DispatchQueue.main.async {
                self.artists = self.artists.filter {
                    $0.obj != artist
                }
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
        if artists[section].isOpen {
            return artists[section].obj.recordings.count + 1
        }
        return 1
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
            cell.delegate = self
            return cell
        } else {
            let recordings = Array(artists[indexPath.section].obj.recordings)
            let cell = RecordingCell(recording: recordings[indexPath.row - 1], excludeFollowingButton: true, excludeArtist: true)
            cell.recordingLabelFontSize = 20.0
            cell.dateLabelFontSize = 16.0
            cell.bgColor = UIColor.white.withAlphaComponent(0.05)
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
            self.unfollowPrompt(for: self.artists[indexPath.section].obj)
        }
        unfollow.backgroundColor = UIColor.red
        return [unfollow]
    }
}

extension FollowingViewController: ArtistCellDelegate {
    func unfollowButtonPressed(for artist: Artist) {
        unfollowPrompt(for: artist)
    }
}
