//
//  ArtistViewModel.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-04-27.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation
import UIKit

struct ArtistViewModel {
    
    private let artist: Artist!
    var isExpanded = false
    var artistName = "Unknown Artist"
    var numRecordingsFollowed = "Unknown number of followed upcoming recordings"
    var expandImage = #imageLiteral(resourceName: "ArrowClosed")
    
    init(artist: Artist) {
        self.artist = artist
        update()
    }
    
    mutating func update() {

        expandImage = isExpanded ? #imageLiteral(resourceName: "ArrowOpen") : #imageLiteral(resourceName: "ArrowClosed")
        artistName = artist.name
        
        let followedRecordings = Util.getFollowedRecordings()
        var numRecordings = 0
        for recording in artist.recordings {
            if followedRecordings.contains(recording.id) {
                numRecordings += 1
            }
        }
        numRecordingsFollowed = "\(numRecordings) followed upcoming recording" + (numRecordings > 1 ? "s" : "")
    }
    
    mutating func changeExpandedState() {
        isExpanded = !isExpanded
        update()
    }

}
