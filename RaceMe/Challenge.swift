//
//  Challenge.swift
//  RaceMe
//
//  Created by LVMBP on 4/10/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class Challenge: NSObject {
    var id: String?
    var created_by: String?
    var creator_name: String?
    var for_group: String?
    var start_date: Double?
    var end_date: Double?
    var total_wo_no: Int?
    var total_distant: Double?
    var total_long_wo_no: Int?
    var total_long_wo_dist: Double?
    var week_long_wo_no: Int?
    var week_long_wo_dist: Double?
    var week_wo_no: Int?
    var week_distant: Double?
    var min_wo_dist: Double?
    var min_wo_pace: Double?
    var chal_photo: String?
    var chalImg: UIImage?
    //    struct participants {
    //        static let participants = "participants"
    //        static let status = "status"
    //        static let qualified_wo = "qualified_wo"
    //        struct qualified_week {
    //            static let qualified_week = "qualified_week"
    //            static let week_status = "week_status"
    //            static let week_start = "start_date"
    //            static let week_end = "end_date"
    //            static let week_wo_no = "total_wo"
    //            static let week_dist = "total_distant"
    //            static let long_wo_no = "long_wo_no"
    //            static let long_wo_dist = "long_wo_dist"
    //        }
    //        struct chal_status {
    //            static let result = "chal_result"
    //            static let total_dist = "total_distant"
    //            static let total_wo = "total_wo"
    //            static let total_qualified_week = "total_qualified_week"
    //        }
    //    }
    init(snapshot: FIRDataSnapshot) {
        //        ref = snapshot.ref
        id = snapshot.ref.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        created_by = snapshotValue[Constants.Challenge.created_by]  as? String
        chal_photo = snapshotValue[Constants.Challenge.chal_photo]  as? String
        for_group = snapshotValue[Constants.Challenge.for_group]  as? String
        start_date = snapshotValue[Constants.Challenge.start_date] as? Double
        end_date = snapshotValue[Constants.Challenge.end_date] as? Double
        total_wo_no = snapshotValue[Constants.Challenge.total_wo_no] as? Int
        total_distant = snapshotValue[Constants.Challenge.total_distant] as? Double
        week_wo_no = snapshotValue[Constants.Challenge.week_wo_no] as? Int
        week_distant = snapshotValue[Constants.Challenge.week_distant] as? Double
        min_wo_dist = snapshotValue[Constants.Challenge.min_wo_dist] as? Double
        min_wo_pace = snapshotValue[Constants.Challenge.min_wo_pace] as? Double
        week_long_wo_no = snapshotValue[Constants.Challenge.week_long_wo_no] as? Int
        week_long_wo_dist = snapshotValue[Constants.Challenge.week_long_wo_dist] as? Double
        total_long_wo_no = snapshotValue[Constants.Challenge.total_long_wo_no] as? Int
        total_long_wo_dist = snapshotValue[Constants.Challenge.total_long_wo_dist] as? Double
    }
    
    func toAnyObject() -> Any {
        return [
            //            Constants.Workout.USER_ID: userId,
            //            Constants.Workout.TYPE : type,
            //            Constants.Workout.START_TIME : startTime,
            //            Constants.Workout.ROUTE_ID : routeId,
            //            Constants.Workout.END_TIME : endTime,
            //            Constants.Workout.DISTANCE_KM : distanceKm,
            //            Constants.Workout.DISTANCE_MI : distanceMi,
            //            Constants.Workout.DURATION : duration,
            //            "isPublic": isPublic
        ]
    }
}
