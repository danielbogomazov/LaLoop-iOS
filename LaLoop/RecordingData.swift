//
//  RecordingData.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation
import CoreData

struct RecordingData: Decodable {
    var recordings: [RecordingObj]
}

struct RecordingObj: Decodable {
    var recording_id: String
    var recording_name: String
    var recording_release_date: String
    var artist_id: String
    var artist_name: String
    var genres: [GenreObj]
    var label_id: String
    var label_name: String
    
    mutating func save() {

        recording_name = Util.replaceCharEntitites(string: recording_name)
        artist_name = Util.replaceCharEntitites(string: artist_name)
        label_name = Util.replaceCharEntitites(string: label_name)
        for var genre in genres {
            genre.genre_name = Util.replaceCharEntitites(string: genre.genre_name)
        }
        
        let foundRecordings = findMatchFor(entity: .recording) as! [Recording]
        let foundArtists = findMatchFor(entity: .artist) as! [Artist]
        let foundGenres = findMatchFor(entity: .genre) as! [Genre]
        let foundLabels = findMatchFor(entity: .label) as! [Label]
        
        var recording: Recording!
        var newRecording = false
        
        if foundRecordings.count < 1 {
            recording = (createNewFor(entity: .recording)[0] as! Recording)
            recording.date_added = Date()
            newRecording = true
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            recording = foundRecordings[0]
            recording.name = recording_name
            recording.release_date = recording_release_date != "" ? formatter.date(from: recording_release_date)! : nil
        }

        artist_id == "" ? recording.artists.removeAll() : addEntityFor(entity: .artist, found: foundArtists, recording: recording)
        label_id == "" ? recording.labels.removeAll() : addEntityFor(entity: .label, found: foundLabels, recording: recording)
        for genre in genres {
            genre.genre_id == "" ? recording.genres.removeAll() : addEntityFor(entity: .genre, found: foundGenres, recording: recording)
        }

        do {
            try AppDelegate.viewContext.save()
            if newRecording {
                
                var notifType: LocalNotif.NewReleaseType?
                if UserDefaults.standard.bool(forKey: Util.Keys.newRecordingFromArtistNotifKey)
                    && Util.getFollowedArtists().contains(artist_id) {
                    notifType = .followedArtist
                } else if UserDefaults.standard.bool(forKey: Util.Keys.newRecordingFromGenreNotifKey) {
                    notifType = .favoriteGenre
                }
                
                if let type = notifType {
                    LocalNotif.createNewReleaseAddedNotif(type: type, recording: recording) { (e) in
                        if let err = e {
                            print(err)
                        }
                    }
                }
                
            }
        } catch let error as NSError {
            print("ERROR - \(error)\n--\(error.userInfo)")
        }
    }
    
    /// Adds or updates a recording with its related entities
    ///
    /// - Parameters:
    ///   - entity: artist, genre, label
    ///   - found: array of found entitites matching the RecordingObj variables
    ///   - recording: recording to assign new or update previous entities
    func addEntityFor(entity: Util.entity, found: [RecordingInformation], recording: Recording) {
        switch entity {
        case .artist:
            let artists = found as! [Artist]
            if artists.count < 1 {
                let newEntities = createNewFor(entity: entity) as! [Artist]
                newEntities[0].recordings.insert(recording)
                recording.artists.insert(newEntities[0])
            } else if artists.count == 1 {
                artists[0].name = artist_name // update artist name
                recording.artists.insert(artists[0])
                artists[0].recordings.insert(recording)
            }
        case .genre:
            let genres = found as! [Genre]
            if genres.count < 1 {
                let newEntities = createNewFor(entity: entity) as! [Genre]
                for newGenre in newEntities {
                    newGenre.recordings.insert(recording)
                    recording.genres.insert(newGenre)
                }
            } else {
                for (index, genre) in self.genres.enumerated() {
                    // This is overriding == fix
                    genres[index].name = genre.genre_name
                    recording.genres.insert(genres[0])
                    genres[index].recordings.insert(recording)
                }
            }
        case .label:
            let labels = found as! [Label]
            if labels.count < 1 {
                let newEntities = createNewFor(entity: entity) as! [Label]
                newEntities[0].recordings.insert(recording)
                recording.labels.insert(newEntities[0])
            } else if labels.count == 1 {
                labels[0].name = label_name
                recording.labels.insert(labels[0])
                labels[0].recordings.insert(recording)
            }
        default:
            print("Warning: RecordingData.addEntityFor(...) does not support recording entities")
            print("No new entity added")
        }
    }
    
    func findMatchFor(entity: Util.entity) -> [RecordingInformation] {
        switch entity {
        case .recording:
            let request: NSFetchRequest<Recording> = Recording.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", recording_id)
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        case .artist:
            let request: NSFetchRequest<Artist> = Artist.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", artist_id)
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        case .genre:
            var foundGenres: [Genre] = []
            for genre in self.genres {
                let request: NSFetchRequest<Genre> = Genre.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", genre.genre_id)
                do {
                    let found = try AppDelegate.viewContext.fetch(request)
                    guard found.count > 0 else { return [] }
                    foundGenres += [found[0]]
                } catch {
                    return []
                }
            }
            return foundGenres
        default:
            let request: NSFetchRequest<Label> = Label.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", label_id)
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        }
    }
    
    func createNewFor(entity: Util.entity) -> [RecordingInformation] {
        switch entity {
        case .recording:
            let newEntity = NSEntityDescription.entity(forEntityName: "Recording", in: AppDelegate.viewContext)!
            let newRecording = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Recording
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            newRecording.id = recording_id
            newRecording.name = recording_name
            newRecording.release_date = recording_release_date != "" ? formatter.date(from: recording_release_date)! : nil
            return [newRecording]
        case .artist:
            let newEntity = NSEntityDescription.entity(forEntityName: "Artist", in: AppDelegate.viewContext)!
            let newArtist = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Artist
            newArtist.id = artist_id
            newArtist.name = artist_name
            return [newArtist]
        case .genre:
            var newGenres: [Genre] = []
            for genre in genres {
                let newEntity = NSEntityDescription.entity(forEntityName: "Genre", in: AppDelegate.viewContext)!
                let newGenre = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Genre
                newGenre.id = genre.genre_id
                newGenre.name = genre.genre_name
                newGenres.append(newGenre)
            }
            return newGenres
        default:
            let newEntity = NSEntityDescription.entity(forEntityName: "Label", in: AppDelegate.viewContext)!
            let newLabel = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Label
            newLabel.id = label_id
            newLabel.name = label_name
            return [newLabel]
        }
    }

}
