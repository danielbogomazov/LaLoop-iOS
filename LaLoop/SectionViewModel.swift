//
//  SectionViewModel.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-02.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation

struct SectionViewModel {
    
    private let section: Section
    var title: String = ""
    var detail: String? = nil
    var isOn: Bool = false
    
    init(section: Section) {
        self.section = section
        update()
    }
    
    mutating func update() {
        title = section.title
        detail = section.detail
        switch section.title {
        case Util.Strings.followedRecordings:
            isOn = UserDefaults.standard.bool(forKey: Util.Keys.followRecordingsNotifKey)
        case Util.Strings.newRecordingsFromFollowedArtists:
            isOn = UserDefaults.standard.bool(forKey: Util.Keys.newRecordingFromArtistNotifKey)
        case Util.Strings.newRecordingsFromFavoriteGenres:
            isOn = UserDefaults.standard.bool(forKey: Util.Keys.newRecordingFromGenreNotifKey)
        case Util.Genres.avant_garde:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.avant_garde)
        case Util.Genres.blues:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.blues)
        case Util.Genres.caribbean:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.caribbean)
        case Util.Genres.childrens:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.childrens)
        case Util.Genres.classical:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.classical)
        case Util.Genres.comedy:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.comedy)
        case Util.Genres.country:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.country)
        case Util.Genres.electronic:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.electronic)
        case Util.Genres.experimental:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.experimental)
        case Util.Genres.folk:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.folk)
        case Util.Genres.hip_hop:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.hip_hop)
        case Util.Genres.jazz:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.jazz)
        case Util.Genres.latin:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.latin)
        case Util.Genres.pop:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.pop)
        case Util.Genres.rnb_and_soul:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.rnb_and_soul)
        case Util.Genres.rock:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.rock)
        case Util.Genres.worship:
            isOn = UserDefaults.standard.bool(forKey: Util.Genres.worship)
        default:
            isOn = false
        }
    }
}
