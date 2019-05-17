//
//  SettingsViewController.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-02.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var settingsTableView: HeaderTableView!
    
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
    
    var clearDataButton = UIButton()
    
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

        settingsTableView = HeaderTableView(frame: .zero, style: .grouped, title: "Settings")
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsTableView)
        view.addConstraints([NSLayoutConstraint(item: settingsTableView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: settingsTableView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: settingsTableView!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: settingsTableView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)])
        
        settingsTableView.delegate = self
        settingsTableView.navigationController = navigationController

    }
    
    override func viewWillAppear(_ animated: Bool) {
        settingsTableView.headerViewHeightConstraint.constant = settingsTableView.maxHeaderHeight
        settingsTableView.updateHeader()
        scrollTableViewToTop(animated: false)
    }
    
    func scrollTableViewToTop(animated: Bool = true) {

        if settingsTableView.tableView.numberOfSections > 0 &&
            settingsTableView.tableView.numberOfRows(inSection: 0) > 0 {
            
            settingsTableView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: animated)
        }
    }

}

extension SettingsViewController: HeaderViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UITableViewCell()
        headerCell.backgroundColor = Util.Color.backgroundColor
        
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCell.addSubview(headerLabel)
        headerCell.addConstraints([NSLayoutConstraint(item: headerLabel, attribute: .left, relatedBy: .equal, toItem: headerCell, attribute: .left, multiplier: 1.0, constant: 12),
                                   NSLayoutConstraint(item: headerLabel, attribute: .bottom, relatedBy: .equal, toItem: headerCell, attribute: .bottom, multiplier: 1.0, constant: -8)])
        headerLabel.setupLabel(fontWeight: .medium, fontSize: 12, textColor: UIColor.white.withAlphaComponent(0.6))
        
        switch section {
        case 0:
            headerLabel.text = "RECEIVE NOTIFICATIONS FOR"
        case 1:
            headerLabel.text = "FAVORITE GENRES"
        default:
            headerLabel.text = ""
        }
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return notifsSection.count
        case 1:
            return genresSection.count
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return notifsSection[indexPath.row].detail != "" ? 80 : 50
        } else {
            return 50
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
            }
            return cell
        case 2:
            // Clear Data
            let cell = UITableViewCell()
            cell.backgroundColor = Util.Color.backgroundColor
            clearDataButton.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(clearDataButton)
            cell.addConstraints([NSLayoutConstraint(item: clearDataButton, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1.0, constant: 0),
                                 NSLayoutConstraint(item: clearDataButton, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1.0, constant: 0),
                                 NSLayoutConstraint(item: clearDataButton, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1.0, constant: 0),
                                 NSLayoutConstraint(item: clearDataButton, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1.0, constant: 0)])
            clearDataButton.setTitle("Clear Data", for: .normal)
            clearDataButton.setTitleColor(.white, for: .normal)
            clearDataButton.titleLabel?.setupLabel(fontWeight: .bold, fontSize: clearDataButton.titleLabel?.font.pointSize ?? 18)
            clearDataButton.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            clearDataButton.addTarget(self, action: #selector(clearDataButtonPressed(_:)), for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @objc func clearDataButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "Clearing the data will remove all followed albums and artists.\nAll upcoming notifications and preferences will also be removed.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Clear Data", style: .destructive, handler: { _ in
            UserDefaults.standard.set([], forKey: Util.Keys.followedRecordingsKey)
            UserDefaults.standard.set([], forKey: Util.Keys.followedArtistsKey)
            LocalNotif.removeAllNotifications()
            Util.resetSettings()
            self.settingsTableView.tableView.reloadData()
        }))
        present(alert, animated: true, completion: nil)
    }
}
