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

    private var artistsTableView: UITableView!
    private var artists: [artistStruct] = []

    struct artistStruct {
        var obj: Artist!
        var isOpen: Bool!
    }
    
    var browseViewController: BrowseViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Util.Color.backgroundColor
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTableView()
        populateArtists()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        
        // Safe Area
        let y: CGFloat = navigationController?.navigationBar.frame.maxY ?? 0
        let height: CGFloat = view.frame.height - y - (tabBarController?.tabBar.frame.height ?? 0)
        
        let frame = CGRect(x: 0, y: y, width: view.bounds.width, height: height)
        
        artistsTableView = UITableView(frame: frame, style: .grouped)
        artistsTableView.backgroundColor = Util.Color.backgroundColor
        artistsTableView.delegate = self
        artistsTableView.dataSource = self
        view.addSubview(artistsTableView)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.artistsTableView.reloadData()
        }
    }
    
    func populateArtists() {
        
        guard let followedArtists = UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) as? [String] else { return }

        let request: NSFetchRequest<Artist> = Artist.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let predicates = followedArtists.map {
            NSPredicate(format: "id == %@", $0)
        }
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        do {
            let artistsArray = try AppDelegate.viewContext.fetch(request)
            for a in artistsArray {
                if !artists.contains(where: { $0.obj == a }) {
                    artists.append(artistStruct(obj: a, isOpen: false))
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FollowingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return Util.Constant.sectionHeight
        } else {
            return Util.Constant.cellHeight
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
            return ArtistCell(artist: artists[indexPath.section].obj)
        } else {
            let recordings = Array(artists[indexPath.section].obj.recordings)
            let cell = RecordingCell(recording: recordings[indexPath.row - 1], excludeArtist: true, excludeFollowingButton: true)
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
}

class ArtistCell: UITableViewCell {

    init(artist: Artist) {
        super.init(style: .default, reuseIdentifier: "artistCell")
        
        let artistLabel = UILabel()
        let recordingsLabel = UILabel()
        
        backgroundColor = Util.Color.backgroundColor
        selectionStyle = .none

        let margin: CGFloat = 2.0
        let labelWidth = contentView.frame.width
        artistLabel.frame = CGRect(x: Util.Constant.sectionMargin, y: Util.Constant.sectionMargin + Util.Constant.sectionContentHeight * 0.1, width: labelWidth, height: Util.Constant.sectionContentHeight * 0.5)
        recordingsLabel.frame = CGRect(x: Util.Constant.sectionMargin, y: artistLabel.frame.maxY + margin, width: labelWidth, height: Util.Constant.sectionContentHeight * 0.3 - margin)
        
        artistLabel.setupLabel(fontWeight: .black, fontSize: 18.0, textColor: Util.Color.main)
        recordingsLabel.setupLabel(fontWeight: .regular, fontSize: 9.0)
        
        artistLabel.text = artist.name
        let numRecordings = artist.recordings.count
        recordingsLabel.text = "\(numRecordings) upcoming recording" + (numRecordings != 1 ? "s" : "")
        
        contentView.addSubview(artistLabel)
        contentView.addSubview(recordingsLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
