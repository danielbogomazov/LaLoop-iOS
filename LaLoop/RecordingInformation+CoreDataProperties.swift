//
//  RecordingInformation+CoreDataProperties.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//
//

import Foundation
import CoreData


extension RecordingInformation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordingInformation> {
        return NSFetchRequest<RecordingInformation>(entityName: "RecordingInformation")
    }

    @NSManaged public var id: String!
    @NSManaged public var name: String!

}
