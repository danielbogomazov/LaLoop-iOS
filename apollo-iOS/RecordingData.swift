//
//  RecordingData.swift
//  apollo-iOS
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
    var genre_id: String
    var genre_name: String
    var label_id: String
    var label_name: String
    
    mutating func save() {

        recording_name = Util.replaceCharEntitites(string: recording_name)
        artist_name = Util.replaceCharEntitites(string: artist_name)
        genre_name = Util.replaceCharEntitites(string: genre_name)
        label_name = Util.replaceCharEntitites(string: label_name)

        let recordings = findMatchFor(entity: .recording) as! [Recording]
        let artists = findMatchFor(entity: .artist) as! [Artist]
        let genres = findMatchFor(entity: .genre) as! [Genre]
        let labels = findMatchFor(entity: .label) as! [Label]
        
        var recording: Recording!
        
        if recordings.count < 1 {
            recording = (createNewFor(entity: .recording) as! Recording)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            recording = recordings[0]
            recording.name = recording_name
            recording.release_date = recording_release_date != "" ? formatter.date(from: recording_release_date)! : nil
        }

        artist_id == "" ? recording.artists.removeAll() : addEntityFor(entity: .artist, found: artists, recording: recording)
        genre_id == "" ? recording.genres.removeAll() : addEntityFor(entity: .genre, found: genres, recording: recording)
        label_id == "" ? recording.labels.removeAll() : addEntityFor(entity: .label, found: labels, recording: recording)

        do {
            try AppDelegate.viewContext.save()
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
                let newEntity = createNewFor(entity: entity) as! Artist
                newEntity.recordings.insert(recording)
                recording.artists.insert(newEntity)
            } else if artists.count == 1 && recording.artists.contains(where: { (artist) -> Bool in return artist.id == artist_id }) {
                artists[0].name = artist_name
                recording.artists.insert(artists[0])
                artists[0].recordings.insert(recording)
            }
        case .genre:
            let genres = found as! [Genre]
            if genres.count < 1 {
                let newEntity = createNewFor(entity: entity) as! Genre
                newEntity.recordings.insert(recording)
                recording.genres.insert(newEntity)
            } else if genres.count == 1 && recording.genres.contains(where: { (genre) -> Bool in return genre.id == genre_id }) {
                genres[0].name = genre_name
                recording.genres.insert(genres[0])
                genres[0].recordings.insert(recording)
            }
        case .label:
            let labels = found as! [Label]
            if labels.count < 1 {
                let newEntity = createNewFor(entity: entity) as! Label
                newEntity.recordings.insert(recording)
                recording.labels.insert(newEntity)
            } else if labels.count == 1 && recording.labels.contains(where: { (label) -> Bool in return label.id == label_id }) {
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
            let request: NSFetchRequest<Genre> = Genre.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", genre_id)
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
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
    
    func createNewFor(entity: Util.entity) -> RecordingInformation {
        switch entity {
        case .recording:
            let newEntity = NSEntityDescription.entity(forEntityName: "Recording", in: AppDelegate.viewContext)!
            let newRecording = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Recording
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            newRecording.id = recording_id
            newRecording.name = recording_name
            newRecording.release_date = recording_release_date != "" ? formatter.date(from: recording_release_date)! : nil
            return newRecording
        case .artist:
            let newEntity = NSEntityDescription.entity(forEntityName: "Artist", in: AppDelegate.viewContext)!
            let newArtist = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Artist
            newArtist.id = artist_id
            newArtist.name = artist_name
            return newArtist
        case .genre:
            let newEntity = NSEntityDescription.entity(forEntityName: "Genre", in: AppDelegate.viewContext)!
            let newGenre = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Genre
            newGenre.id = genre_id
            newGenre.name = genre_name
            return newGenre
        default:
            let newEntity = NSEntityDescription.entity(forEntityName: "Label", in: AppDelegate.viewContext)!
            let newLabel = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Label
            newLabel.id = label_id
            newLabel.name = label_name
            return newLabel
        }
    }

}
