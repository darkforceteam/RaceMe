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
    
    @IBAction func selectTime(_ sender: UIButton) {
        let selectTimeVC = SelectTimeViewController(nibName: "SelectTimeViewController", bundle: nil)
        selectTimeVC.modalPresentationStyle = UIModalPresentationStyle.popover
        // set up the popover presentation controller
//        selectTimeVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        selectTimeVC.popoverPresentationController?.delegate = self
        selectTimeVC.popoverPresentationController?.sourceView = sender
        selectTimeVC.popoverPresentationController?.sourceRect = sender.bounds //sender.bounds
        selectTimeVC.preferredContentSize.height = 200
        
        selectTimeVC.delegate = self
        // present the popover
        self.present(selectTimeVC, animated: true, completion: nil)
    }

    @IBOutlet weak var selectTimeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
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
        
        loadData()
    }
    
    var allRoute = [Route]()
    var displayRoute = [Route]()
    var todayRoute = [Route]()
    var tomorrowRoute = [Route]()
    var laterRoute = [Route]()
    var selectedTime = "0"
    
    func loadData(){
        ref.child(Constants.Route.TABLE_NAME).observeSingleEvent(of: .value, with: { (snapshot) in
            let routes = Route.decodeRoutes(routesData: snapshot)
            for route in routes{
                if route.isPublic {
                    print("drawing route with distance: \(route.distance)")
                    self.allRoute.append(route)
                }
            }
            self.filterRoutesData(newTime: self.selectedTime)
            self.refreshDisplayRoute()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func refreshDisplayRoute(){
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        for route in displayRoute {
            drawRoute(route: route.locations)
        }
    }
    
    func filterRoutesData(newTime: String){
        if newTime != selectedTime{
            switch newTime {
            case "0":
                displayRoute = allRoute
            case "1":
                if todayRoute.count == 0 {
                    todayRoute = buildDisplayRoute(timeIndex: newTime)
                }
                displayRoute = todayRoute
            case "2":
                if tomorrowRoute.count == 0 {
                    tomorrowRoute = buildDisplayRoute(timeIndex: newTime)
                }
                displayRoute = tomorrowRoute
            default:
                if laterRoute.count == 0 {
                    laterRoute = buildDisplayRoute(timeIndex: newTime)
                }
                displayRoute = laterRoute
            }
            selectedTime = newTime
        } else {
            displayRoute = allRoute
            selectedTime = newTime
        }
    }
    
    func buildDisplayRoute(timeIndex: String) -> [Route]{
        var returnRoute = [Route]()
        switch timeIndex {
        case "1":
            returnRoute.append(allRoute.first!)
        case "2":
            returnRoute.append(allRoute.last!)
        default:
            returnRoute.append(allRoute.last!)
        }
        return returnRoute
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
extension ExploreViewController: MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, SelectTimeViewControllerDelegate{
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
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
    }
    func changeTime(selectTimeVC: SelectTimeViewController, selectedTime: String){
        print("Selected value: \(selectedTime)")
        filterRoutesData(newTime: selectedTime)
        refreshDisplayRoute()
    }
}
