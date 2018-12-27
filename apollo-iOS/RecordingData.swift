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
    var producer_id: String
    var producer_name: String
    
    func save() {

        let recordings = findMatchFor(entity: .recording) as! [Recording]
        let artists = findMatchFor(entity: .artist) as! [Artist]
        let genres = findMatchFor(entity: .genre) as! [Genre]
        let labels = findMatchFor(entity: .label) as! [Label]
        let producers = findMatchFor(entity: .producer) as! [Producer]

        if recordings.count < 1 {
            // Recording not found -- create a new entity
            let newRecording = createNewFor(entity: .recording) as! Recording

            if artist_id != "" && artists.count < 1 {
                let newArtist = createNewFor(entity: .artist) as! Artist
                newArtist.recordings.insert(newRecording)
                newRecording.artists.insert(newArtist)
            } else if artist_id != "" && artists.count == 0 {
                artists[0].recordings.insert(newRecording)
                newRecording.artists.insert(artists[0])
            }
            
            if genre_id != "" && genres.count < 1 {
                let newGenre = createNewFor(entity: .genre) as! Genre
                newGenre.recordings.insert(newRecording)
                newRecording.genres.insert(newGenre)
            } else if genre_id != "" && genres.count == 0 {
                genres[0].recordings.insert(newRecording)
                newRecording.genres.insert(genres[0])
            }
        
            if label_id != "" && labels.count < 1 {
                let newLabel = createNewFor(entity: .label) as! Label
                newLabel.recordings.insert(newRecording)
                newRecording.labels.insert(newLabel)
            } else if label_id != "" && labels.count == 0 {
                labels[0].recordings.insert(newRecording)
                newRecording.labels.insert(labels[0])
            }
            
            if producer_id != "" && producers.count < 1 {
                let newProducer = createNewFor(entity: .producer) as! Producer
                newProducer.recordings.insert(newRecording)
                newRecording.producers.insert(newProducer)
            } else if producer_id != "" && producers.count == 0 {
                producers[0].recordings.insert(newRecording)
                newRecording.producers.insert(producers[0])
            }
            
            do {
                try AppDelegate.viewContext.save()
            } catch let error as NSError {
                print("ERROR - \(error)\n--\(error.userInfo)")
            }
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
        case .label:
            let request: NSFetchRequest<Label> = Label.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", label_id)
            do {
                let found = try AppDelegate.viewContext.fetch(request)
                return found
            } catch {
                return []
            }
        default:
            let request: NSFetchRequest<Producer> = Producer.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", producer_id)
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
        case .label:
            let newEntity = NSEntityDescription.entity(forEntityName: "Label", in: AppDelegate.viewContext)!
            let newLabel = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Label
            newLabel.id = label_id
            newLabel.name = label_name
            return newLabel
        default:
            let newEntity = NSEntityDescription.entity(forEntityName: "Producer", in: AppDelegate.viewContext)!
            let newProducer = NSManagedObject(entity: newEntity, insertInto: AppDelegate.viewContext) as! Producer
            newProducer.id = producer_id
            newProducer.name = producer_name
            return newProducer
        }
    }

}
