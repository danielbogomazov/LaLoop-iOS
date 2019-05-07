//
//  GenreData.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-02.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation
import CoreData

struct GenreObj: Decodable {
    var genre_name: String
    var genre_id: String
}

struct GenreData: Decodable {
    var avant_garde: [GenreObj]
    var blues: [GenreObj]
    var caribbean: [GenreObj]
    var childrens: [GenreObj]
    var classical: [GenreObj]
    var comedy: [GenreObj]
    var country: [GenreObj]
    var electronic: [GenreObj]
    var experimental: [GenreObj]
    var folk: [GenreObj]
    var hip_hop: [GenreObj]
    var jazz: [GenreObj]
    var latin: [GenreObj]
    var pop: [GenreObj]
    var rnb_and_soul: [GenreObj]
    var rock: [GenreObj]
    var worship: [GenreObj]
    
    mutating func save() {
        AppDelegate.avant_garde_subgenres = avant_garde.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.blues_subgenres = blues.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.caribbean_subgenres = caribbean.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.childrens_subgenres = childrens.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.classical_subgenres = classical.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.comedy_subgenres = comedy.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.country_subgenres = country.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.electronic_subgenres = electronic.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.experimental_subgenres = experimental.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.folk_subgenres = folk.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.hip_hop_subgenres = hip_hop.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.jazz_subgenres = jazz.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.latin_subgenres = latin.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.pop_subgenres = pop.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.rnb_and_soul_subgenres = rnb_and_soul.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.rock_subgenres = rock.map { return Util.replaceCharEntitites(string: $0.genre_name) }
        AppDelegate.worship_subgenres = worship.map { return Util.replaceCharEntitites(string: $0.genre_name) }
    }
}
