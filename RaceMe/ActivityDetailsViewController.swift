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
        if (workout) != nil{
            loadRoute(routeid: workout.key)
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
    
    func loadRoute(routeid: String){
        if routeid != "" {
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
        //TODO: move span value to a global constant so that all mapview show the same zoom level
        let span = MKCoordinateSpanMake(0.009, 0.009)
        let myRegion = MKCoordinateRegion(center: route.locations.first!, span: span)
        mapView.setRegion(myRegion, animated: false)
        let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
        mapView.add(myPolyline)
        //TODO: set center to the middle point of the route. HTF can I calculate that?
        mapView.setCenter((route.locations.first)!, animated: true)
    }
}
extension ActivityDetailsViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = dangerColor
        renderer.lineWidth = 4.0
        return renderer
    }
}
