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
//    let locationManager = CLLocationManager()
    fileprivate lazy var locationManager: CLLocationManager = {
        var lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.activityType = .fitness
        lm.distanceFilter = 10.0
        lm.requestAlwaysAuthorization()
        lm.allowsBackgroundLocationUpdates = true
        return lm
    }()
    let loadUrlImgSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()
    
    var allRoute = [Route]()
    var displayRoute = [Route]()
    var todayRoute = [Route]()
    var tomorrowRoute = [Route]()
    var laterRoute = [Route]()
    var displayingTime = "0"
    var newFilterDay = ""
    //    var myLoc = MKUserLocation()
    //    var myRegion = MKCoordinateRegion()
    var ref: FIRDatabaseReference!
    var eventRef: FIRDatabaseReference!
    var geoRef: FIRDatabaseReference!
    var userRef: FIRDatabaseReference!
    var geoFire: GeoFire!
    var routesInSpanKey = [String]()
    //    var viewingTime = ""
    var foundCurrentLoc = false
    var routesChanged = false
    var oldVersion = false
    var nearByRouteCount = 0
    var publicRouteInSpan = 0
    
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectTimeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        eventRef = ref.child("EVENTS")
        geoRef = ref.child(Constants.PUBLIC_GEOFIRE)
        geoFire = GeoFire(firebaseRef: geoRef)
        userRef = ref.child("USERS")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 9.0, *) {
            locationManager.requestLocation()
        } else {
            oldVersion = true
            locationManager.startUpdatingLocation()
        }
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true;
        mapView.isScrollEnabled = true;
        mapView.isUserInteractionEnabled = true;
        mapView.setUserTrackingMode(.none, animated: true)
        actIndicator.isHidden = true
        actIndicator.hidesWhenStopped = true
        //        locationManager.startUpdatingLocation()
        //        ref.child(Constants.Route.TABLE_NAME).removeValue()
        fixManuallyImportedRoutes()
        //        emptyPublicRoute()
    }
    
    @IBAction func selectTime(_ sender: UIButton) {
        buildDisplayRoute()
        
        let selectTimeVC = SelectTimeViewController(nibName: "SelectTimeViewController", bundle: nil)
        selectTimeVC.modalPresentationStyle = UIModalPresentationStyle.popover
        
        selectTimeVC.popoverPresentationController?.delegate = self
        selectTimeVC.popoverPresentationController?.sourceView = sender
        selectTimeVC.popoverPresentationController?.sourceRect = sender.bounds //sender.bounds
        selectTimeVC.preferredContentSize.height = 160
        
        selectTimeVC.delegate = self
        // present the popover
        self.present(selectTimeVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool){
        filterDataByTime()
    }
    override func viewDidAppear(_ animated: Bool) {
        if mapView == nil {
            print("mapview is null")
        }
    }
    func filterDataByTime(){
        do {
            if newFilterDay != "" {
                selectTimeButton.titleLabel?.text = newFilterDay
                try filterRoutesData(newTime: newFilterDay)
                try refreshDisplayRoute()
            }
        } catch {
            print("ERROR!!!!!!: \(error)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if ref != nil {
            ref.removeAllObservers()
            eventRef.removeAllObservers()
        }
    }

    func refreshDisplayRoute() throws {
        if mapView.overlays.count > 0 {
            mapView.removeOverlays(mapView.overlays)
        }
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        for route in displayRoute {
            do {
                try drawRoute(route: route)
            } catch {
                print("Error drawing route: \(error)")
            }
        }
    }
    
    func filterRoutesData(newTime: String) throws {
        displayRoute.removeAll()
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
        if routesChanged {
            todayRoute.removeAll()
            tomorrowRoute.removeAll()
            laterRoute.removeAll()
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
        routesChanged = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawRoute(route: Route) throws {
        let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
        mapView.add(myPolyline)
        print("ROUTE has event with \(route.displayEvent?.participants.count) participant")
        let routeMarker = RouteAnnotation()
        routeMarker.routeId = route.routeId
        routeMarker.route = route
        let pin = RoutePoint()
        pin.coordinate = route.locations.first!
        
        
        if let firstEvent = route.displayEvent {
            let firstPersonID = firstEvent.participants[0] as String
            userRef.child(firstPersonID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let userData = snapshot.value as? NSDictionary{
                    let firstUser = UserObject(snapshot: snapshot)
                    routeMarker.pinType = RouteAnnotation.PIN_EVENT
                    routeMarker.pinCustomImage = userData.value(forKey: "photoUrl") as! String!
                    routeMarker.pinUsername = userData.value(forKey: "displayName") as! String!
                    routeMarker.personCount = route.participant_count(displayingDate: self.displayingTime)
                    routeMarker.setTitleEvent(scheduled: firstEvent.start_time, firstEventDay: route.firstEventDay)
                    
                    //                    let imageUrl = NSURL(string: routeMarker.pinCustomImage)
                    //                    if let data = NSData(contentsOf: imageUrl as! URL){
                    //                        routeMarker.imageView = UIImage(data: data as Data)!
                    //                    }
                    //                    self.loadAnnoImage(imageURL: routeMarker.pinCustomImage, anno: routeMarker)
                    routeMarker.image = UIImage(named: "default-avatar")!
                    firstUser.avatarImg = routeMarker.image
                    routeMarker.route.displayEvent?.firstUser = firstUser
                    
                    let request = NSMutableURLRequest(url: URL(string: routeMarker.pinCustomImage)!)
                    request.httpMethod = "GET"
                    
//                    let session = URLSession(configuration: URLSessionConfiguration.default)
                    let dataTask = self.loadUrlImgSession.dataTask(with: request as URLRequest) { (data, response, error) in
                        if error == nil {
                            routeMarker.image = UIImage(data: data!, scale: UIScreen.main.scale)
                            firstUser.avatarImg = routeMarker.image
                            routeMarker.route.displayEvent?.firstUser = firstUser
                            DispatchQueue.main.async {
                                pin.title = routeMarker.title
                                pin.AnnoView = routeMarker
                                self.mapView.addAnnotation(pin)
                            }
                        } else {
                            print("ERROR: \(error)")
                            self.alert(message: "\(error)",title: "Error loading user avatar")
                        }
                    }
                    dataTask.resume()
                } else {
                    routeMarker.setTitleDistance()
                    routeMarker.image = UIImage(named: "pin-run")?.withRenderingMode(.alwaysTemplate)
                    routeMarker.tintColor = successColor
                    pin.title = routeMarker.title
                    pin.AnnoView = routeMarker
                    self.mapView.addAnnotation(pin)
                }
                self.actIndicator.stopAnimating()
            })
        } else {
            routeMarker.setTitleDistance()
            routeMarker.image = UIImage(named: "pin-run")
            pin.title = routeMarker.title
            pin.AnnoView = routeMarker
            self.mapView.addAnnotation(pin)
            self.actIndicator.stopAnimating()
        }
    }
    
    func changeTime(selectTimeVC: SelectTimeViewController, selectedTime: String){
//        selectTimeButton.titleLabel?.text = selectedTime
//        filterRoutesData(newTime: selectedTime)
//        refreshDisplayRoute()
        newFilterDay = selectedTime
        filterDataByTime()
    }

    func loadRoute(routeid: String){
        nearByRouteCount += 1
        print("\(nearByRouteCount). Route \(routeid)")
        // QueryCount 2: for each Route, check if Route is GLOBAL ROUTE
        actIndicator.isHidden = false
        actIndicator.startAnimating()
//        ref.child(Constants.Route.TABLE_NAME+"/"+routeid).observeSingleEvent(of: .value, with: { (snapshot) in
//            if snapshot.hasChild(Constants.Route.IS_GLOBAL) {
//                print("Route \(routeid) IS GLOBAL")
            
                self.ref.child(Constants.PublicRoute.TABLE_NAME+"/"+routeid).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let route = Route(locationsData: snapshot)
                    route.routeId = routeid
                    if route.locations.count > 0 {
                        self.publicRouteInSpan += 1
                        //                print("route \(self.visibleRoutes) added. Distance: \(route.distance)")
                        // QueryCount 3: for each Route, get events hosted at this route in the future
                        
                        self.eventRef.queryOrdered(byChild: "route_id").queryEqual(toValue: routeid).observe(.value, with: {
                            //                        self.eventRef.queryEqual(toValue: routeid, childKey: "route_id").observeSingleEvent(of: .value, with: {
                            (snapshot) in
                            if snapshot.hasChildren(){
                                let currentTime = NSDate().timeIntervalSince1970
                                route.events.removeAll()
                                for eventData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                                    if let oneEvent = eventData.value as? NSDictionary{
                                        let start_time = oneEvent.value(forKey: "start_time") as! Double
                                        if start_time >= currentTime {
                                            let event_datetime = NSDate(timeIntervalSince1970: start_time )
                                            let event = Event(route_id: "", start_time: event_datetime as Date)
                                            event.eventId = eventData.key
                                            if let participants = oneEvent.value(forKey: "participants") as? NSDictionary{
                                                if participants.count > 0 {
                                                    for (key, _) in participants{
                                                        event.participants.append(key as! String)
                                                    }
                                                    event.setFirstUser()
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
                                route.setFirstEvent()
//                                print("found \(route.events.count) event for \(routeid)")
                                
                            }
                            do {
                                try self.drawRoute(route: route)
                            } catch {
                                print("Error drawing route")
                            }
                        })
                        self.allRoute.append(route)
                    }
                    if self.publicRouteInSpan == 0{
                        self.actIndicator.stopAnimating()
                        print("NO GLOBAL ROUTE FOUND")
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
//            } else {
//                self.actIndicator.stopAnimating()
//                print("NO GLOBAL ROUTE FOUND")
//            }
//        })
    }
    
//    func loadUser(_ snapshot: FIRDataSnapshot) -> UserObject{
//        var returnUser = UserObject(snapshot: snapshot)
//        
//        let request = NSMutableURLRequest(url: URL(string: returnUser.photoUrl!)!)
//        request.httpMethod = "GET"
//        
//        let session = URLSession(configuration: URLSessionConfiguration.default)
//        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
//            if error == nil {
//                returnUser.avatarImg = UIImage(data: data!, scale: UIScreen.main.scale)
//            }
//        }
//        dataTask.resume()
//        
//    }
    
    func queryRouteInRegion(myRegion: MKCoordinateRegion){
        nearByRouteCount = 0
        publicRouteInSpan = 0
        if (myRegion.span.latitudeDelta > 0) && (myRegion.span.latitudeDelta < 120)
            && (myRegion.span.longitudeDelta > 0) && (myRegion.span.longitudeDelta < 120){
            //get routes with start_loc in span from GEOFIRE
            let regionQuery = geoFire?.query(with: myRegion)
            actIndicator.isHidden = false
            actIndicator.startAnimating()
            
            //        let center = CLLocation(latitude: myLoc.coordinate.latitude,longitude: myLoc.coordinate.longitude)
            //        var circleQuery = geoFire?.query(at: center, withRadius: 10)
            //        regionQuery?.observeReady({
            //            print("All initial data has been loaded and events have been fired!")
            //        })
            // QueryCount 1: get Routes in Displaying Region using GeoFire
            regionQuery?.observeReady({
                if self.nearByRouteCount == 0{
                    self.actIndicator.stopAnimating()
                }
            })
            
            _ = regionQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
                //            print("Key '\(key)' entered the search area and is at location '\(location)'")
                if !self.routesInSpanKey.contains(key!){
                    self.routesInSpanKey.append(key!)
                    self.loadRoute(routeid: key!)
                }
            })
            routesChanged = true
        }
    }
    func loadAnnoImage(imageURL: String, anno: MKAnnotationView) {
        let request = NSMutableURLRequest(url: URL(string: imageURL)!)
        request.httpMethod = "GET"
//        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = loadUrlImgSession.dataTask(with: request as URLRequest) { (data, response, error) in
            if error == nil {
                anno.image = UIImage(data: data!, scale: UIScreen.main.scale)
                //                DispatchQueue.main.async {
                //                    self.mapView.addAnnotation(anno as! MKAnnotation)
                //                }
            }
        }
        dataTask.resume()
    }
    
    func fixManuallyImportedRoutes(){
        //check if needed
        
        //load routes
        let routeref = ref.child(Constants.PublicRoute.TABLE_NAME)
        _ = routeref.observe(.value, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                //pickup each route, get route_id
                if let key = child.key as String? {
                    print("checking route: \(key)")
                    let route = Route(locationsData: child)
                    //set value for geofire
                    if route.locations.count > 0 {
                        let startLoc = route.locations.first
                        
                        let geoFire = GeoFire(firebaseRef: self.geoRef)
                        //        geoFire?.setLocation(startLoc, forKey: "\(routeID)/\(Constants.Route.ROUTE_DISTANCE)")
                        geoFire?.setLocation(CLLocation(latitude: (startLoc?.latitude)!,longitude: (startLoc?.longitude)!), forKey: key)
                    }
                }
                //                if route.locations.count > 0 {
                //                    routes.append(route)
                //                    i+=1
                //                    print("added route number: \(i)")
                //                }
            }
        })
    }
    func emptyPublicRoute(){
        ref.child(Constants.PublicRoute.TABLE_NAME).removeValue(completionBlock: { (error, reff) in
            if error != nil {
                print("ERROR: \(error)")
            } else {
                print("success")
            }
        })
    }
    func openDetailsVC(sender: UIButton)
    {
        let view = sender.superview as! CustomPinView
        print("open details vc for route id: \(view.routeId)")
        let routeDetailVC = RouteDetailVC(nibName: "RouteDetailVC", bundle: nil)
        routeDetailVC.routeId = view.routeId
        routeDetailVC.route = view.route
        // present the popover
        navigationController?.pushViewController(routeDetailVC, animated: true)
//        self.present(routeDetailVC, animated: true, completion: nil)
    }

}
extension ExploreViewController: CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, SelectTimeViewControllerDelegate, MKMapViewDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if oldVersion {
                if let location = locations.first {
                    let myLat = location.coordinate.latitude
                    let myLong = location.coordinate.longitude
                    let span = MKCoordinateSpanMake(0.18, 0.18)
                    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: myLat, longitude: myLong), span: span)
                    mapView.setRegion(region, animated: true)
                    locationManager.stopUpdatingLocation()
                }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //TODO display custom User location view
            return nil
        }
        let castedAnno = annotation as! RoutePoint
        let annoView = castedAnno.AnnoView as! RouteAnnotation

        annoView.canShowCallout = false
