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
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref.removeAllObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        needReloadEventData = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !needReloadEventData {
            eventList.removeAll()
            eventList = route.events
            self.tableView.reloadData()
        }
    }
    func loadRoute(){
        self.ref.child(Constants.Route.TABLE_NAME+"/"+routeId).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
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
        mapView.setRegion(myRegion, animated: false)
        let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
        mapView.add(myPolyline)
        //TODO: set center to the middle point of the route. HTF can I calculate that?
        mapView.setCenter((route.locations.first)!, animated: true)
    }
    func loadSchedules(){
        self.eventList.removeAll()
        self.route.events.removeAll()
        self.ref.child("EVENTS/").queryOrdered(byChild: "route_id").queryEqual(toValue: routeId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren(){
                let currentTime = NSDate().timeIntervalSince1970
                print("TIME is \(currentTime) now")
                print(snapshot)
                for eventData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    if let oneEvent = eventData.value as? NSDictionary{
                        let start_time = oneEvent.value(forKey: "start_time") as! Double
                        if start_time >= currentTime {
                            let event_datetime = NSDate(timeIntervalSince1970: start_time )
                            let event = Event(route_id: "", start_time: event_datetime as Date)
                            if let participants = oneEvent.value(forKey: "participants") as? NSDictionary{
                                for (key, _) in participants{
                                    event.participants.append(key as! String)
                                    event.eventId = eventData.ref.key
                                }
                            }
                            event.setFirstUser()
                            self.eventList.append(event)
                        } else {
                            print("starttime \(start_time) is smalled than current time")
                        }
                    }
                }
                print(self.eventList)
                self.route.events = self.eventList
                self.route.setFirstEvent()
                print("start refreshing data")
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
        print(eventList)
        print("selected Item: \(indexPath.row)")
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
}
extension Date {
    func toStringWithoutSecond() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy' at ' h:mm a."
        return dateFormatter.string(from: self)
    }
}
