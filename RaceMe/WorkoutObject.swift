//
//  Workout.swift
//  RaceMe
//
//  Created by vulong.com on 3/21/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WorkoutObject: NSObject {
    var key: String
    var userId: String
    var type: String
    var startTime: Date
    var endTime: Date?
    var routeId: String
    var startLocation: Location?
    var endLocation: Location?
    var distanceKm = 0.0
    var distanceMi = 0.0
    var duration = 0.0
    let ref: FIRDatabaseReference?
    
    init(userId: String, type: String, startTime: Date, routeId: String, startLocation: Location?, key: String = "") {
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
        userId = snapshotValue[Constants.Workout.USER_ID] as! String
        type = snapshotValue[Constants.Workout.TYPE] as! String
        startTime = snapshotValue[Constants.Workout.START_TIME] as! Date
        routeId = snapshotValue[Constants.Workout.ROUTE_ID] as! String
        startLocation = snapshotValue[Constants.Workout.START_LOC] as? Location
        endTime = snapshotValue[Constants.Workout.END_TIME] as? Date
        endLocation = snapshotValue[Constants.Workout.END_LOC] as? Location
        distanceKm = (snapshotValue[Constants.Workout.DISTANCE_KM] as? Double)!
        distanceMi = (snapshotValue[Constants.Workout.DISTANCE_MI] as? Double)!
        duration = snapshotValue[Constants.Workout.DURATION] as! Double
        ref = snapshot.ref
    }
    
    func completed(endTime: Date, endLocation: Location?, distanceKm: Double, duration: Double){
        self.endTime = endTime
        self.endLocation = endLocation
        self.distanceKm = distanceKm
        self.distanceMi = distanceKm * Constants.UnitExchange.ONE_KM_IN_MILE
        self.duration = duration
    }
    
    func toAnyObject() -> Any {
        return [
            Constants.Workout.USER_ID: userId,
            Constants.Workout.TYPE : type,
            Constants.Workout.START_TIME : "\(startTime)",
            Constants.Workout.ROUTE_ID : routeId,
            //            "startLocation": startLocation!.toAnyObject(),
            Constants.Workout.END_TIME : "\(endTime!)",
            //            "endLocation": endLocation!.toAnyObject(),
            Constants.Workout.DISTANCE_KM : "\(distanceKm)",
            Constants.Workout.DISTANCE_MI : "\(distanceMi)",
            Constants.Workout.DURATION : "\(duration)"
        ]
    }
    
}
