//
//  Location.swift
//  RaceMe
//
//  Created by vulong.com on 3/21/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

struct Location {
    var key: String
    var latitude: Double
    var longitude: Double
    var speed: Double
    var timestamp: String
    var ref: FIRDatabaseReference?
    
    init(key: String = "", _ location: CLLocation) {
        self.key = key
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timestamp = "\(location.timestamp)"
        self.speed = location.speed
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
}
