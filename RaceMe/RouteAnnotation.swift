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
        if personCount > 1 {
            self.title = "\(pinUsername!) and \(personCount-1) person at \(time) \(date)"
        } else {
            self.title = "\(pinUsername!) will run at \(time) \(date)"
        }
    }
    //    var startLoc: CLLocationCoordinate2D
    func setTitleDistance(){
        self.title = "\(route.name): \(route.distance.divided(by: 1000.0)) km"
    }
    
    func getNameDistance() -> String{
        return "\(route.name): \(route.distance.divided(by: 1000.0)) km"
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
