//
//  Route.swift
//  RaceMe
//
//  Created by LVMBP on 3/24/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
class Route: NSObject {
    var distance: String = ""
    var locations = [CLLocationCoordinate2D]()
    var isPublic = false
    var events = [Event]()
    var todayEvents = [Event]()
    var tomorrowEvents = [Event]()
    var laterEvents = [Event]()
    //    var startLoc: CLLocationCoordinate2D
    func title(displayingDate: String) -> String {
        switch displayingDate {
        case "0":
            return "\(self.distance) km"
        case "1":
            return "\(self.todayEvents.first?.participants.count) runners"
        case "2":
            return "\(self.tomorrowEvents.first?.participants.count) runners"
        default:
            return "\(self.laterEvents.first?.participants.count) runners"
        }
    }
    init(locationsData: FIRDataSnapshot){
        print("initializing Route")
        var locCount = 0
        for loc in locationsData.children.allObjects as! [FIRDataSnapshot] {
            
            if let oneLoc = loc.value as? NSDictionary{
                if let latValue = oneLoc.value(forKey: Constants.Location.LATITUDE) as! Double? {
                let location = CLLocationCoordinate2D(latitude: latValue , longitude: oneLoc.value(forKey: Constants.Location.LONGTITUDE) as! CLLocationDegrees)
                locations.append(location)
                locCount += 1
                } else {
                    //LONG TODO handle GeoFire Data
                    //no need. Moved GeoFire marking to global
                }
            } else {
                if let key = loc.key as String? {
                    if key == "DISTANCE" {
                        distance = "\(loc.value)"
                    } else if key == "PUBLIC" {
                        isPublic = true
                    } else {

                    }
                }
            }
        }
        print("Route has \(locCount) locs")
        //        for loc in locations {
        //            print("CHILD VALUE ~~~~~~~~~")
        //            print(loc)
        //            let location = CLLocationCoordinate2D(latitude: loc.value [Constants.Location.LATTITUDE], longitude: loc[Constants.Location.LONGTITUDE])
        //            locations.append(location)
    }
    
    static func decodeRoutes(routesData: FIRDataSnapshot) -> [Route]{
        var routes = [Route]()
        var i = 0
        for child in routesData.children.allObjects as! [FIRDataSnapshot] {
            let route = Route(locationsData: child)
            if route.locations.count > 0 {
                routes.append(route)
                i+=1
                print("added route number: \(i)")
            }
        }
        return routes
    }
}
