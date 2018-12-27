//
//  Recording+CoreDataProperties.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//
//

import Foundation
import CoreData


extension Recording {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording")
    }

    @NSManaged public var release_date: Date?
    @NSManaged public var artists: Set<Artist>
    @NSManaged public var labels: Set<Label>
    @NSManaged public var genres: Set<Genre>
    @NSManaged public var producers: Set<Producer>

}
