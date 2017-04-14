//
//  RouteDetailVC.swift
//  RaceMe
//
//  Created by LVMBP on 4/3/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
class RouteDetailVC: UIViewController {
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var generalInfoLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var infoSegment: UISegmentedControl!
    @IBOutlet weak var runNowBtn: UIButton!
    @IBOutlet weak var addScheBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var routeId: String!
    var route: Route!
    var event: Event!
    var ref: FIRDatabaseReference!
    var eventRef: FIRDatabaseReference!
    var eventList = [Event]()
    var needReloadEventData = false
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        eventRef = ref.child("EVENTS")
//        loadRoute()
        drawRoute(route: route)
//        loadSchedules()
        eventList = route.events
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        
        mapView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view.
        generalInfoLabel.text = route.name
        if self.route.type == "" || self.route.type == Constants.SPORT_TYPE.RUN {
            runNowBtn.backgroundColor = successColor
            runNowBtn.layer.cornerRadius = 3
            addScheBtn.backgroundColor = warningColor
            addScheBtn.layer.cornerRadius = 3
            distanceLabel.text =  "\(String(format: "%.2f", Utils.distanceInKm(distanceInMeter: route.distance))) km"
        } else {
            distanceLabel.text =  "\(route.type)"
            setStartLoc(coordinate: route.locations.first!)
        }
        
    }
    
    @IBAction func addSchedule(_ sender: UIButton) {
        let scheduleVC = ScheduleVC(nibName: "ScheduleVC", bundle: nil)
        scheduleVC.route = route
        scheduleVC.viewingType = ScheduleVC.CREATE_SCHEDULE
        scheduleVC.delegate = self
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    @IBAction func runNow(_ sender: UIButton) {
        //TODO: dismiss this VC and switch to RunTrackingVC with routeId chosen is this route's id
        let recordNavVC = RecordViewController()
        recordNavVC.selectedRoute = route
        navigationController?.pushViewController(recordNavVC, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        needReloadEventData = false
    }
    deinit {
        if ref != nil{
            ref.removeAllObservers()
            eventRef.removeAllObservers()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if !needReloadEventData {
//            eventList.removeAll()
        loadSchedules()
//            eventList = route.events
//            self.tableView.reloadData()
//        }
    }
    func loadRoute(){
        self.ref.child(Constants.PublicRoute.TABLE_NAME+"/"+routeId).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
        let route = Route(locationsData: snapshot)
        route.routeId = self.routeId
        if route.locations.count > 0 {
            self.drawRoute(route: route)
        }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func drawRoute(route: Route){
        if self.route.type != "" && self.route.type != Constants.SPORT_TYPE.RUN {
            let span = MKCoordinateSpanMake(0.009, 0.009)
            let myRegion = MKCoordinateRegion(center: route.locations.first!, span: span)
            mapView.setRegion(myRegion, animated: false)
            mapView.setCenter((route.locations.first)!, animated: true)
        }
        let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
        mapView.add(myPolyline)
    }
    func loadSchedules(){
        self.ref.child(Constants.Event.TABLE_NAME).queryOrdered(byChild: Constants.Event.ROUTE_ID).queryEqual(toValue: routeId).observe(.value, with: { (snapshot) in
            if snapshot.hasChildren(){
                self.eventList.removeAll()
                self.route.events.removeAll()
                let currentTime = NSDate().timeIntervalSince1970
//                print("TIME is \(currentTime) now")
                var eventCount = 0
                for eventData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    if let oneEvent = eventData.value as? NSDictionary{
                        if let start_time = oneEvent.value(forKey: Constants.Event.START_TIME) as? Double {
                            if start_time >= currentTime {
                                eventCount += 1
                                let event_datetime = NSDate(timeIntervalSince1970: start_time )
                                let event = Event(route_id: self.routeId, start_time: event_datetime as Date)
                                event.eventId = eventData.ref.key
                                event.createdBy = oneEvent.value(forKey: Constants.Event.CREATED_BY) as? String
                                if let distance = oneEvent.value(forKey: Constants.Event.TARGET_DISTANT) as? Double{
                                    event.targetDistance = distance
                                }
                                if let startLoc = oneEvent.value(forKey: Constants.Event.START_LOC) as? NSDictionary{
                                    let lat = startLoc.value(forKey: Constants.Location.LATITUDE) as? Double
                                    let lng = startLoc.value(forKey: Constants.Location.LONGTITUDE) as? Double
                                    if lat != nil && lng != nil {
                                        event.startLoc = CLLocationCoordinate2D(latitude: lat!,longitude: lng!)
                                    }
                                }
                                var runList = ""
                                if let participants = oneEvent.value(forKey: Constants.Event.PARTICIPANTS) as? NSDictionary{
                                    for (key, _) in participants{
                                        event.participants.append(key as! String)
                                        runList.append("\(key) ")
                                    }
                                }
                                //.setFirstUser DOESN'T WORK, PERHAPS IT TAKES TO LONG TO LOAD USER PHOTO
                                //                            event.setFirstUser()
                                if event.participants.count > 0 {
                                    FIRDatabase.database().reference().child("USERS/\(event.participants[0])").observeSingleEvent(of: .value, with: { (snapshot) in
                                        event.firstUser = UserObject(snapshot: snapshot)
                                        
                                        let request = NSMutableURLRequest(url: URL(string: (event.firstUser?.photoUrl!)!)!)
                                        request.httpMethod = "GET"
                                        
                                        let session = URLSession(configuration: URLSessionConfiguration.default)
                                        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                                            if error == nil {
                                                DispatchQueue.main.async {
                                                    event.firstUser?.avatarImg = UIImage(data: data!, scale: UIScreen.main.scale)
                                                    self.eventList.append(event)
                                                    var strFirstName = "NIL"
                                                    if let user = event.firstUser as UserObject?{
                                                        strFirstName = user.displayName!
                                                    }
                                                    print("Event \(eventCount): Runners: "+runList+". FIRST RUNNER: \(strFirstName)")
                                                    self.route.events.append(event)
                                                    self.route.setFirstEvent()
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                        dataTask.resume()
                                        
                                    })
                                }
                            } else {
                                //                            print("starttime \(start_time) is smalled than current time")
                            }
                        }
                    }
                }
//                print(self.eventList)
                self.route.events = self.eventList
                self.route.setFirstEvent()
//                print("start refreshing data")
                self.tableView.reloadData()
            }
        })
    }
    func setStartLoc(coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        if route.address == "" {
            annotation.title = "Class location"
        } else {
            annotation.title = route.address
        }
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }
    func loadLeaderboard(){
        
    }
}
extension RouteDetailVC: MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, ScheduleVCDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = dangerColor
        renderer.lineWidth = 4.0

        if self.route.type == "" || self.route.type == Constants.SPORT_TYPE.RUN {
            let mapRect = MKPolygon(points: renderer.polyline.points(), count: renderer.polyline.pointCount)
            mapView.setVisibleMapRect(mapRect.boundingMapRect, edgePadding: UIEdgeInsets(top: 20.0,left: 20.0,bottom: 20.0,right: 20.0), animated: false)
        }
        return renderer
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "startPin")
            pinAnnotationView.pinTintColor = .purple
            pinAnnotationView.isDraggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            return pinAnnotationView
        }
        return nil
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return eventList.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        let event = eventList[indexPath.row]
        var strFirstName = "NIL"
        if let user = event.firstUser as UserObject?{
            strFirstName = user.displayName!
        }
//        print("\(indexPath.row) has \(event.participants.count) users. First is: \(strFirstName)")
//        cell.dateLabel.text = "\(event.start_time.toStringWithoutSecond())"
        cell.dateLabel.text = "\(event.start_time.friendlyDate())"
        
        var strRunnerNum = " will run alone"
        if event.participants.count > 1{
            
            strRunnerNum = " and \(event.participants.count-1) person"
        }

        if let user = event.firstUser {
            cell.runnersLabel.text = "\(user.displayName!)"+strRunnerNum
            cell.avatarImg.image = user.avatarImg
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(eventList)
//        print("selected Item: \(indexPath.row)")
        let scheduleVC = ScheduleVC(nibName: "ScheduleVC", bundle: nil)
        scheduleVC.route = route
        let event = eventList[indexPath.row]
        scheduleVC.event = event
        scheduleVC.viewingType = ScheduleVC.JOIN_RUN
        scheduleVC.delegate = self
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    func reloadEventForRoute(scheduleVC: ScheduleVC, reload: Bool) {
        if reload {
            loadSchedules()
            needReloadEventData = true
        }
    }
    
    func getRegionForRoute(route: Route) -> MKCoordinateRegion {
        let locations = route.locations
        let firstPointCoordinate = locations[0]
        
        var minLatitude: Double!
        var minLongitude: Double!
        var maxLatitude: Double!
        var maxLongitude: Double!
        
        for location in locations {
            let locationCoordinate = location
            minLatitude = min(firstPointCoordinate.latitude, locationCoordinate.latitude)
            minLongitude = min(firstPointCoordinate.longitude, locationCoordinate.longitude)
            maxLatitude = max(firstPointCoordinate.latitude, locationCoordinate.latitude)
            maxLongitude = max(firstPointCoordinate.longitude, locationCoordinate.longitude)
        }
        
        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        let latDelta = (maxLatitude - minLatitude) * 2
        let longDelta = (maxLongitude - minLongitude) * 2
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude), span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
    }
}
extension Date {
    func toDateOnly() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: self)
    }

    func toStringWithoutSecond() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
        return dateFormatter.string(from: self)
    }
    func friendlyDate() -> String {
        if NSCalendar.current.isDateInToday(self){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            return "Today at " + dateFormatter.string(from: self)

        } else if NSCalendar.current.isDateInTomorrow(self){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            return "Tomorrow at" + dateFormatter.string(from: self)

        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
            return dateFormatter.string(from: self)

        }
    }
}
