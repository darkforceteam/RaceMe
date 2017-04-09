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
    var distance = 0.0
    var locations = [CLLocationCoordinate2D]()
    var name: String = ""
    var events = [Event]()
    var todayEvents = [Event]()
    var tomorrowEvents = [Event]()
    var laterEvents = [Event]()
    var displayEvent: Event?
    var routeId: String!
    var firstEventDay = 0
    func participant_count(displayingDate: String) -> Int {
        switch displayingDate {
        case "1":
            if self.todayEvents.first != nil{
                return (self.todayEvents.first?.participants.count)!
            } else {
                return 0
            }
        case "2":
            if self.tomorrowEvents.first != nil {
                return (self.tomorrowEvents.first?.participants.count)!
            } else {
                return 0
            }
        case "3":
            if self.laterEvents.first != nil {
                return (self.laterEvents.first?.participants.count)!
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    func setFirstEvent(){
        if todayEvents.count > 0 {
            displayEvent = todayEvents[0] as Event
            firstEventDay = 1
            print("First Event is at \(displayEvent?.start_time)")
        } else if tomorrowEvents.count > 0 {
            displayEvent = tomorrowEvents[0] as Event
            firstEventDay = 2
            print("First Event is at \(displayEvent?.start_time)")
        } else if laterEvents.count > 0 {
            displayEvent = laterEvents[0] as Event
            firstEventDay = 3
            print("First Event is at \(displayEvent?.start_time)")
        } else {
            displayEvent = nil
            print("NO EVENT FOUND")
        }
    }
    func removeEvent(eventId: String) {
        for i in 0..<events.count{
            let event = events[i] as Event!
            if event?.eventId == eventId{
                events.remove(at: i)
                break
            }
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
                        distance = loc.value! as! Double
                    } else if key == "NAME" {
                        name = loc.value! as! String
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
