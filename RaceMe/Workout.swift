//
//  Workout.swift
//  RaceMe
//
//  Created by LVMBP on 3/21/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Workout: NSObject {
    var key: String
    var userId: String
    var type: String
    var startTime: String
    var endTime: String?
    var routeId: String
    var startLocation: Location?
    var endLocation: Location?
    var distanceKm = 0.0
    var distanceMi = 0.0
    var duration = 0.0
    let ref: FIRDatabaseReference?
    
    init(userId: String, type: String, startTime: String, routeId: String, startLocation: Location?, key: String = "") {
        self.key = key
        self.userId = userId
        self.type = type
        self.startTime = startTime
        self.routeId = routeId
        self.startLocation = startLocation
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        userId = snapshotValue["userId"] as! String
        type = snapshotValue["type"] as! String
        startTime = snapshotValue["startTime"] as! String
        routeId = snapshotValue["routeId"] as! String
        startLocation = snapshotValue["startLocation"] as? Location
        endTime = snapshotValue["endTime"] as? String
        endLocation = snapshotValue["endLocation"] as? Location
        distanceKm = (snapshotValue["distanceKm"] as? Double)!
        distanceMi = (snapshotValue["distanceMi"] as? Double)!
        duration = (snapshotValue["duration"] as? Double)!
        ref = snapshot.ref
    }
    
    func completed(endTime: String, endLocation: Location?, distanceKm: Double, duration: Double){
        self.endTime = endTime
        self.endLocation = endLocation
        self.distanceKm = distanceKm
        self.distanceMi = distanceKm * Constants.UnitExchange.ONE_KM_IN_MILE
        self.duration = duration
    }
    
    func toAnyObject() -> Any {
        return [
            "userId": userId,
            "type": type,
            "startTime": startTime,
            "routeId": routeId,
//            "startLocation": startLocation!.toAnyObject(),
            "endTime": endTime!,
//            "endLocation": endLocation!.toAnyObject(),
            "distanceKm": "\(distanceKm)",
            "distanceMi": "\(distanceMi)",
            "duration": "\(duration)"
        ]
    }

}
