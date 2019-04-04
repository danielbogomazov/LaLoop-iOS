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
    
    static func createNewRecording(recording: Recording, completionHandler: @escaping (Bool, Error?) -> Void) {
        // TODO : When the date changes, make sure the notification changes as well
        guard let date = recording.release_date else {
            completionHandler(false, nil)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Recording Released!", arguments: nil)
        content.body = createBody(for: recording)
        
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
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
                    if let date = recording.release_date {
                        if (n.trigger as! UNCalendarNotificationTrigger).dateComponents != Calendar.current.dateComponents([.day, .month, .year], from: date) || n.content.body != createBody(for: recording) {
                            
                            removeRecording(id: recording.id)
                            createNewRecording(recording: recording, completionHandler: { (success, error) in
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

    private init() {}
}
