//
//  ArtistData.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-10.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation
import CoreData

struct ArtistData: Decodable {
    var artists: [ArtistObj]
}

struct ArtistObj: Decodable {
    var artist_id: String
    var artist_name: String
    var genres: [GenreObj]
    
    mutating func save() {
        
        artist_name = Util.replaceCharEntitites(string: artist_name)
        for var genre in genres {
            genre.genre_name = Util.replaceCharEntitites(string: genre.genre_name)
        }
        
        let foundArtists = findMatchFor(entity: .artist) as! [Artist]
        let foundGenres = findMatchFor(entity: .genre) as! [Genre]
        
        foundArtists[0].genres.removeAll() // Easy way of removing removed genres
        for genre in foundGenres {
            foundArtists[0].genres.insert(genre)
        }
        
        do {
            try AppDelegate.viewContext.save()
        } catch let error as NSError {
            print("ERROR - \(error)\n--\(error.userInfo)")
        }
    }
    
    func findMatchFor(entity: Util.entity) -> [RecordingInformation] {
        switch entity {
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
            print("Warning: ArtistData.findMatchFor(...) does not support non-artist and non-genre entities")
            return []
        }
    }
}
