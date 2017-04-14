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
class ExploreViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
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
    var displayingTime = Constants.FilterDay.ALL_TIME_DISPLAY
    var newFilterDay = Constants.FilterDay.ALL_TIME_DISPLAY
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
    var displayingType = Constants.SPORT_TYPE.ALL

    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var groupPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIPickerView!

    
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectTimeButton: UIButton!
    @IBOutlet weak var selectTypeButton: UIButton!
    @IBOutlet weak var selectGroupButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var typeOptions = [Constants.SPORT_TYPE.ALL,Constants.SPORT_TYPE.RUN,Constants.SPORT_TYPE.YOGA,Constants.SPORT_TYPE.SWIM]//FIXED FOR NOW. TODO: change to DB load
    var groupOptions = ["Public", "Friends"]//FIXED FOR NOW. TODO: change to DB load
    var timeOptions = [Constants.FilterDay.ALL_TIME_DISPLAY,Constants.FilterDay.TODAY_DISPLAY,Constants.FilterDay.TOMORROW_DISPLAY,Constants.FilterDay.LATER_DISPLAY]
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
        
        selectTimeButton.layer.cornerRadius = 3
        selectTimeButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        selectTimeButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        selectTimeButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        selectTimeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        
        selectTypeButton.layer.cornerRadius = 3
        
        selectTypeButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        selectTypeButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        selectTypeButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        selectTypeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        
        selectGroupButton.layer.cornerRadius = 3
        selectGroupButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        selectGroupButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        selectGroupButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        selectGroupButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)

        setupFilterButtons()
        hideKeyboardWhenTappedAround()
    }
    
    func setupFilterButtons(){
        typePicker.delegate = self
        typePicker.isHidden = true
        groupPicker.delegate = self
        groupPicker.isHidden = true
        timePicker.delegate = self
        timePicker.isHidden = true
    }
    
    @IBAction func selectTime(_ sender: UIButton) {
        buildDisplayRoute()
        timePicker.isHidden = false
//        let selectTimeVC = SelectTimeViewController(nibName: "SelectTimeViewController", bundle: nil)
//        selectTimeVC.modalPresentationStyle = UIModalPresentationStyle.popover
//        
//        selectTimeVC.popoverPresentationController?.delegate = self
//        selectTimeVC.popoverPresentationController?.sourceView = sender
//        selectTimeVC.popoverPresentationController?.sourceRect = sender.bounds //sender.bounds
//        selectTimeVC.preferredContentSize.height = 180
//        
//        selectTimeVC.delegate = self
//        // present the popover
//        self.present(selectTimeVC, animated: true, completion: nil)
    }
    
    @IBAction func selectGroup(_ sender: UIButton) {
        groupPicker.isHidden = false
    }
    @IBAction func selectType(_ sender: UIButton) {
        typePicker.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool){
        if foundCurrentLoc {
            queryRouteInRegion(myRegion: mapView.region)
            filterDataByTime()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if mapView == nil {
            print("mapview is null")
        }
    }
    func filterDataByTime(){
        do {
            if newFilterDay != "" {
                //selectTimeButton.titleLabel?.text = Constants.timeData[newFilterDay]
                try filterRoutesData(newTime: newFilterDay)
                try refreshDisplayRoute()
            }
        } catch {
            print("ERROR!!!!!!: \(error)")
        }
    }
    
    deinit{
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
            if newTime == Constants.FilterDay.ALL_TIME_DISPLAY {
                displayRoute = allRoute
            } else if newTime == Constants.FilterDay.TODAY_DISPLAY {
                displayRoute = todayRoute
            } else if newTime == Constants.FilterDay.TOMORROW_DISPLAY {
                displayRoute = tomorrowRoute
            } else {
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
        print(displayingType)
        print(route.type)
        if displayingType == route.type || displayingType == Constants.SPORT_TYPE.ALL || (displayingType == Constants.SPORT_TYPE.RUN && route.type == "") {
            let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
            mapView.add(myPolyline)
            print("ROUTE has event with \(route.displayEvent?.participants.count) participant")
            let routeMarker = RouteAnnotation()
            routeMarker.routeId = route.routeId
            routeMarker.route = route
            routeMarker.loc_type = route.type
            let pin = RoutePoint()
            pin.coordinate = route.locations.first!
            
            if let firstEvent = route.displayEvent {
                var userOnPinImgId = ""
                if let creatorId = route.displayEvent?.createdBy {
                    userOnPinImgId = creatorId
                }
                if  firstEvent.participants.count > 0 {
                    if userOnPinImgId == "" {
                        userOnPinImgId = firstEvent.participants[0] as String
                    }
                    userRef.child(userOnPinImgId).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let userData = snapshot.value as? NSDictionary{
                            let firstUser = UserObject(snapshot: snapshot)
                            routeMarker.pinType = RouteAnnotation.PIN_EVENT
                            routeMarker.pinCustomImage = userData.value(forKey: "photoUrl") as! String!
                            routeMarker.pinUsername = userData.value(forKey: "displayName") as! String!
                            routeMarker.personCount = route.participant_count(displayingDate: self.displayingTime)
                            routeMarker.personCount = firstEvent.participants.count
                            routeMarker.setTitleEvent(scheduled: firstEvent.start_time, firstEventDay: route.firstEventDay)
                            
//                            routeMarker.image = UIImage(named: "default-avatar")!
                            firstUser.avatarImg = routeMarker.image
                            routeMarker.route.displayEvent?.firstUser = firstUser
                            
                            let request = NSMutableURLRequest(url: URL(string: routeMarker.pinCustomImage)!)
                            request.httpMethod = "GET"
                            
                            //                    let session = URLSession(configuration: URLSessionConfiguration.default)
                            let dataTask = self.loadUrlImgSession.dataTask(with: request as URLRequest) { (data, response, error) in
                                if error == nil {
                                    // Resize image
                                    let pinImage = UIImage(data: data!, scale: UIScreen.main.scale)
                                    let size = CGSize(width: 30, height: 30)
                                    UIGraphicsBeginImageContext(size)
                                    pinImage!.draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
                                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                                    UIGraphicsEndImageContext()
                                    
                                    routeMarker.image = resizedImage
                                    firstUser.avatarImg = routeMarker.image
                                    routeMarker.route.displayEvent?.firstUser = firstUser
                                    DispatchQueue.main.async {
                                        pin.title = routeMarker.title
                                        pin.AnnoView = routeMarker
                                        self.mapView.addAnnotation(pin)
                                        self.actIndicator.stopAnimating()
                                    }
                                } else {
                                    print("ERROR: \(error)")
                                    self.alert(message: "\(error)",title: "Error loading user avatar")
                                }
                            }
                            dataTask.resume()
                        } else {
                            self.setDefaultPinImg(routeMarker: routeMarker, pin: pin, sportType: "")
                        }
                    })
                } else {
                    self.setDefaultPinImg(routeMarker: routeMarker, pin: pin, sportType: routeMarker.loc_type)
                }
            } else {
                self.setDefaultPinImg(routeMarker: routeMarker, pin: pin, sportType: routeMarker.loc_type)
            }
        }
    }
    func setDefaultPinImg(routeMarker: RouteAnnotation, pin: RoutePoint, sportType: String?){
        if (sportType == "") || (sportType == "RUN") {
            routeMarker.image = UIImage(named: "avatar-run")
        } else if (sportType == "yoga"){
            routeMarker.image = UIImage(named: "pin-yoga")
        } else if (sportType == "swim"){
            routeMarker.image = UIImage(named: "pin-swimming")
        } else {
            routeMarker.image = UIImage(named: "map-pin")
        }
        routeMarker.setDefaultTitle()
        pin.title = routeMarker.title
        pin.AnnoView = routeMarker
        self.mapView.addAnnotation(pin)
        self.actIndicator.stopAnimating()

    }
    func changeTime(selectTimeVC: SelectTimeViewController, selectedTime: String){
//        selectTimeButton.titleLabel?.text = selectedTime
//        refreshDisplayRoute()
        newFilterDay = selectedTime
        filterDataByTime()
    }

    func loadRoute(routeid: String){
        nearByRouteCount += 1
        print("\(nearByRouteCount). Route \(routeid)")
        // QueryCount 2: for each Route, check if Route is GLOBAL ROUTE
        actIndicator.isHidden = false
//        actIndicator.startAnimating()
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
                                        if let start_time = oneEvent.value(forKey: Constants.Event.START_TIME) as? Double{
                                            if start_time >= currentTime {
                                                let event_datetime = NSDate(timeIntervalSince1970: start_time )
                                                let event = Event(route_id: "", start_time: event_datetime as Date)
                                                event.eventId = eventData.key
                                                event.createdBy = oneEvent.value(forKey: Constants.Event.CREATED_BY) as? String
                                                if let participants = oneEvent.value(forKey: Constants.Event.PARTICIPANTS) as? NSDictionary{
                                                    if participants.count > 0 {
                                                        for (key, _) in participants{
                                                            event.participants.append(key as! String)
                                                        }
                                                        event.setFirstUser()
                                                    }
                                                }
                                                if event.participants.count > 0 {
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
                                }
                                route.setFirstEvent()
//                                print("found \(route.events.count) event for \(routeid)")
                                
                            }
                            //FILTER HERE TOO!!
                            if (self.displayingTime == Constants.FilterDay.ALL_TIME_DISPLAY) || ((self.displayingTime == Constants.FilterDay.TODAY_DISPLAY) && (route.todayEvents.count > 0 )) || ((self.displayingTime == Constants.FilterDay.TOMORROW_DISPLAY) && (route.tomorrowEvents.count > 0 )) || ((self.displayingTime == Constants.FilterDay.LATER_DISPLAY) && (route.laterEvents.count > 0 )) {
                                do {
                                    try self.drawRoute(route: route)
                                } catch {
                                    print("Error drawing route")
                                }
                            } else {
                                self.actIndicator.stopAnimating()
                            }
                        })
                        self.allRoute.append(route)
                        self.displayRoute.append(route)
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
            allRoute.removeAll()
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
                // this was mean to check and return from memorry the route that is already available, no need to reload from DB
                // now we load from DB anytime this VC is show so that we have latest data
//                if !self.routesInSpanKey.contains(key!){
//                    self.routesInSpanKey.append(key!)
//                    self.loadRoute(routeid: key!)
//                }
                self.loadRoute(routeid: key!)
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker {
            return typeOptions.count
        } else if pickerView == groupPicker {
            return groupOptions.count
        } else {
            return timeOptions.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        if pickerView == typePicker {
            return typeOptions[row]
        } else if pickerView == groupPicker {
            return groupOptions[row]
        } else {
            return timeOptions[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == typePicker {
            selectTypeButton.titleLabel?.text = typeOptions[row]
            typePicker.isHidden = true
            displayingType = typeOptions[row]
            do {
                try refreshDisplayRoute()
            } catch {
                print("ERROR!!!!!!: \(error)")
            }
        } else if pickerView == groupPicker {
            selectGroupButton.titleLabel?.text = groupOptions[row]
            groupPicker.isHidden = true
        } else {
            selectTimeButton.titleLabel?.text = timeOptions[row]
            newFilterDay = timeOptions[row]
            filterDataByTime()
            timePicker.isHidden = true
        }
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
//        pinView.titleLabel.text = annoView.getNameDistance()
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
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
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
