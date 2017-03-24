//
//  Location.swift
//  RaceMe
//
//  Created by vulong.com on 3/21/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import Foundation
import Firebase

struct Location {
    let key: String
    let latitude: Double
    let longitude: Double
    let speed: Double
    let timestamp: String
    let ref: FIRDatabaseReference?
    
    init(key: String = "", latitude: Double, longitude: Double, timestamp: String, speed: Double) {
        self.key = key
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.speed = speed
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        longitude = snapshotValue[Constants.Location.LONGTITUDE] as! Double
        latitude = snapshotValue[Constants.Location.LATITUDE] as! Double
        timestamp = snapshotValue[Constants.Location.TIMESTAMP] as! String
        speed = snapshotValue[Constants.Location.SPEED] as! Double
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            Constants.Location.LONGTITUDE: longitude,
            Constants.Location.LATITUDE: latitude,
            Constants.Location.TIMESTAMP: timestamp,
            Constants.Location.SPEED: speed
        ]
    }
    
//    static func initArray(gpsLocs: [CLLocation]) -> [Location]{
//        var locations = [Location]()
//        for loc in gpsLocs {
//            let location = Location(longtitude: String(loc.coordinate.longitude), latitude: String(loc.coordinate.longitude), speed: String(loc.speed), timestamp: "\(loc.timestamp)")
//            locations.append(location)
//        }
//        return locations
//    }
}
