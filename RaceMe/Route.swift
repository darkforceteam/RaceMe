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
    var locations = [CLLocationCoordinate2D]()
    init(locationsData: FIRDataSnapshot){
        
        for loc in locationsData.children.allObjects as! [FIRDataSnapshot] {
            if let oneLoc = loc.value as? NSDictionary{
            let location = CLLocationCoordinate2D(latitude: oneLoc.value(forKey: Constants.Location.LATITUDE) as! CLLocationDegrees, longitude: oneLoc.value(forKey: Constants.Location.LONGTITUDE) as! CLLocationDegrees)
            locations.append(location)
            }
        }
        
        //        for loc in locations {
        //            print("CHILD VALUE ~~~~~~~~~")
        //            print(loc)
        //            let location = CLLocationCoordinate2D(latitude: loc.value [Constants.Location.LATTITUDE], longitude: loc[Constants.Location.LONGTITUDE])
        //            locations.append(location)
    }
    
    static func decodeRoute(routesData: FIRDataSnapshot) -> [Route]{
        var routes = [Route]()
        for child in routesData.children.allObjects as! [FIRDataSnapshot] {
            let route = Route(locationsData: child)
            routes.append(route)
        }
        return routes
    }
}
