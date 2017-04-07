//
//  ScheduleVC.swift
//  RaceMe
//
//  Created by LVMBP on 4/4/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
protocol ScheduleVCDelegate {
    func reloadEventForRoute(scheduleVC: ScheduleVC, reload: Bool)
}
class ScheduleVC: UIViewController {
    static let CREATE_SCHEDULE = "0"
    static let JOIN_RUN = "1"
    var ref: FIRDatabaseReference!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var readyBtn: UIButton!
    @IBOutlet weak var joinRunBtn: UIButton!
    @IBOutlet weak var generalInfoLabel: UILabel!
    @IBOutlet weak var startPosWarnLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var addScheBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var route: Route!
    var event: Event?
    var viewingType = ScheduleVC.CREATE_SCHEDULE
    var participants = [UserObject]()
    var userId: String!
    var currentUser: UserObject!
    var delegate: ScheduleVCDelegate!
    var routeNeedReloadEvent = false
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        mapView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ParticipantViewCell", bundle: nil), forCellReuseIdentifier: "ParticipantViewCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        addScheBtn.backgroundColor = UIColor.orange
        addScheBtn.layer.cornerRadius = 5
        joinRunBtn.backgroundColor = UIColor.orange
        joinRunBtn.layer.cornerRadius = 5
        readyBtn.backgroundColor = UIColor(136, 192, 87)
        readyBtn.layer.cornerRadius = 5
        cancelBtn.backgroundColor = UIColor.red
        cancelBtn.layer.cornerRadius = 5
        //        if FIRAuth.auth()?.currentUser != nil {
        //            self.view.sendSubview(toBack: readyBtn)
        //            self.view.sendSubview(toBack: cancelBtn)
        //        } else {
        //        }
        userId = FIRAuth.auth()?.currentUser?.uid
        if viewingType == ScheduleVC.CREATE_SCHEDULE{
            self.view.sendSubview(toBack: joinRunBtn)
            self.view.sendSubview(toBack: readyBtn)
            self.view.sendSubview(toBack: cancelBtn)
            joinRunBtn.isHidden = true
            readyBtn.isHidden = true
            cancelBtn.isHidden = true
        } else {
            loadParticipants()
            self.view.sendSubview(toBack: addScheBtn)
            addScheBtn.isHidden = true
                if (event?.participants.contains(userId!))!{
                    self.view.sendSubview(toBack: joinRunBtn)
                    joinRunBtn.isHidden = true
                } else {
                    readyBtn.isHidden = true
                    cancelBtn.isHidden = true
                }
        }
        loadCurrentUser()
        //        if (event?.participants.contains((FIRAuth.auth()?.currentUser?.uid)!))!{
        //            if viewingType == ScheduleVC.CREATE_SCHEDULE{
        //                self.view.sendSubview(toBack: joinRunBtn)
        //            } else {
        //                self.view.sendSubview(toBack: addScheBtn)
        //            }
        //        } else {
        //            self.view.sendSubview(toBack: readyBtn)
        //            self.view.sendSubview(toBack: cancelBtn)
        //        }
        drawRoute(route: route)
        // Do any additional setup after loading the view.
    }

    func loadCurrentUser(){
        print("current user id: \(userId)")
        _ = ref.child("USERS/\(userId!)").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value as? NSDictionary) != nil{
            self.currentUser = UserObject(snapshot: snapshot)
            
            let request = NSMutableURLRequest(url: URL(string: self.currentUser.photoUrl!)!)
            request.httpMethod = "GET"
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                if error == nil {
                        self.currentUser.avatarImg = UIImage(data: data!, scale: UIScreen.main.scale)
                }
            }
            dataTask.resume()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addSchedule(_ sender: UIButton) {
        self.view.sendSubview(toBack: addScheBtn)
        addScheBtn.isHidden = true
        
        let eventRef = ref.child(Constants.Event.TABLE_NAME).childByAutoId()
        eventRef.child(Constants.Event.ROUTE_ID).setValue("\(route.routeId!)")
        eventRef.child(Constants.Event.START_TIME).setValue(startDatePicker.date.timeIntervalSince1970)
        eventRef.child(Constants.Event.PARTICIPANTS).child(userId!).setValue(true)
        participants.append(currentUser)
        self.event = Event(route_id: route.routeId!, start_time: startDatePicker.date)
        self.event?.eventId = eventRef.key
        self.event?.setFirstUser(user: currentUser)
        self.event?.participants.append(userId)
        route.events.append(self.event!)
        tableView.reloadData()
        self.view.bringSubview(toFront: readyBtn)
        self.view.bringSubview(toFront: cancelBtn)
        readyBtn.isHidden = false
        cancelBtn.isHidden = false
    }
    
    @IBAction func joinRun(_ sender: UIButton) {
        self.view.sendSubview(toBack: joinRunBtn)
        joinRunBtn.isHidden = true
        let eventRef = ref.child("\(Constants.Event.TABLE_NAME)/\(self.event!.eventId!)/\(Constants.Event.PARTICIPANTS)")
        eventRef.child(userId!).setValue(true)
        self.event?.participants.append(userId)
        participants.append(currentUser)
        tableView.reloadData()
        self.view.bringSubview(toFront: readyBtn)
        self.view.bringSubview(toFront: cancelBtn)
        readyBtn.isHidden = false
        cancelBtn.isHidden = false
    }
    @IBAction func readyForRun(_ sender: UIButton) {
    }
    @IBAction func cancelRun(_ sender: UIButton) {
        let eventPath = "\(Constants.Event.TABLE_NAME)/\(self.event!.eventId!)"
        print(eventPath)
        let eventRef = ref.child(eventPath)
        let userInEventPath = "\(Constants.Event.PARTICIPANTS)/\(userId!)"
        print(userInEventPath)
        let userRecord = eventRef.child(userInEventPath)
        print(userRecord)
        userRecord.removeValue { (error, refer) in
            if error != nil {
                print(error!)
            } else {
                let index = self.event?.participants.index(of: self.userId)!
                self.event?.participants.remove(at: index!)
                self.participants.remove(at: index!)
                
                self.tableView.reloadData()
                
                self.view.sendSubview(toBack: self.readyBtn)
                self.readyBtn.isHidden = true
                self.view.sendSubview(toBack: self.cancelBtn)
                self.cancelBtn.isHidden = true
                if self.participants.count > 0 {
                    self.event?.setFirstUser()
                    self.view.bringSubview(toFront: self.joinRunBtn)
                    self.joinRunBtn.isHidden = false
                } else {
                    eventRef.removeValue()
                    self.routeNeedReloadEvent = true
                    self.view.bringSubview(toFront: self.addScheBtn)
                    self.addScheBtn.isHidden = false
                }
            }
        }

    }
    override func viewWillDisappear(_ animated: Bool) {
        if routeNeedReloadEvent{
            delegate.reloadEventForRoute(scheduleVC: self, reload: true)
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
    
    func loadParticipants(){
        
        let userRef = ref.child("USERS")
        for userId in (event?.participants)! {
            userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.value as? NSDictionary) != nil{
                    let user = UserObject(snapshot: snapshot)
                    user.avatarImg = UIImage(named: "default-avatar")!
                    let request = NSMutableURLRequest(url: URL(string: user.photoUrl!)!)
                    request.httpMethod = "GET"
                    let session = URLSession(configuration: URLSessionConfiguration.default)
                    let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                        if error == nil {
                            user.avatarImg = UIImage(data: data!, scale: UIScreen.main.scale)
                            DispatchQueue.main.async {
                                self.participants.append(user)
                                self.tableView.reloadData()
                            }
                        }
                    }
                    dataTask.resume()
                }
            })
        }
    }
}
extension ScheduleVC: MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return participants.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantViewCell", for: indexPath) as! ParticipantViewCell
        if participants.count > 0 {
            let participant = participants[indexPath.row]
            cell.statusLabel.text = participant.displayName
            if let avatarImg = participant.avatarImg{
                cell.avatarImg.image = avatarImg
            }
        }
        return cell
        //        let participant = event?.participants[indexPath.row]
        //        cell.statusLabel.text = participant
    }
}
