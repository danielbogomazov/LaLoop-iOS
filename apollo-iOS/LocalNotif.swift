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
        
        var artists = ""
        for (index, artist) in recording.artists.enumerated() {
            let name: String = index == 0 ? artist.name : " & " + artist.name
            artists.append(contentsOf: name)
        }
        if recording.name == "TBA" {
            content.body = NSString.localizedUserNotificationString(forKey: "By \(artists)", arguments: nil)
        } else {
            content.body = NSString.localizedUserNotificationString(forKey: recording.name + " by \(artists)", arguments: nil)
        }
        
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: recording.id, content: content, trigger: trigger)
        
        
        let center = UNUserNotificationCenter.current()
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
    
    private init() {}
}
