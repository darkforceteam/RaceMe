//
//  Workout.swift
//  RaceMe
//
//  Created by vulong.com on 3/21/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

struct Workout {
    var key: String
    var userId: String
    var type: String
    var startTime: String?
    var endTime: String?
    var routeId: String?
    var distanceKm: Double?
    var distanceMi: Double?
    var duration: Int?
    var isPublic = true
    var ref: FIRDatabaseReference?
    
    init(key: String = "", type: String = "RUN", _ user: User, _ routeId: String, _ locations: [CLLocation], _ distance: Double, _ duration: Int) {
        self.key = key
        self.type = type
        self.userId = user.uid
        self.routeId = routeId
        self.distanceKm = distance / 1000
        self.distanceMi = distanceKm! * Constants.UnitExchange.ONE_KM_IN_MILE
        self.duration = duration
        self.ref = nil
        
        if let startTime = locations.first?.timestamp, let endTime = locations.last?.timestamp {
            self.startTime = "\(startTime)"
            self.endTime = "\(endTime)"
        }
    }
    
    init(key: String = "", type: String = "RUN", _ user: User, _ distance: Double, _ duration: Int, _ isPublic: Bool) {
        self.key = key
        self.type = type
        self.userId = user.uid
        self.distanceKm = distance / 1000
        self.distanceMi = distanceKm! * Constants.UnitExchange.ONE_KM_IN_MILE
        self.duration = duration
        self.isPublic = isPublic
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        userId = snapshotValue[Constants.Workout.USER_ID] as! String
        type = snapshotValue[Constants.Workout.TYPE] as! String
        startTime = snapshotValue[Constants.Workout.START_TIME]  as? String
        routeId = snapshotValue[Constants.Workout.ROUTE_ID] as? String
        endTime = snapshotValue[Constants.Workout.END_TIME] as? String
        distanceKm = snapshotValue[Constants.Workout.DISTANCE_KM] as? Double
        distanceMi = snapshotValue[Constants.Workout.DISTANCE_MI] as? Double
        duration = snapshotValue[Constants.Workout.DURATION] as? Int
        //isPublic = snapshotValue["isPublic"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            Constants.Workout.USER_ID: userId,
            Constants.Workout.TYPE : type,
            Constants.Workout.START_TIME : startTime,
            Constants.Workout.ROUTE_ID : routeId,
            Constants.Workout.END_TIME : endTime,
            Constants.Workout.DISTANCE_KM : distanceKm,
            Constants.Workout.DISTANCE_MI : distanceMi,
            Constants.Workout.DURATION : duration,
            "isPublic": isPublic
        ]
    }
}
