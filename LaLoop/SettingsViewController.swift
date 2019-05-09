//
//  SettingsViewController.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-02.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var tableView: HeaderTableView!
    
    var notifsSection: [Section] = [Section(title: Util.Strings.followedRecordings),
                                    Section(title: Util.Strings.newRecordingsFromFavoriteGenres),
                                    Section(title: Util.Strings.newRecordingsFromFollowedArtists, detail: "An artist is added to your favorites when you star one of their recordings")]
   
    var genresSection: [Section] = [Section(title: Util.Genres.avant_garde),
                                    Section(title: Util.Genres.blues),
                                    Section(title: Util.Genres.caribbean),
                                    Section(title: Util.Genres.childrens),
                                    Section(title: Util.Genres.classical),
                                    Section(title: Util.Genres.comedy),
                                    Section(title: Util.Genres.country),
                                    Section(title: Util.Genres.electronic),
                                    Section(title: Util.Genres.experimental),
                                    Section(title: Util.Genres.folk),
                                    Section(title: Util.Genres.hip_hop),
                                    Section(title: Util.Genres.jazz),
                                    Section(title: Util.Genres.latin),
                                    Section(title: Util.Genres.pop),
                                    Section(title: Util.Genres.rnb_and_soul),
                                    Section(title: Util.Genres.rock),
                                    Section(title: Util.Genres.worship)]
    
    enum NotifType {
        case followedRecording
        case newRecordingByArtist
        case newRecordingByGenre
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        title = "Settings"
        navigationController?.navigationBar.barStyle = .blackOpaque
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Util.Color.secondaryDark
        
        view.backgroundColor = Util.Color.backgroundColor

        tableView = HeaderTableView(frame: .zero, style: .grouped, title: "Settings")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addConstraints([NSLayoutConstraint(item: tableView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: tableView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: tableView!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: tableView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)])
        
        tableView.delegate = self
        tableView.navigationController = navigationController

    }
}

extension SettingsViewController: HeaderViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UITableViewCell()
        headerCell.backgroundColor = Util.Color.backgroundColor
        
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCell.addSubview(headerLabel)
        headerCell.addConstraints([NSLayoutConstraint(item: headerLabel, attribute: .left, relatedBy: .equal, toItem: headerCell, attribute: .left, multiplier: 1.0, constant: 12),
                                   NSLayoutConstraint(item: headerLabel, attribute: .bottom, relatedBy: .equal, toItem: headerCell, attribute: .bottom, multiplier: 1.0, constant: -8)])
        headerLabel.text = section == 0 ? "RECEIVE NOTIFICATIONS FOR" : "FAVORITE GENRES"
        headerLabel.setupLabel(fontWeight: .medium, fontSize: 12, textColor: UIColor.white.withAlphaComponent(0.6))
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return notifsSection.count
        } else if section == 1 {
            return genresSection.count
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return notifsSection[indexPath.row].detail != "" ? 80 : 50
        case 1:
            return 50
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Notifs
            let cell = SectionCell()
            cell.sectionViewModel = SectionViewModel(section: notifsSection[indexPath.row])
            cell.switchAction = { sender in
                let value = (sender as! UISwitch).isOn
                switch self.notifsSection[indexPath.row].title {
                case Util.Strings.followedRecordings:
                    UserDefaults.standard.set(value, forKey: Util.Keys.followRecordingsNotifKey)
                    value ? LocalNotif.addAllNotifications() : LocalNotif.removeAllNotifications()
                case Util.Strings.newRecordingsFromFollowedArtists:
                    UserDefaults.standard.set(value, forKey: Util.Keys.newRecordingFromArtistNotifKey)
                case Util.Strings.newRecordingsFromFavoriteGenres:
                    UserDefaults.standard.set(value, forKey: Util.Keys.newRecordingFromGenreNotifKey)
                default:
                    fatalError()
                }
            }
            return cell
        case 1:
            // Genres
            let section = genresSection[indexPath.row]
            let cell = SectionCell()
            cell.sectionViewModel = SectionViewModel(section: section)
            cell.switchAction = { sender in
                UserDefaults.standard.set((sender as! UISwitch).isOn, forKey: section.title)
                if (sender as! UISwitch).isOn {
                    print("\(section.title) is on")
                } else {
                    print("\(section.title) is off")
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}
