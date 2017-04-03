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
    var distance = 0
    var personCount = 0
    let dateFormatter = DateFormatter()
    let dateFormat = "hh:mm a"
    var imageView = UIImage()
    var title: String!
    var routeId: String!
    
    //    var startLoc: CLLocationCoordinate2D
    func setTitleEvent(scheduled: Date?){
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: scheduled!)
        if personCount > 1 {
            self.title = "\(pinUsername!) and \(personCount-1) person at \(dateString)"
        } else {
            self.title = "\(pinUsername!) will run at \(dateString)"
        }
    }
    //    var startLoc: CLLocationCoordinate2D
    func setTitleDistance(){
        self.title = "\(self.distance) km"
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
