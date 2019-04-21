//
//  LocalNotif.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2019-01-01.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation
import UserNotifications

struct LocalNotif {
    
    static let center = UNUserNotificationCenter.current()
    
    static func createNewRecordingNotif(recording: Recording, completionHandler: @escaping (Bool, Error?) -> Void) {

        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Recording Released!", arguments: nil)
        content.body = createBody(for: recording)
        
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
            if let e = error {
                completionHandler(false, e)
            } else {
                completionHandler(true, nil)
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
                    
                    if n.content.body != createBody(for: recording) ||
                        (date == nil && notifDateComponents != Calendar.current.dateComponents([.day, .month, .year], from: getDefaultTBAReleaseDate())) ||
                        (date != nil && notifDateComponents != Calendar.current.dateComponents([.day, .month, .year], from: date!)) {
                        
                        removeRecording(id: recording.id)
                        createNewRecordingNotif(recording: recording, completionHandler: { (success, error) in
                            if let e = error {
                                print(e.localizedDescription)
                            }
                            if !success {
                                // TODO
                            }
                        })
                    }
                } else {
                    // TODO
                }
            }
        })
    }
    
    static func createBody(for recording: Recording) -> String {
        var artists = ""
        for (index, artist) in recording.artists.enumerated() {
            let name: String = index == 0 ? artist.name : " & " + artist.name
            artists.append(contentsOf: name)
        }
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

    private init() {}
}
