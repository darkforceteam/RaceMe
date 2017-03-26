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
    init(locationsData: FIRDataSnapshot){
        print("initializing Route")
        var locCount = 0
        for loc in locationsData.children.allObjects as! [FIRDataSnapshot] {
            
            if let oneLoc = loc.value as? NSDictionary{
                let location = CLLocationCoordinate2D(latitude: oneLoc.value(forKey: Constants.Location.LATITUDE) as! CLLocationDegrees, longitude: oneLoc.value(forKey: Constants.Location.LONGTITUDE) as! CLLocationDegrees)
                locations.append(location)
                locCount += 1
            } else {
                if loc.key == "DISTANCE" {
                    distance = loc.value as! String
                } else if loc.key == "PUBLIC" {
                    isPublic = true
                } else {
                    
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
