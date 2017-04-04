//
//  ScheduleVC.swift
//  RaceMe
//
//  Created by LVMBP on 4/4/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ScheduleVC: UIViewController {
    static let CREATE_SCHEDULE = "0"
    static let JOIN_RUN = "1"
    
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            if (FIRAuth.auth()?.currentUser?.uid) != nil{
                let userId = FIRAuth.auth()?.currentUser?.uid
                if (event?.participants.contains(userId!))!{
                    self.view.sendSubview(toBack: joinRunBtn)
                    joinRunBtn.isHidden = true
                } else {
                    readyBtn.isHidden = true
                    cancelBtn.isHidden = true
                }
            }
        }
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addSchedule(_ sender: UIButton) {
    }
    
    @IBAction func joinRun(_ sender: UIButton) {
    }
    @IBAction func readyForRun(_ sender: UIButton) {
    }
    @IBAction func cancelRun(_ sender: UIButton) {
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
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("USERS")
        for userId in (event?.participants)! {
            userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.value as? NSDictionary) != nil{
                    let user = UserObject(snapshot: snapshot)

                    let request = NSMutableURLRequest(url: URL(string: user.photoUrl!)!)
                    request.httpMethod = "GET"
                    let session = URLSession(configuration: URLSessionConfiguration.default)
                    let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                        if error == nil {
                            user.avatarImg = UIImage(data: data!, scale: UIScreen.main.scale)
                            self.participants.append(user)
                            self.tableView.reloadData()
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
        if event != nil {
            return (event?.participants.count)!
        } else {
            return 0
        }
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
