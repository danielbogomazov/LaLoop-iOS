//
//  Util.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import CoreData

public class Util {
    
    enum entity {
        case recording
        case artist
        case genre
        case label
        case producer
    }

    struct Color {
        static let backgroundColor: UIColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        static let main: UIColor = UIColor(red: 38/255, green: 89/255, blue: 97/255, alpha: 1)
        static let mainDark: UIColor = UIColor(red: 33/255, green: 65/255, blue: 84/255, alpha: 1)
        static let secondary: UIColor = UIColor(red: 118/255, green: 166/255, blue: 101/255, alpha: 1)
        static let secondaryDark: UIColor = UIColor(red: 34/255, green: 112/255, blue: 102/255, alpha: 1)
        static let yellow: UIColor = UIColor(red: 255/255, green: 221/255, blue: 92/255, alpha: 1)
    }
        
    static func getCountdownString(until releaseDate: Date) -> String {
        let calendar = NSCalendar.current
        let current = calendar.startOfDay(for: Date())
        let release = calendar.startOfDay(for: releaseDate)
        
        let components = calendar.dateComponents([.day], from: current, to: release)
        
        if components.day! == 0 { return "TODAY" }
        if components.day! == 1 { return "TOMORROW" }
        return "\(components.day!) Days"
    }
    
    /// Checks to see if the year of the recording is the current year + 1999 (recording without a day)
    ///
    /// - Parameter date: release date of the recording pulled from the server
    /// - Returns: True if the current year + 1999 equals the recording's year - False otherwise
    static func noDay(from date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: date))!
        let curr = Int(formatter.string(from: Date()))!
        
        return curr + 1999 == year
    }
    
    /// If the year of the recording is the current year + 1999, then the release day is unknown -- use this to store the release month without the year
    ///
    /// - Parameter date: release date of the recording pulled from the server
    /// - Returns: Correct date with everything accounted for
    static func trueDate(from date: Date) -> String {
        let formatter = DateFormatter()
        
        if noDay(from: date) {
            formatter.dateFormat = "MMMM"
            let month = formatter.string(from: date)
            formatter.dateFormat = "yyyy"
            return "\(month) \(Int(formatter.string(from: date))! - 1999)"
        }
        
        formatter.dateFormat = "MMMM dd, YYYY"
        return formatter.string(from: date)
    }
}

public class DevelopmentUtil {
    
    static func displaySavedCoreData() {
        let recordings = findMatchFor(entity: .recording) as! [Recording]
        let artists = findMatchFor(entity: .artist) as! [Artist]
        let genres = findMatchFor(entity: .genre) as! [Genre]
        let labels = findMatchFor(entity: .label) as! [Label]
        let producers = findMatchFor(entity: .producer) as! [Producer]
        
        print("\n== Saved Recordings ==")
        for recording in recordings {
            print(recording.id)
            print(recording.release_date ?? "TBA")
            print("Num of artists: \(recording.artists.count)")
        }
        
        print("\n== Saved Artists ==")
        for artist in artists {
            print(artist.id)
        }
        
        print("\n== Saved Genres ==")
        for genre in genres {
            print(genre.id)
        }
        
        print("\n== Saved Labels ==")
        for label in labels {
            print(label.id)
        }

        print("\n== Saved Producers ==")
        for producer in producers {
            print(producer.id)
        }
    }
    
    static func deleteSavedCoreData() {
        var entities = findMatchFor(entity: .recording)
        entities.append(contentsOf: findMatchFor(entity: .artist))
        entities.append(contentsOf: findMatchFor(entity: .genre))
        entities.append(contentsOf: findMatchFor(entity: .label))
        entities.append(contentsOf: findMatchFor(entity: .producer))

        for entity in entities {
            AppDelegate.viewContext.delete(entity)
        }
    }
    
    
    static func findMatchFor(entity: Util.entity) -> [RecordingInformation] {
        switch entity {
        case .recording:
            let request: NSFetchRequest<Recording> = Recording.fetchRequest()
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        case .artist:
            let request: NSFetchRequest<Artist> = Artist.fetchRequest()
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        case .genre:
            let request: NSFetchRequest<Genre> = Genre.fetchRequest()
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        case .label:
            let request: NSFetchRequest<Label> = Label.fetchRequest()
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        default:
            let request: NSFetchRequest<Producer> = Producer.fetchRequest()
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        }
    }
}