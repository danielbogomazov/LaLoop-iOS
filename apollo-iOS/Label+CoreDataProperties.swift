//
//  Label+CoreDataProperties.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//
//

import Foundation
import CoreData


extension Label {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Label> {
        return NSFetchRequest<Label>(entityName: "Label")
    }

    @NSManaged public var recordings: Set<Recording>

}
