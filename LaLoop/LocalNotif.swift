//
//  LocalNotif.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-01-01.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation
import UserNotifications
import CoreData

struct LocalNotif {

    enum NewReleaseType {
        case favoriteGenre
        case followedArtist
    }
    
    static let center = UNUserNotificationCenter.current()
    
    // Creates a notification for an upcoming release
    static func createRecordingReleaseNotif(recording: Recording, completionHandler: ((Error?) -> Void)?) {

        if !UserDefaults.standard.bool(forKey: Util.Keys.followRecordingsNotifKey) {
            completionHandler?(nil)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Recording Released!", arguments: nil)
        content.body = createRecordingReleaseBody(for: recording)
        
        var dateComponents: DateComponents
        if let date = recording.release_date {
            if Util.isTBA(date: date) {
                let newDate = Calendar.current.date(byAdding: .year, value: -1999, to: date)
                dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: newDate?.endOfMonth() ?? date)
            } else {
                dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
            }
        } else {
            dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: getDefaultTBAReleaseDate())
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: recording.id, content: content, trigger: trigger)

        center.add(request) { (error: Error?) in
            completionHandler?(error)
        }
    }
    
    static func createNewReleaseAddedNotif(type: NewReleaseType, recording: Recording, completionHandler: ((Error?) -> Void)?) {

        switch type {
        case .followedArtist:

            if !UserDefaults.standard.bool(forKey: Util.Keys.newRecordingFromArtistNotifKey) {
                completionHandler?(nil)
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "New Recording Added", arguments: nil)
            content.body = createNewRecordingAddedBody(for: recording, type: .followedArtist)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
            let request = UNNotificationRequest(identifier: "a_recordingadded" + recording.id, content: content, trigger: trigger)
            
            center.add(request) { (error: Error?) in
                completionHandler?(error)
            }
        default:

            if !UserDefaults.standard.bool(forKey: Util.Keys.newRecordingFromGenreNotifKey) {
                completionHandler?(nil)
                return
            }

            var foundGenres: [String] = []
            for genre in recording.genres {

                if UserDefaults.standard.bool(forKey: Util.Genres.avant_garde) && AppDelegate.avant_garde_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.avant_garde)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.blues) && AppDelegate.blues_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.blues)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.caribbean) && AppDelegate.caribbean_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.caribbean)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.childrens) && AppDelegate.childrens_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.childrens)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.classical) && AppDelegate.classical_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.classical)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.comedy) && AppDelegate.comedy_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.comedy)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.country) && AppDelegate.country_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.country)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.electronic) && AppDelegate.electronic_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.electronic)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.experimental) && AppDelegate.experimental_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.experimental)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.folk) && AppDelegate.folk_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.folk)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.hip_hop) && AppDelegate.hip_hop_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.hip_hop)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.jazz) && AppDelegate.jazz_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.jazz)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.latin) && AppDelegate.latin_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.latin)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.pop) && AppDelegate.pop_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.pop)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.rnb_and_soul) && AppDelegate.rnb_and_soul_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.rnb_and_soul)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.rock) && AppDelegate.rock_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.rock)
                } else if UserDefaults.standard.bool(forKey: Util.Genres.worship) && AppDelegate.worship_subgenres.contains(genre.name) {
                    foundGenres.append(Util.Genres.worship)
                }
            }
            if foundGenres.count > 0 {
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "New Recording Added", arguments: nil)
                content.body = createNewRecordingAddedBody(for: recording, type: .favoriteGenre, foundGenres)
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                let request = UNNotificationRequest(identifier: "g_recordingadded" + recording.id, content: content, trigger: trigger)
                
                center.add(request) { (error: Error?) in
                    completionHandler?(error)
                }
            }
        }
    }
    
    static func removeRecording(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    static func update() {
        center.getPendingNotificationRequests(completionHandler: { notif in
            for n in notif {
                if let recording = AppDelegate.recordings.first(where: { $0.id == n.identifier }) {
                    let date = recording.release_date
                    let notifDateComponents = (n.trigger as! UNCalendarNotificationTrigger).dateComponents
                    
                    if n.content.body != createRecordingReleaseBody(for: recording) ||
                        (date == nil && notifDateComponents != Calendar.current.dateComponents([.day, .month, .year], from: getDefaultTBAReleaseDate())) ||
                        (date != nil && notifDateComponents != Calendar.current.dateComponents([.day, .month, .year], from: date!)) {
                        
                        removeRecording(id: recording.id)
                        createRecordingReleaseNotif(recording: recording, completionHandler: { (error) in
                            if let e = error {
                                print(e.localizedDescription)
                            }
                        })
                    }
                } else {
                    // TODO
                }
            }
        })
    }
    
    static func createRecordingReleaseBody(for recording: Recording) -> String {
        let artists = Util.getArtistsString(from: recording)
        return recording.name == "TBA" ? NSString.localizedUserNotificationString(forKey: "By \(artists)", arguments: nil) : NSString.localizedUserNotificationString(forKey: recording.name + " by \(artists)", arguments: nil)
    }
    
    static func getDefaultTBAReleaseDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.date(from: "4999/01/01") ?? Date()
    }
    
    static func isTBAReleaseDate(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        guard let d = Int(formatter.string(from: date)) else { return false }
        return d > 4000
    }
    
    static func createNewRecordingAddedBody(for recording: Recording, type: NewReleaseType, _ genres: [String] = []) -> String {
        switch type {
        case .followedArtist:
            var rs = Util.getArtistsString(from: recording) + " has a new album releasing"
            if recording.name != "TBA" {
                rs += " named \(recording.name!)"
            }
            return rs
        default:
            var rs = "A new album has been added with your favorite genre" + (genres.count > 1 ? "s" : "") + " ("
            for genre in Set(genres) {
                rs += genre + ", "
            }
            if rs.last == " " {
                let _ = rs.popLast()
                let _ = rs.popLast()
            }
            return rs + ") by " + Util.getArtistsString(from: recording)
        }
    }
    
    /// Removes notifications for all followed recordings
    static func removeAllNotifications() {
        for id in Util.getFollowedRecordings() {
            LocalNotif.removeRecording(id: id)
        }
    }
    
    /// Creates notifications for all followed recordings
    static func addAllNotifications() {
        for id in Util.getFollowedRecordings() {
            let request: NSFetchRequest<Recording> = Recording.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            do {
                let recording = try AppDelegate.viewContext.fetch(request)
                LocalNotif.createRecordingReleaseNotif(recording: recording[0], completionHandler: nil)
            } catch let error as NSError {
                print("ERROR - \(error)\n--\(error.userInfo)")
            }
        }
    }
    
    static func printPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        center.getPendingNotificationRequests(completionHandler: { notif in
            completion(notif)
        })
    }
    
    private init() {}
}
