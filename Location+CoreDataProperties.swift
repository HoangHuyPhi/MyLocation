//
//  Location+CoreDataProperties.swift
//  MyLocation
//
//  Created by Phi Hoang Huy on 12/21/18.
//  Copyright © 2018 Phi Hoang Huy. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var lattitude: Double
    @NSManaged public var longtitude: Double
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var locationDescription: String
    @NSManaged public var date: Date
    @NSManaged public var photoID: NSNumber?
}
