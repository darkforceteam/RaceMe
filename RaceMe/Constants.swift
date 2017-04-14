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
        static let NAME = "NAME"
        static let TYPE = "TYPE"
        static let ADDR = "ADDR"
        static let BANNER = "BANNER"
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
        static let ELAPSED = "elapsed"
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
        static let TABLE_NAME = "GROUPS"
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
    struct USERS{
        static let table_name = "USERS"
        static let display_name = "displayName"
        static let bio = "bio"
        static let photoUrl = "photoUrl"
    }
    struct Challenge{
        static let table_name = "challenges"
        static let description = "description"
        static let challenge_name = "name"
        static let chal_photo = "photo"
        static let created_by = "created_by"
        static let for_group = "for_group"
        static let start_date = "start_date"
        static let end_date = "end_date"
        static let total_wo_no = "total_wo_no"
        static let total_distant = "total_distant"
        static let week_wo_no = "week_wo_no"
        static let week_distant = "week_distant"
        static let min_wo_dist = "min_wo_dist"
        static let min_wo_pace = "min_wo_pace"
        static let total_long_wo_no = "total_long_wo_no"
        static let total_long_wo_dist = "total_long_wo_dist"
        static let week_long_wo_no = "week_long_wo_no"
        static let week_long_wo_dist = "week_long_wo_dist"
        struct participants {
            static let participants = "participants"
            static let status = "status"
            static let qualified_wo = "qualified_wo"
            struct qualified_week {
                static let qualified_week = "qualified_week"
                static let week_status = "week_status"
                static let week_start = "start_date"
                static let week_end = "end_date"
                static let week_wo_no = "total_wo"
                static let week_dist = "total_distant"
                static let long_wo_no = "long_wo_no"
                static let long_wo_dist = "long_wo_dist"
            }
            struct chal_status {
                static let result = "chal_result"
                static let total_dist = "total_distant"
                static let total_wo = "total_wo"
                static let total_qualified_week = "total_qualified_week"
            }
        }
    }
    struct STORAGE {
        static let CHALLENGE = "CHALLENGES"
    }
    static let localImageChallenge = "resources/images/challenges"
    static let timeData: Dictionary = ["0":"All time","1":"Today","2":"Tomorrow","3":"Later"]
    struct SPORT_TYPE {
        static let ALL = "All sport"
        static let RUN = "run"
        static let SWIM = "swim"
        static let YOGA = "yoga"
    }
}
