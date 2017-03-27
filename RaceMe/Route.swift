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
    //    var startLoc: CLLocationCoordinate2D
    init(locationsData: FIRDataSnapshot){
        print("initializing Route")
        var locCount = 0
        for loc in locationsData.children.allObjects as! [FIRDataSnapshot] {
            
            if let oneLoc = loc.value as? NSDictionary{
                if let latValue = oneLoc.value(forKey: Constants.Location.LATITUDE) as! Double? {
                let location = CLLocationCoordinate2D(latitude: latValue as! CLLocationDegrees, longitude: oneLoc.value(forKey: Constants.Location.LONGTITUDE) as! CLLocationDegrees)
                locations.append(location)
                locCount += 1
                } else {
                    //LONG TODO handle GeoFire Data
                }
            } else {
                if let key = loc.key as String? {
                    if key == "DISTANCE" {
                        distance = "\(loc.value)"
                    } else if key == "PUBLIC" {
                        isPublic = true
                    } else {
                        //                        geoFire.getLocationForKey("firebase-hq", withCallback: { (startLoc, error) in
                        //                            if (error != nil) {
                        //                                println("An error occurred getting the location for \"firebase-hq\": \(error.localizedDescription)")
                        //                            } else if (location != nil) {
                        //                                println("Location for \"firebase-hq\" is [\(location.coordinate.latitude), \(location.coordinate.longitude)]")
                        //                            } else {
                        //                                println("GeoFire does not contain a location for \"firebase-hq\"")
                        //                            }
                        //                        })
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
