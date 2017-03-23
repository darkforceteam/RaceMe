//
//  Run.swift
//  RaceMe
//
//  Created by Duc Pham Viet on 3/23/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import Foundation
import Firebase

struct Run {
    
    let key: String
    let distance: Double
    let duration: Int
    let timestamp: String
    let addedByUser: String
    let ref: FIRDatabaseReference?
    
    init(key: String = "", distance: Double, duration: Int, timestamp: String, addedByUser: String) {
        self.key = key
        self.distance = distance
        self.duration = duration
        self.timestamp = timestamp
        self.addedByUser = addedByUser
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        distance = snapshotValue["distance"] as! Double
        duration = snapshotValue["duration"] as! Int
        timestamp = snapshotValue["timestamp"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return ["distance": distance, "duration": duration, "timestamp": timestamp, "addedByUser": addedByUser]
    }
}
