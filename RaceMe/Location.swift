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
    var elapsed: Int
    var ref: FIRDatabaseReference?
    
    init(key: String = "", _ location: CLLocation, _ fromDate: Date, _ toDate: Date) {
        self.key = key
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timestamp = "\(location.timestamp)"
        self.speed = location.speed
        self.elapsed = toDate.seconds(from: fromDate)
        self.ref = nil
    }
    
    init(longtitude: Double, lattitude: Double, speed: Double, timestamp: String, key: String = "", elapsed: Int = 0) {
        self.key = key
        self.longitude = longtitude
        self.latitude = lattitude
        self.timestamp = timestamp
        self.speed = speed
        self.ref = nil
        self.elapsed = elapsed
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        longitude = snapshotValue[Constants.Location.LONGTITUDE] as! Double
        latitude = snapshotValue[Constants.Location.LATITUDE] as! Double
        timestamp = snapshotValue[Constants.Location.TIMESTAMP] as! String
        speed = snapshotValue[Constants.Location.SPEED] as! Double
        elapsed = snapshotValue[Constants.Location.ELAPSED] as! Int
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            Constants.Location.LONGTITUDE: longitude,
            Constants.Location.LATITUDE: latitude,
            Constants.Location.TIMESTAMP: timestamp,
            Constants.Location.SPEED: speed,
            Constants.Location.ELAPSED: elapsed
        ]
    }
    
    static func initArray(gpsLocs: [CLLocation]) -> [Location]{
        var locations = [Location]()
        for loc in gpsLocs {
            let location = Location(longtitude: loc.coordinate.longitude, lattitude: loc.coordinate.latitude, speed: loc.speed, timestamp: "\(loc.timestamp)")
            locations.append(location)
        }
        return locations
    }
}
