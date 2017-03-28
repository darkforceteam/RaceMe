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
    var allRoute = [Route]()
    var displayRoute = [Route]()
    var todayRoute = [Route]()
    var tomorrowRoute = [Route]()
    var laterRoute = [Route]()
    var displayingTime = "0"
    //    var myLoc = MKUserLocation()
    //    var myRegion = MKCoordinateRegion()
    var ref: FIRDatabaseReference!
    var routesInSpanKey = [String]()
    var visibleRoutes = 0
//    var viewingTime = ""
    var foundCurrentLoc = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.delegate = self
        mapView.isZoomEnabled = true;
        mapView.isScrollEnabled = true;
        mapView.isUserInteractionEnabled = true;
        mapView.setUserTrackingMode(.none, animated: true)
        if #available(iOS 9.0, *) {
            locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func selectTime(_ sender: UIButton) {
        buildDisplayRoute()
        
        let selectTimeVC = SelectTimeViewController(nibName: "SelectTimeViewController", bundle: nil)
        selectTimeVC.modalPresentationStyle = UIModalPresentationStyle.popover
        
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
    
    override func viewWillAppear(_ animated: Bool){
        if displayingTime != "" {
            selectTimeButton.titleLabel?.text = displayingTime
            filterRoutesData(newTime: displayingTime)
            refreshDisplayRoute()
        }
    }
    
    func refreshDisplayRoute(){
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        for route in displayRoute {
            drawRoute(route: route)
        }
    }
    
    func filterRoutesData(newTime: String){
        if newTime != displayingTime{
            switch newTime {
            case "0"://All time
                displayRoute = allRoute
            case "1"://Today
                displayRoute = todayRoute
            case "2"://Tomorrow
                displayRoute = tomorrowRoute
            default://Later
                displayRoute = laterRoute
            }
        } else {
            displayRoute = allRoute
        }
        displayingTime = newTime
    }
    
    func buildDisplayRoute(){
        for route in allRoute {
            if route.todayEvents.count > 0 {
                todayRoute.append(route)
            }
            if route.tomorrowEvents.count > 0 {
                tomorrowRoute.append(route)
            }
            if route.laterEvents.count > 0 {
                laterRoute.append(route)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawRoute(route: Route){
        let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
        mapView.add(myPolyline)
        
        let routeMarker = RouteAnnotation()
        routeMarker.coordinate = route.locations.first!
        routeMarker.title = route.title(displayingDate: displayingTime)
        mapView.addAnnotation(routeMarker)
        mapView.selectAnnotation(routeMarker, animated: true)

    }
    
    func changeTime(selectTimeVC: SelectTimeViewController, selectedTime: String){
        print("Selected value: \(selectedTime)")
//        displayingTime = selectedTime
//        viewingTime = selectedTime
        selectTimeButton.titleLabel?.text = selectedTime
        filterRoutesData(newTime: selectedTime)
        refreshDisplayRoute()
    }
    
    func loadRoute(routeid: String){
        // QueryCount 2: for each Route, get 1 locations set to display
        ref.child(Constants.Route.TABLE_NAME+"/"+routeid).observeSingleEvent(of: .value, with: { (snapshot) in
            let route = Route(locationsData: snapshot)
            if route.locations.count > 0 {
                self.visibleRoutes += 1
                //                print("route \(self.visibleRoutes) added. Distance: \(route.distance)")
                // QueryCount 3: for each Route, get events hosted at this route in the future
                let eventRef = self.ref.child("EVENTS")
                eventRef.queryOrdered(byChild: "route_id").queryEqual(toValue: routeid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChildren(){
                        let currentTime = NSDate().timeIntervalSince1970
                        for eventData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                            if let oneEvent = eventData.value as? NSDictionary{
                                let start_time = oneEvent.value(forKey: "start_time") as! Double
                                if start_time >= currentTime {
                                    let event_datetime = NSDate(timeIntervalSince1970: start_time )
                                    let event = Event(route_id: "", start_time: event_datetime as Date)
                                    if let participants = oneEvent.value(forKey: "participants") as? NSDictionary{
                                        for (key, _) in participants{
                                            event.participants.append(key as! String)
                                        }
                                    }
                                    route.events.append(event)
                                    if NSCalendar.current.isDateInToday(event.start_time){
                                        route.todayEvents.append(event)
                                    } else if NSCalendar.current.isDateInTomorrow(event.start_time){
                                        route.tomorrowEvents.append(event)
                                    } else {
                                        route.laterEvents.append(event)
                                    }
                                }
                            }
                        }
                    }
                })
                self.allRoute.append(route)
                self.drawRoute(route: route)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func queryRouteInRegion(myRegion: MKCoordinateRegion){
        //get routes with start_loc in span from GEOFIRE
        let gfRef = ref.child(Constants.GEOFIRE)
        let geoFire = GeoFire(firebaseRef: gfRef)
        let regionQuery = geoFire?.query(with: myRegion)
        
        //        let center = CLLocation(latitude: myLoc.coordinate.latitude,longitude: myLoc.coordinate.longitude)
        //        var circleQuery = geoFire?.query(at: center, withRadius: 10)
        //        regionQuery?.observeReady({
        //            print("All initial data has been loaded and events have been fired!")
        //        })
        // QueryCount 1: get Routes in Displaying Region using GeoFire
        _ = regionQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            //            print("Key '\(key)' entered the search area and is at location '\(location)'")
            if !self.routesInSpanKey.contains(key!){
                self.routesInSpanKey.append(key!)
                self.loadRoute(routeid: key!)
            }
        })
    }
}
extension ExploreViewController: MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, SelectTimeViewControllerDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation){
        //        myLoc = userLocation
        if !foundCurrentLoc {
            let span = MKCoordinateSpanMake(0.09, 0.09)
            let myRegion = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(myRegion, animated: true)
//            queryRouteInRegion(myRegion: myRegion)
            foundCurrentLoc = true
        }
    }
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        if let location = locations.first {
    //            myLat = location.coordinate.latitude
    //            myLong = location.coordinate.longitude
    //            let span = MKCoordinateSpanMake(0.18, 0.18)
    //            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: myLat, longitude: myLong), span: span)
    //            mapView.setRegion(region, animated: true)
    //            locationManager.stopUpdatingLocation()
    //        }
        }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        queryRouteInRegion(myRegion: mapView.region)
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
    
    //    func loadRoutes(){
    //        //get route data
    //        ref.child(Constants.Route.TABLE_NAME).observeSingleEvent(of: .value, with: { (snapshot) in
    //            let routes = Route.decodeRoutes(routesData: snapshot)
    //            for route in routes{
    //                if route.isPublic {
    //                    print("drawing route with distance: \(route.distance)")
    //                    self.allRoute.append(route)
    //                }
    //            }
    //        }) { (error) in
    //            print(error.localizedDescription)
    //        }
    //    }
    
}
