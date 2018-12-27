//
//  Producer+CoreDataProperties.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//
//

import Foundation
import CoreData


extension Producer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Producer> {
        return NSFetchRequest<Producer>(entityName: "Producer")
    }

    @NSManaged public var recordings: Set<Recording>
    
}
