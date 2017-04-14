//
//  ActivityDetailsViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/5/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
class ActivityDetailsViewController: UIViewController {
    var ref: FIRDatabaseReference!
    var workout: Workout!
    var locations = [CLLocation]()
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var avgPaceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        mapView.delegate = self
        // Do any additional setup after loading the view.
        if (workout) != nil {
            loadRoute(routeid: workout.routeId!)
            loadUser(uid: workout.userId)
        }
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        
        timeLabel.text = workout.startTime!.toDate
        durationLabel.text = "\(workout.duration!.toMinutes):\(workout.duration!.toSeconds)"
        distanceLabel.text = String(format: "%.1f", workout.distanceKm!)
        let pace = Double(workout.duration!) / workout.distanceKm!
        avgPaceLabel.text = "\(pace.stringWithPaceFormat) /km"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension ActivityDetailsViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = dangerColor
        renderer.lineWidth = 4.0
        let mapRect = MKPolygon(points: renderer.polyline.points(), count: renderer.polyline.pointCount)
        mapView.setVisibleMapRect(mapRect.boundingMapRect, edgePadding: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0), animated: false)
        return renderer
    }
    
    func loadUser(uid: String) {
        if uid != "" {
            self.ref.child("USERS/\(uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                self.avatarImageView.setImageWith(URL(string: user.photoUrl!)!)
                self.displayNameLabel.text = user.displayName
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func loadRoute(routeid: String){
        if routeid != "" {
            print(routeid)
            self.ref.child(Constants.Route.TABLE_NAME+"/"+routeid).observeSingleEvent(of: .value, with: { (snapshot) in
                let route = Route(locationsData: snapshot)
                route.routeId = routeid
                if route.locations.count > 0 {
                    self.drawRoute(route: route)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    func drawRoute(route: Route){
        let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
        mapView.add(myPolyline)
    }
}
