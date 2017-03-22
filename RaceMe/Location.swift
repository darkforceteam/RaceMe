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
    var longtitude: String
    var lattitude: String
    var speed: String
    var timestamp: String
    let ref: FIRDatabaseReference?
    
    init(longtitude: String, lattitude: String, speed: String, timestamp: String, key: String = "") {
        self.key = key
        self.longtitude = longtitude
        self.lattitude = lattitude
        self.timestamp = timestamp
        self.speed = speed
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        longtitude = snapshotValue["longtitude"] as! String
        lattitude = snapshotValue["lattitude"] as! String
        timestamp = snapshotValue["timestamp"] as! String
        speed = snapshotValue["speed"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "longtitude": longtitude,
            "lattitude": lattitude,
            "timestamp": timestamp,
            "speed": speed
        ]
    }
    
    static func initArray(gpsLocs: [CLLocation]) -> [Location]{
        var locations = [Location]()
        for loc in gpsLocs {
            let location = Location(longtitude: String(loc.coordinate.longitude), lattitude: String(loc.coordinate.longitude), speed: String(loc.speed), timestamp: "\(loc.timestamp)")
            locations.append(location)
        }
        return locations
    }
}
