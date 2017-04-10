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
    static let PUBLIC_GEOFIRE = "PUBLIC_GEOFIRE"
    struct PublicRoute{
        static let TABLE_NAME = "PUBLIC_ROUTES"
        static let ROUTE_DISTANCE = "DISTANCE"
        static let START_LOC = "START_LOC"
        static let END_LOC = "END_LOC"
    }
    struct Route{
        static let TABLE_NAME = "ROUTES"
        static let ROUTE_DISTANCE = "DISTANCE"
        static let START_LOC = "START_LOC"
        static let END_LOC = "END_LOC"
        static let IS_GLOBAL = "IS_GLOBAL"
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
    struct Event{
        static let TABLE_NAME = "EVENTS"
        static let PARTICIPANTS = "participants"
        static let ROUTE_ID = "route_id"
        static let START_LOC = "start_loc"
        static let START_TIME = "start_time"
        static let CREATED_BY = "created_by"
        static let TARGET_DISTANT = "target_distant"
    }
    
    struct Group {
        static let NAME = "name"
        static let DESCRIPTION = "description"
        static let CREATOR = "creator"
        static let BANNER = "banner"
    }

    struct FilterDay {
        static let ALL_TIME_DISPLAY = "All time"
        static let TODAY_DISPLAY = "Today"
        static let TOMORROW_DISPLAY = "Tomorrow"
        static let LATER_DISPLAY = "Later"
        static let ALL_TIME_VALUE = "0"
        static let TODAY_VALUE = "1"
        static let TOMORROW_VALUE = "2"
        static let LATER_VALUE = "3"
    }
    static let timeData: Dictionary = ["0":"All time","1":"Today","2":"Tomorrow","3":"Later"]
}
