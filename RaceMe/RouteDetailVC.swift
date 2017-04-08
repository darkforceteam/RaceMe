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
        mapView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        runNowBtn.backgroundColor = UIColor(136, 192, 87)
        runNowBtn.layer.cornerRadius = 5
        addScheBtn.backgroundColor = UIColor.orange
        addScheBtn.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
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
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        needReloadEventData = false
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
        let span = MKCoordinateSpanMake(0.009, 0.009)
        let myRegion = MKCoordinateRegion(center: route.locations.first!, span: span)
//        let myRegion = getRegionForRoute(route: route)
        mapView.setRegion(myRegion, animated: false)
        let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
        mapView.add(myPolyline)
        //TODO: set center to the middle point of the route. HTF can I calculate that?
        mapView.setCenter((route.locations.first)!, animated: true)
    }
    func loadSchedules(){
        self.ref.child("EVENTS/").queryOrdered(byChild: "route_id").queryEqual(toValue: routeId).observe(.value, with: { (snapshot) in
            if snapshot.hasChildren(){
                self.eventList.removeAll()
                self.route.events.removeAll()
                let currentTime = NSDate().timeIntervalSince1970
//                print("TIME is \(currentTime) now")
                var eventCount = 0
                for eventData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    if let oneEvent = eventData.value as? NSDictionary{
                        let start_time = oneEvent.value(forKey: "start_time") as! Double
                        if start_time >= currentTime {
                            eventCount += 1
                            let event_datetime = NSDate(timeIntervalSince1970: start_time )
                            let event = Event(route_id: "", start_time: event_datetime as Date)
                            event.eventId = eventData.ref.key
                            var runList = ""
                            if let participants = oneEvent.value(forKey: "participants") as? NSDictionary{
                                for (key, _) in participants{
                                    event.participants.append(key as! String)
                                    runList.append("\(key) ")
                                }
                            }
                            
                            event.setFirstUser()
                            self.eventList.append(event)
                            print("Event \(eventCount): Runners: "+runList+". FIRST RUNNER: \(event.firstUser?.displayName)")
                        } else {
//                            print("starttime \(start_time) is smalled than current time")
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
    
    func loadLeaderboard(){
        
    }
}
extension RouteDetailVC: MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, ScheduleVCDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return eventList.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        let event = eventList[indexPath.row]
        
        cell.dateLabel.text = "\(event.start_time.toStringWithoutSecond())"
        
        var strRunnerNum = " will run alone"
        if event.participants.count > 1{
            
            strRunnerNum = " and \(event.participants.count-1) runners"
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
    func toStringWithoutSecond() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy' at ' h:mm a."
        return dateFormatter.string(from: self)
    }
}
