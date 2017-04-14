//
//  RouteAnnotation.swift
//  RaceMe
//
//  Created by LVMBP on 3/28/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import MapKit
class RouteAnnotation: MKAnnotationView {
    static let PIN_DISTANCE = "DISTANCE"
    static let PIN_EVENT = "EVENT"
    var pinCustomImage: String!
    var pinUsername: String!
    var pinCustomTitle: String!
    var pinType = PIN_DISTANCE
    var personCount = 0
    let dateFormatter = DateFormatter()
    let timeFormat = "hh:mm a"
    let dateFormat = "E MMM dd"
    var imageView = UIImage()
    var title: String!
    var routeId: String!
    var route: Route!
    var loc_type = ""
    
    //    var startLoc: CLLocationCoordinate2D
    func setTitleEvent(scheduled: Date?, firstEventDay: Int){
        dateFormatter.dateFormat = timeFormat
        let time = dateFormatter.string(from: scheduled!)
        var date = ""
        if firstEventDay == 1 {
            date = "today"
        } else if firstEventDay == 2{
            date = "tomorrow"
        } else if firstEventDay == 3{
            dateFormatter.dateFormat = dateFormat
            date = dateFormatter.string(from: scheduled!)
        }
        var actType = loc_type
        if actType == "" ||  actType == Constants.SPORT_TYPE.RUN{
            actType = Constants.SPORT_TYPE.RUN
            if personCount > 1 {
                self.title = "\(pinUsername!) and \(personCount-1) person will \(actType) at \(time) \(date)"
            } else {
                self.title = "\(pinUsername!) will \(actType) at \(time) \(date)"
            }
        } else {
            var strAppend = ""
            if personCount > 1 {
                strAppend = ": \(personCount) person at \(time) \(date)"
            } else {
                strAppend = ": \(pinUsername!) will join at \(time) \(date)"
            }
            self.title = "\(route.name) \(strAppend)"
        }
    }
    //    var startLoc: CLLocationCoordinate2D
    func setDefaultTitle(){
        var strAppend = ""
        if route.distance > 0.0 {
            strAppend = ": \(String(format: "%.2f", Utils.distanceInKm(distanceInMeter: route.distance))) km"
        } else {
//            if self.loc_type != "" {
//                strAppend = self.loc_type
//            }
        }
        self.title = "\(route.name) \(strAppend)"
    }
    
    func getNameDistance() -> String{
        let distStr = String(format: "%.2f", Utils.distanceInKm(distanceInMeter: route.distance))
        return "\(route.name): \(distStr) km"
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds;
        var isInside: Bool = rect.contains(point);
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point);
                if isInside
                {
                    break;
                }
            }
        }
        return isInside;
    }
}
class RoutePoint: MKPointAnnotation{
    var AnnoView = MKAnnotationView()
}
