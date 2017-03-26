//
//  ExploreViewController.swift
//  RaceMe
//
//  Created by Vu Long on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
class ExploreViewController: UIViewController {
    let locationManager = CLLocationManager()
    var myLat = 0.00
    var myLong = 0.00
    var ref: FIRDatabaseReference!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        loadData()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.delegate = self
        
        if #available(iOS 9.0, *) {
            locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    func loadData(){
        ref.child(Constants.Route.TABLE_NAME).observeSingleEvent(of: .value, with: { (snapshot) in
            let routes = Route.decodeRoute(routesData: snapshot)
            for route in routes{
                self.drawRoute(route: route.locations)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawRoute(route: [CLLocationCoordinate2D]){
        let myPolyline = MKGeodesicPolyline(coordinates: route, count: route.count)
        mapView.add(myPolyline)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
extension ExploreViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
//            print("Found User's location: \(location11)")
//            print("Latitude: \(location11.coordinate.latitude) Longitude: \(location11.coordinate.longitude)")
            myLat = location.coordinate.latitude
            myLong = location.coordinate.longitude
            let span = MKCoordinateSpanMake(0.18, 0.18)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: myLat, longitude: myLong), span: span)
            mapView.setRegion(region, animated: true)
            
//            self.mapView.setCenter(CLLocationCoordinate2D(latitude: myLat, longitude: myLong), animated: true)
            locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
}
