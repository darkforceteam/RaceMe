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
    
    @IBOutlet weak var tableView: UITableView!
    var routeId: String!
    var ref: FIRDatabaseReference!
    var eventRef: FIRDatabaseReference!
    var eventList = [Event]()
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        eventRef = ref.child("EVENTS")
        loadRoute()
        loadSchedules()
        mapView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
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
    }
    func loadSchedules(){
        self.ref.child("EVENTS/").queryOrdered(byChild: "route_id").queryEqual(toValue: routeId).observeSingleEvent(of: .value, with: { (snapshot) in
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
                            self.eventList.append(event)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func loadLeaderboard(){
        
    }
}
extension RouteDetailVC: MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource{
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
            strRunnerNum = " and \(event.participants.count) runners"
        }
        
        self.ref.child("USERS/"+event.participants[0]).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value as? NSDictionary) != nil{
                let user = User(snapshot: snapshot)
                cell.runnersLabel.text = "\(user.displayName!)"+strRunnerNum
            }
        })
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
extension Date {
    func toStringWithoutSecond() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy' at ' h:mm a."
        return dateFormatter.string(from: self)
    }
}
