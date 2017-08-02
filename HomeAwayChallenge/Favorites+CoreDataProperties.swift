//
//  Favorites+CoreDataProperties.swift
//  HomeAwayChallenge
//
//  Created by rtackett on 8/1/17.
//  Copyright © 2017 RICHARD TACKETT. All rights reserved.
//

import Foundation
import CoreData


extension Favorites {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorites> {
        return NSFetchRequest<Favorites>(entityName: "Favorites")
    }

    @NSManaged public var eventID: Int64

}
