//
//  Constants.swift
//  RaceMe
//
//  Created by vulong.com on 3/21/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

struct Constants {
    // Global variables
    static let GEOFIRE = "GEOFIRE"
    struct UnitExchange {
        static let ONE_KM_IN_MILE = 0.621371
    }
    struct Route{
        static let TABLE_NAME = "ROUTES"
        static let ROUTE_DISTANCE = "DISTANCE"
        static let START_LOC = "START_LOC"
        static let END_LOC = "END_LOC"
    }
    struct Workout{
        static let TABLE_NAME = "WORKOUTS"
        static let DISTANCE_KM = "distance_km"
        static let DISTANCE_MI = "distance_mi"
        static let USER_ID = "user_id"
        static let TYPE = "type"
        static let START_TIME = "start_time"
        static let ROUTE_ID = "route_id"
        static let START_LOC = "start_location"
        static let END_TIME = "end_time"
        static let END_LOC = "end_location"
        static let DURATION = "duration"
    }
    struct Location{
        static let LONGTITUDE = "longtitude"
        static let LATITUDE = "latitude"
        static let TIMESTAMP = "timestamp"
        static let SPEED = "speed"
    }
}
