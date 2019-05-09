//
//  Util.swift
//  LaLoop
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
    }

    struct Color {
        static let backgroundColor: UIColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        static let main: UIColor = UIColor(red: 255/255, green: 221/255, blue: 92/255, alpha: 1)
        static let secondary: UIColor = UIColor(red: 34/255, green: 112/255, blue: 102/255, alpha: 1)
        static let secondaryDark: UIColor = UIColor(red: 38/255, green: 89/255, blue: 97/255, alpha: 1)
    }
        
    struct URLs {
        static let recordingsURL = "http://107.152.35.241/json/recordings/current.json" // apollo webserver
        static let genreURL = "http://107.152.35.241/json/genres/genres.json"
    }
    struct Keys {
        static let followedRecordingsKey = "Followed Recordings"
        static let followedArtistsKey = "Followed Artists"
        static let launchedBeforeKey = "Launched Before"
        static let followRecordingsNotifKey = "Follow Recordings Notifications"
        static let newRecordingFromArtistNotifKey = "New Recording From Artist Notifications"
        static let newRecordingFromGenreNotifKey = "New Recording From Genre Notifications"
    }
    struct Strings {
        static let followedRecordings = "Followed Recordings"
        static let newRecordingsFromFollowedArtists = "New Recordings From Followed Artists"
        static let newRecordingsFromFavoriteGenres = "New Recordings From Favorite Genres"
    }
    struct Genres {
        static let avant_garde = "Avant-garde"
        static let blues = "Blues"
        static let caribbean = "Caribbean"
        static let childrens = "Childrens"
        static let classical = "Classical"
        static let comedy = "Comedy"
        static let country = "Country"
        static let electronic = "Electronic"
        static let experimental = "Experimental"
        static let folk = "Folk"
        static let hip_hop = "Hip hop"
        static let jazz = "Jazz"
        static let latin = "Latin"
        static let pop = "Pop"
        static let rnb_and_soul = "R&B and soul"
        static let rock = "Rock"
        static let worship = "Worship"
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
    
    static func replaceCharEntitites(string: String) -> String {
        var newString = string
        newString = newString.replacingOccurrences(of: "&lt;", with: "<", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&gt;", with: ">", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&amp;", with: "&", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&quot;", with: "\"", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&apos;", with: "\'", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&cent;", with: "¢", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&pound;", with: "£", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&yen;", with: "¥", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&euro;", with: "€", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&copy;", with: "©", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "&copy;", with: "®", options: .literal, range: nil)
        return newString
    }
    
    /// Removes a recording and its artist from the following list
    ///
    /// - Parameter id: ID of the recording to unfollow
    static func unfollowRecording(id: String) {
        var followedRecordings = Util.getFollowedRecordings()
        var followedArtists = Util.getFollowedArtists()
        
        guard let recIndex = followedRecordings.firstIndex(of: id) else { return }

        followedRecordings.remove(at: recIndex)
        UserDefaults.standard.set(followedRecordings, forKey: Util.Keys.followedRecordingsKey)
        LocalNotif.removeRecording(id: id)

        let request: NSFetchRequest<Recording> = Recording.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            if let artist = try AppDelegate.viewContext.fetch(request)[0].artists.first, let artIndex = followedArtists.firstIndex(of: artist.id) {
                followedArtists.remove(at: artIndex)
                UserDefaults.standard.set(followedArtists, forKey: Util.Keys.followedArtistsKey)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Add a recording and its artist to the following list
    ///
    /// - Parameters:
    ///   - recording: Recording for which the notification will be made for
    static func followRecording(recording: Recording) {
        var followedRecordings = Util.getFollowedRecordings()
        var followedArtists = Util.getFollowedArtists()
        
        followedRecordings.append(recording.id)
        followedArtists.append(recording.artists.first!.id)
        
        UserDefaults.standard.set(followedRecordings, forKey: Util.Keys.followedRecordingsKey)
        UserDefaults.standard.set(followedArtists, forKey: Util.Keys.followedArtistsKey)
        
        LocalNotif.createRecordingReleaseNotif(recording: recording, completionHandler: { (error) in
            if let e = error {
                print(e.localizedDescription)
            }
        })
    }
    
    static func isTBA(date: Date) -> Bool {
        guard let years = Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).year else { return false }
        // TODO : years > 1000 is pretty hackish but it will do until the TBA standard is changed from the backend
        return years > 1000 ? true :  false
    }
    
    static func getFollowedRecordings() -> [String] {
        guard let arr = UserDefaults.standard.array(forKey: Util.Keys.followedRecordingsKey) else {
            UserDefaults.standard.set([], forKey: Util.Keys.followedRecordingsKey)
            return []
        }
        return arr as! [String]
    }
    
    static func getFollowedArtists() -> [String] {
        guard let arr = UserDefaults.standard.array(forKey: Util.Keys.followedArtistsKey) else {
            UserDefaults.standard.set([], forKey: Util.Keys.followedArtistsKey)
            return []
        }
        return arr as! [String]
    }
    
    static func getArtistsString(from recording: Recording) -> String {
        var artists = ""
        for (index, artist) in recording.artists.enumerated() {
            let name: String = index == 0 ? artist.name : " & " + artist.name
            artists.append(contentsOf: name)
        }
        return artists
    }
    
    static func getData(completionHandler: @escaping (Bool) ->()) {
        getData(from: Util.URLs.genreURL) { success in
            if !success {
                completionHandler(false)
                return
            }
            getData(from: Util.URLs.recordingsURL) { success in
                completionHandler(success)
            }
        }
    }

    static func getData(from urlStr: String, completionHandler: @escaping (Bool) -> ()) {
        
        guard let url = URL(string: urlStr) else { completionHandler(false); return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        let session = URLSession(configuration: .ephemeral)
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error in HTTP request: \(error!)")
                completionHandler(false)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Error in HTTP response: \(response!)")
                completionHandler(false)
                return
            }
            do {
                switch urlStr {
                case Util.URLs.recordingsURL:
                    // Store found recording IDs to be used during removing not found recordings
                    var existingRecordings: [String] = []
                    let jsonData = try JSONDecoder().decode(RecordingData.self, from: data)
                    for var recording in jsonData.recordings {
                        DispatchQueue.main.async {
                            existingRecordings.append(recording.recording_id)
                            recording.save()
                        }
                    }
                    DispatchQueue.main.async {
                        let request: NSFetchRequest<Recording> = Recording.fetchRequest()
                        do {
                            let storedRecordings = try AppDelegate.viewContext.fetch(request)
                            for recording in storedRecordings {
                                if existingRecordings.firstIndex(of: recording.id) == nil {
                                    // Remove deleted recordings
                                    Util.unfollowRecording(id: recording.id)
                                    AppDelegate.viewContext.delete(recording)
                                    try AppDelegate.viewContext.save()
                                }
                            }
                        } catch let error as NSError {
                            print("ERROR - \(error)\n--\(error.userInfo)")
                        }
                    }
                    completionHandler(true)
                case Util.URLs.genreURL:
                    var jsonData = try JSONDecoder().decode(GenreData.self, from: data)
                    jsonData.save()
                    completionHandler(true)
                default:
                    completionHandler(false)
                }
            } catch let error as NSError {
                print("ERROR - \(error)\n--\(error.userInfo)")
                completionHandler(false)
            }
        }
        task.resume()
    }
    
    static func allSubgenres() -> [String] {
        return AppDelegate.avant_garde_subgenres + AppDelegate.blues_subgenres + AppDelegate.caribbean_subgenres + AppDelegate.childrens_subgenres + AppDelegate.classical_subgenres + AppDelegate.comedy_subgenres + AppDelegate.country_subgenres + AppDelegate.electronic_subgenres + AppDelegate.experimental_subgenres + AppDelegate.folk_subgenres + AppDelegate.hip_hop_subgenres + AppDelegate.jazz_subgenres + AppDelegate.latin_subgenres + AppDelegate.pop_subgenres + AppDelegate.rnb_and_soul_subgenres + AppDelegate.rock_subgenres + AppDelegate.worship_subgenres
    }
    
    static func resetSettings() {
        UserDefaults.standard.set(true, forKey: Util.Keys.launchedBeforeKey)
        UserDefaults.standard.set(true, forKey: Util.Keys.followRecordingsNotifKey)
        UserDefaults.standard.set(true, forKey: Util.Keys.newRecordingFromArtistNotifKey)
        UserDefaults.standard.set(true, forKey: Util.Keys.newRecordingFromGenreNotifKey)
        UserDefaults.standard.set(false, forKey: Util.Genres.avant_garde)
        UserDefaults.standard.set(false, forKey: Util.Genres.blues)
        UserDefaults.standard.set(false, forKey: Util.Genres.caribbean)
        UserDefaults.standard.set(false, forKey: Util.Genres.childrens)
        UserDefaults.standard.set(false, forKey: Util.Genres.classical)
        UserDefaults.standard.set(false, forKey: Util.Genres.comedy)
        UserDefaults.standard.set(false, forKey: Util.Genres.country)
        UserDefaults.standard.set(false, forKey: Util.Genres.electronic)
        UserDefaults.standard.set(false, forKey: Util.Genres.experimental)
        UserDefaults.standard.set(false, forKey: Util.Genres.folk)
        UserDefaults.standard.set(false, forKey: Util.Genres.hip_hop)
        UserDefaults.standard.set(false, forKey: Util.Genres.jazz)
        UserDefaults.standard.set(false, forKey: Util.Genres.latin)
        UserDefaults.standard.set(false, forKey: Util.Genres.pop)
        UserDefaults.standard.set(false, forKey: Util.Genres.rnb_and_soul)
        UserDefaults.standard.set(false, forKey: Util.Genres.rock)
        UserDefaults.standard.set(false, forKey: Util.Genres.worship)

    }
}
