//
//  RecordingViewModel.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2019-04-27.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation
import UIKit

struct RecordingViewModel {
    
    private let recording: Recording
    var artistName = "Unknown Artist"
    var recordingName = "TBA"
    var releaseDate = "TBA"
    var isFollowed = false
    var backgroundColor = UIColor.clear
    var recordingID = ""
    var followingImage = #imageLiteral(resourceName: "NotFollowed")

    
    init(recording: Recording) {
        self.recording = recording
        recordingID = recording.id
        update()
    }
    
    mutating func update() {     
        artistName = recording.artists.first?.name ?? "Unknown Artist"
        recordingName = recording.name != "" ? recording.name : "TBA"
        
        if let date = recording.release_date {
            let formatter = DateFormatter()
            if Util.isTBA(date: date) {
                let newDate = Calendar.current.date(byAdding: .year, value: -1999, to: date)
                formatter.dateFormat = "MMMM YYYY"
                releaseDate = formatter.string(from: newDate ?? date)
            } else {
                formatter.dateFormat = "MMMM dd YYYY"
                releaseDate = formatter.string(from: date) == formatter.string(from: Date()) ? "Releasing Today" : formatter.string(from: date)
            }
        } else {
            releaseDate = "TBA"
        }

        isFollowed = Util.getFollowedRecordings().contains(recording.id)
        followingImage = isFollowed ? #imageLiteral(resourceName: "Followed") : #imageLiteral(resourceName: "NotFollowed")
        backgroundColor = releaseDate == "Releasing Today" && isFollowed ? Util.Color.main.withAlphaComponent(0.2) : UIColor.clear
    }
    
    mutating func changeFollowingStatus() {
        let followedRecordings = Util.getFollowedRecordings()
        followedRecordings.contains(recording.id) ? Util.unfollowRecording(id: recording.id) : Util.followRecording(recording: recording)

        update()
    }
}
