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
    var displayEvent: Event?
    var routeId: String!
    func participant_count(displayingDate: String) -> Int {
        switch displayingDate {
        case "0":
            return 0
        case "1":
            return (self.todayEvents.first?.participants.count)!
        case "2":
            return (self.tomorrowEvents.first?.participants.count)!
        case "3":
            return (self.laterEvents.first?.participants.count)!
        default:
            return 0
        }
    }
    func setFirstEvent(){
        if todayEvents.count > 0 {
            displayEvent = todayEvents[0] as Event
            print("First Event is at \(displayEvent?.start_time)")
        } else if tomorrowEvents.count > 0 {
            displayEvent = tomorrowEvents[0] as Event
            print("First Event is at \(displayEvent?.start_time)")
        } else if laterEvents.count > 0 {
            displayEvent = laterEvents[0] as Event
            print("First Event is at \(displayEvent?.start_time)")
        } else {
            displayEvent = nil
            print("NO EVENT FOUND")
        }
    }
    
    init(locationsData: FIRDataSnapshot){
        print("initializing Route")
        var locCount = 0
        for loc in locationsData.children.allObjects as! [FIRDataSnapshot] {
            
            if let oneLoc = loc.value as? NSDictionary{
                if let latValue = oneLoc.value(forKey: Constants.Location.LATITUDE) as! Double? {
                    let longVal = oneLoc.value(forKey: Constants.Location.LONGTITUDE) as! Double?
                let location = CLLocationCoordinate2D(latitude: latValue , longitude: longVal!)
                locations.append(location)
                locCount += 1
                } else {
                    //LONG TODO handle GeoFire Data
                    //no need. Moved GeoFire marking to global
                }
            } else {
                if let key = loc.key as String? {
                    if key == "DISTANCE" {
                        distance = "\(loc.value!)"
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
