//
//  Location+CoreDataClass.swift
//  MyLocation
//
//  Created by Phi Hoang Huy on 12/21/18.
//  Copyright © 2018 Phi Hoang Huy. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation
import MapKit
@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lattitude, longtitude)
    }
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    public var subtitle: String? {
        return category
    }
    var hasPhoto: Bool {
        return photoID != nil
    }
    var photoURL: URL {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
}