//        annoView.tintColor = UIColor.green
//        annoView.layer.cornerRadius = annoView.frame.width / 2
//        annoView.layer.borderColor = UIColor.green.cgColor
//        annoView.layer.borderWidth = 1
//        annoView.clipsToBounds = true
        
        if annoView.pinType == RouteAnnotation.PIN_EVENT{
            annoView.isSelected = true
        }
        
//        let views = Bundle.main.loadNibNamed("CustomPinView", owner: nil, options: nil)
//        let pinView = views?[0] as! CustomPinView
//        pinView.titleLabel.text = annoView.title
//        pinView.imageView.image = annoView.image
//        annoView.addSubview(pinView)
//        // Set size
//        let widthConstraint = NSLayoutConstraint(item: pinView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 80)
//        let heightConstraint = NSLayoutConstraint(item: pinView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20)
//        var constraints = NSLayoutConstraint.constraints(
//            withVisualFormat: "V:[superview]-(<=1)-[label]",
//            options: NSLayoutFormatOptions.alignAllCenterX,
//            metrics: nil,
//            views: ["superview":annoView, "label":pinView])
//        annoView.addConstraints(constraints)
//        // Center vertically
//        constraints = NSLayoutConstraint.constraints(
//            withVisualFormat: "H:[superview]-(<=1)-[label]",
//            options: NSLayoutFormatOptions.alignAllTop,
//            metrics: nil,
//            views: ["superview":annoView, "label":pinView])
//        annoView.addConstraints(constraints)
//        annoView.addConstraints([ widthConstraint, heightConstraint])
        
        return annoView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // 1
        if view.annotation is MKUserLocation
        {
            return
        }
        let annoView = view as! RouteAnnotation
        let views = Bundle.main.loadNibNamed("CustomPinView", owner: nil, options: nil)
        let pinView = views?[0] as! CustomPinView
        pinView.route = annoView.route
        pinView.titleLabel.text = annoView.title
        let button = UIButton(frame: pinView.titleLabel.frame)
        button.addTarget(self, action: #selector(openDetailsVC(sender:)), for: .touchUpInside)
        pinView.addSubview(button)
        
        pinView.imageView.image = annoView.image
        
        pinView.routeId = annoView.routeId
        // 3
        pinView.center = CGPoint(x: view.bounds.size.width / 2, y: -pinView.bounds.size.height*0.52)
        
        view.addSubview(pinView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: RouteAnnotation.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation){
        if !foundCurrentLoc {
            let span = MKCoordinateSpanMake(0.09, 0.09)
            let myRegion = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(myRegion, animated: true)
            foundCurrentLoc = true
        }
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if foundCurrentLoc {
            queryRouteInRegion(myRegion: mapView.region)
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = dangerColor
        renderer.lineWidth = 4.0
        return renderer
    }
}
extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy' at ' h:mm a."
        return dateFormatter.string(from: self)
    }
}
extension UIViewController {
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
