//
//  Location.swift
//  RaceMe
//
//  Created by vulong.com on 3/21/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation

class Location: NSObject {
    var key: String
    var longitude: String
    var lattitude: String
    var speed: String
    var timestamp: String
    let ref: FIRDatabaseReference?
    
    init(longtitude: String, lattitude: String, speed: String, timestamp: String, key: String = "") {
        self.key = key
        self.longitude = longtitude
        self.lattitude = lattitude
        self.timestamp = timestamp
        self.speed = speed
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        longitude = snapshotValue[Constants.Location.LONGTITUDE] as! String
        lattitude = snapshotValue[Constants.Location.LATITUDE] as! String
        timestamp = snapshotValue[Constants.Location.TIMESTAMP] as! String
        speed = snapshotValue[Constants.Location.SPEED] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            Constants.Location.LONGTITUDE: longitude,
            Constants.Location.LATITUDE: lattitude,
            Constants.Location.TIMESTAMP: timestamp,
            Constants.Location.SPEED: speed
        ]
    }
    
    static func initArray(gpsLocs: [CLLocation]) -> [Location]{
        var locations = [Location]()
        for loc in gpsLocs {
            let location = Location(longtitude: "\(loc.coordinate.longitude)", lattitude: "\(loc.coordinate.latitude)", speed: String(loc.speed), timestamp: "\(loc.timestamp)")
            locations.append(location)
        }
        return locations
    }
}
