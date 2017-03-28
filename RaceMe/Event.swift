//
//  Event.swift
//  RaceMe
//
//  Created by LVMBP on 3/27/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class Event: NSObject {
    var start_time: Date
    var route_id: String
    var participants = [String]()
    init(route_id: String, start_time: Date){
        self.start_time = start_time
        self.route_id = route_id
    }
    
}
