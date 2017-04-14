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
    var eventRef: FIRDatabaseReference!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var dateTextField: UITextField!
    var datePicker = UIDatePicker()
    @IBOutlet weak var readyBtn: UIButton!
    @IBOutlet weak var joinRunBtn: UIButton!
    @IBOutlet weak var generalInfoLabel: UILabel!
    @IBOutlet weak var startPosWarnLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var coundownLabel: UILabel!
    @IBOutlet weak var targetDistTextField: UITextField!
    @IBOutlet weak var addScheBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var route: Route!
    var event: Event?
    var viewingType = ScheduleVC.CREATE_SCHEDULE
    var participants = [UserObject]()
    var userId: String!
    var currentUser: UserObject!
    var creator: UserObject!
    var delegate: ScheduleVCDelegate!
    var startDate: Date!
    var targetDistance: Int?
    var creatorId: String?
    var timer: Timer?
    var startLocSet = false
    var startLoc: CLLocationCoordinate2D?
    
    @IBOutlet weak var loadCoverAct: UIActivityIndicatorView!

    @IBOutlet weak var nextSessionLabel: UILabel!
    @IBOutlet weak var creatorImgView: UIImageView!
    @IBOutlet weak var classDescripLabel: UILabel!
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var creatorInfoView: UIView!
    @IBOutlet weak var coverImgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        if event != nil{
            mapView.isScrollEnabled = false
            mapView.isZoomEnabled = false
            mapView.isPitchEnabled = false
            mapView.isRotateEnabled = false
            mapView.isUserInteractionEnabled = false
            startPosWarnLabel.isHidden = true
            
            let eventPath = "\(Constants.Event.TABLE_NAME)/\(self.event!.eventId!)"
            eventRef = ref.child(eventPath)
            targetDistTextField.isEnabled = false
            if event?.targetDistance != nil {
                startTimeLabel.isHidden = false
                dateTextField.isHidden = false
                let distStr = String(format: "%.2f", Utils.distanceInKm(distanceInMeter: Double((event?.targetDistance)!)))
                
                targetDistTextField.text = distStr
            } else {
                let distStr = String(format: "%.2f", Utils.distanceInKm(distanceInMeter: route.distance))
                targetDistTextField.text = distStr
            }
            if event?.start_time != nil {
                dateTextField.isHidden = true
                startTimeLabel.isHidden = true
                startCountDown()
            }
            if event?.startLoc != nil {
                setStartLoc(coordinate: (event?.startLoc)!)
            } else if route.locations.count > 0 {
                setStartLoc(coordinate: route.locations.first!)
            }
            
            if self.route.type == "" || self.route.type == Constants.SPORT_TYPE.RUN {
                creatorInfoView.isHidden = true
            } else {
                loadCoverAct.hidesWhenStopped = true
                let creatorAvatarGesture = UITapGestureRecognizer(target: self, action: #selector(openCreatorView))
                let coverGesture = UITapGestureRecognizer(target: self, action: #selector(openCreatorView))
                if event?.createdBy != nil {
                    loadCreator(creatorId: event!.createdBy!)
                    creatorImgView.isUserInteractionEnabled = true
                    creatorImgView.addGestureRecognizer(creatorAvatarGesture)
                }
                if route.bannerUrl != "" {
                    loadCoverAct.startAnimating()
                    loadBanner(imgUrl: route.bannerUrl)
                    coverImgView.isUserInteractionEnabled = true
                    coverImgView.addGestureRecognizer(coverGesture)
                }
            }
        } else {
            coundownLabel.isHidden = true
            creatorInfoView.isHidden = true
            let distStr = String(format: "%.2f", Utils.distanceInKm(distanceInMeter: route.distance))
            targetDistTextField.text = distStr
        }

        mapView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ParticipantViewCell", bundle: nil), forCellReuseIdentifier: "ParticipantViewCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        addScheBtn.backgroundColor = warningColor
        addScheBtn.layer.cornerRadius = 3
        joinRunBtn.backgroundColor = warningColor
        joinRunBtn.layer.cornerRadius = 3
        readyBtn.backgroundColor = successColor
        readyBtn.layer.cornerRadius = 3
        cancelBtn.backgroundColor = dangerColor
        cancelBtn.layer.cornerRadius = 3
        
        setupDatePicker()
        setupInputComponents()
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
    override func viewWillAppear(_ animated: Bool) {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    func mapTapped(gestureRecognizer: UIGestureRecognizer){
        startPosWarnLabel.isHidden = true
        if !startLocSet {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            setStartLoc(coordinate: newCoordinate)
        }
    }
    func setStartLoc(coordinate: CLLocationCoordinate2D){
        startLoc = coordinate
        let annotation = MKPointAnnotation()
        annotation.title = "Start location"
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        startLocSet = true
    }
    func setupInputComponents(){
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self, action: #selector(distantEntered))
        
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        targetDistTextField.inputAccessoryView = toolbarDone
    }
    func distantEntered() {
        targetDistTextField.resignFirstResponder()
    }
    func setupDatePicker(){
        var components = DateComponents()
        components.minute = 30
        let minDate = Calendar.current.date(byAdding: components, to: Date())
        
        components.day = 365
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.datePickerMode = .dateAndTime
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = primaryColor
        toolBar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DatePickerSettingCell.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DatePickerSettingCell.donePicker))
        toolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = toolBar
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        components.day = 1
        startDate = Calendar.current.date(byAdding: components, to: Date())
        dateTextField.text = "\(dateFormatter.string(from: startDate!))"
    }
    func donePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateTextField.text = "\(dateFormatter.string(from: datePicker.date))"
        startDate = datePicker.date
        dateTextField.resignFirstResponder()
    }
    func cancelPicker() {
        dateTextField.resignFirstResponder()
    }
    func startCountDown(){
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    func updateCounter(){
        let now = Date()
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: (event?.start_time)!)
//        print(diff)
        if now < (event?.start_time)!
        {
            coundownLabel.text = "\(diff)".uppercased()
        } else {
            //RACE TIME!
            coundownLabel.text = "The run starts now!!!"
        }
    }
    func loadCurrentUser(){
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
    func loadBanner(imgUrl: String){
        var session = URLSession.shared
        var task = URLSessionDataTask()
        let request = NSMutableURLRequest(url: URL(string: imgUrl)!)
        request.httpMethod = "GET"
        session = URLSession(configuration: URLSessionConfiguration.default)
        task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error == nil {
                let img = UIImage(data: data!, scale: UIScreen.main.scale)
                self.coverImgView.image = img
                self.loadCoverAct.stopAnimating()
            }
        }
        task.resume()
    }
    func loadCreator(creatorId: String){
        _ = self.ref.child("USERS/\(creatorId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value as? NSDictionary) != nil{
                self.creator = UserObject(snapshot: snapshot)
                //display creator name, bio and next schedule
                self.nextSessionLabel.text = self.event?.start_time.friendlyDate()
                
                self.classNameLabel.text = self.creator.displayName
                self.classDescripLabel.text = self.creator.bio
                let request = NSMutableURLRequest(url: URL(string: self.creator.photoUrl!)!)
                request.httpMethod = "GET"
                let session = URLSession(configuration: URLSessionConfiguration.default)
                let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                    if error == nil {
                        self.creator.avatarImg = UIImage(data: data!, scale: UIScreen.main.scale)
                        self.creatorImgView.image = UIImage(data: data!, scale: UIScreen.main.scale)
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
        
        eventRef = ref.child(Constants.Event.TABLE_NAME).childByAutoId()
        eventRef.child(Constants.Event.ROUTE_ID).setValue("\(route.routeId!)")
        eventRef.child(Constants.Event.START_TIME).setValue(startDate.timeIntervalSince1970)
        eventRef.child(Constants.Event.PARTICIPANTS).child(userId!).setValue(false)
        eventRef.child(Constants.Event.CREATED_BY).setValue(userId)
        if targetDistTextField.text != "" {
            eventRef.child(Constants.Event.TARGET_DISTANT).setValue(Int(targetDistTextField.text!))
        }
        eventRef.child(Constants.Event.START_LOC).child(Constants.Location.LATITUDE).setValue(startLoc?.latitude)
        eventRef.child(Constants.Event.START_LOC).child(Constants.Location.LONGTITUDE).setValue(startLoc?.longitude)
        participants.append(currentUser)
        self.event = Event(route_id: route.routeId!, start_time: startDate)
        self.event?.eventId = eventRef.key
        self.event?.setFirstUser(user: currentUser)
        self.event?.participants.append(userId)
        self.event?.createdBy = userId
        if targetDistTextField.text != ""
        {
            self.event?.targetDistance = Double(targetDistTextField.text!)
        }
        self.event?.startLoc = startLoc
        startCountDown()
        route.events.append(self.event!)
        tableView.reloadData()
        self.view.bringSubview(toFront: readyBtn)
        self.view.bringSubview(toFront: cancelBtn)
        readyBtn.isHidden = false
        cancelBtn.isHidden = false
        targetDistTextField.isEnabled = false
        coundownLabel.isHidden = false
        dateTextField.isHidden = true
        startTimeLabel.isHidden = true
    }
    
    @IBAction func joinRun(_ sender: UIButton) {
        self.view.sendSubview(toBack: joinRunBtn)
        joinRunBtn.isHidden = true
//        let eventRef = ref.child("\(Constants.Event.TABLE_NAME)/\(self.event!.eventId!)/\(Constants.Event.PARTICIPANTS)")
//        eventRef.child(userId!).setValue(true)
        eventRef.child("\(Constants.Event.PARTICIPANTS)/\(userId!)").setValue(false)
        self.event?.participants.append(userId)
        participants.append(currentUser)
        tableView.reloadData()
        self.view.bringSubview(toFront: readyBtn)
        self.view.bringSubview(toFront: cancelBtn)
        readyBtn.isHidden = false
        cancelBtn.isHidden = false
    }
    @IBAction func readyForRun(_ sender: UIButton) {
        let participantRef = ref.child(Constants.Event.TABLE_NAME).child((event?.eventId)!).child(Constants.Event.PARTICIPANTS).child(userId!)
        participantRef.setValue(true)
        readyBtn.isHidden = true
    }
    @IBAction func cancelRun(_ sender: UIButton) {
//        let eventPath = "\(Constants.Event.TABLE_NAME)/\(self.event!.eventId!)"
////        print(eventPath)
//        let eventRef = ref.child(eventPath)
        let userInEventPath = "\(Constants.Event.PARTICIPANTS)/\(userId!)"
//        print(userInEventPath)
        let userRecord = eventRef.child(userInEventPath)
//        print(userRecord)
        userRecord.removeValue { (error, refer) in
            if error != nil {
                print(error!)
            } else {
//                let index = self.event?.participants.index(of: self.userId)!
//                self.event?.participants.remove(at: index!)
//                print(self.event?.participants)
//                self.participants.remove(at: index!)
//                print("///////////")
//                print(self.participants)
//                self.tableView.reloadData()
                
                self.view.sendSubview(toBack: self.readyBtn)
                self.readyBtn.isHidden = true
                self.view.sendSubview(toBack: self.cancelBtn)
                self.cancelBtn.isHidden = true
                if self.participants.count > 0 {
                    self.view.bringSubview(toFront: self.joinRunBtn)
                    self.joinRunBtn.isHidden = false
                } else {
                    self.deleteEvent()
                    self.targetDistTextField.isEnabled = true
                    self.dateTextField.isHidden = false
                    self.startTimeLabel.isHidden = false
                    self.coundownLabel.isHidden = true
                    self.view.bringSubview(toFront: self.addScheBtn)
                    self.addScheBtn.isHidden = false
                }
            }
        }

    }
    override func viewWillDisappear(_ animated: Bool) {
//        if routeNeedReloadEvent{
//            delegate.reloadEventForRoute(scheduleVC: self, reload: true)
//        }
    }
    deinit {
        if ref != nil{
            ref.removeAllObservers()
            if eventRef != nil
            {
                eventRef.removeAllObservers()
            }
        }
    }
    func deleteEvent() {
        if self.participants.count > 0 {
            self.event?.setFirstUser()
        } else {
            if eventRef != nil{
                eventRef.removeValue(){ (error, refer) in
                    if error != nil {
                        print(error!)
                    } else {
                        self.route.removeEvent(eventId: (self.event?.eventId)!)
                    }
                }
            }
        }
    }
    func drawRoute(route: Route){
//        let span = MKCoordinateSpanMake(0.009, 0.009)
//        let myRegion = MKCoordinateRegion(center: route.locations.first!, span: span)
//        mapView.setRegion(myRegion, animated: false)
        let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
        mapView.add(myPolyline)
        //TODO: set center to the middle point of the route. HTF can I calculate that?
//        mapView.setCenter((route.locations.first)!, animated: true)
    }
    
    func loadParticipants(){
        let userRef = ref.child(Constants.USERS.table_name)
        let eventPartRef = ref.child(Constants.Event.TABLE_NAME).child((event?.eventId)!)
        eventPartRef.observe(.value, with:  { (snapshot) in
            if let data = snapshot.value as? NSDictionary{
                self.participants.removeAll()
                self.event?.participants.removeAll()
                if let participants = data.value(forKey: Constants.Event.PARTICIPANTS) as? NSDictionary{
                    for (key, value) in participants{
                        userRef.child(key as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                            if (snapshot.value as? NSDictionary) != nil{
                                let user = UserObject(snapshot: snapshot)
                                user.isReady = value as! Bool
                                //                    user.avatarImg = UIImage(named: "default-avatar")!
                                let request = NSMutableURLRequest(url: URL(string: user.photoUrl!)!)
                                request.httpMethod = "GET"
                                let session = URLSession(configuration: URLSessionConfiguration.default)
                                let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                                    if error == nil {
                                        user.avatarImg = UIImage(data: data!, scale: UIScreen.main.scale)
                                        DispatchQueue.main.async {
                                            self.participants.append(user)
                                            self.event?.participants.append(user.uid)
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
        })
    }

    func openCreatorView()
    {
        let profileViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileViewController.uid = creator.uid
        navigationController?.pushViewController(profileViewController, animated: true)
    }
}
extension ScheduleVC: MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = dangerColor
        renderer.lineWidth = 4.0
        
        let mapRect = MKPolygon(points: renderer.polyline.points(), count: renderer.polyline.pointCount)
        mapView.setVisibleMapRect(mapRect.boundingMapRect, edgePadding: UIEdgeInsets(top: 20.0,left: 20.0,bottom: 20.0,right: 20.0), animated: false)
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
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if (newState == MKAnnotationViewDragState.ending) {
            startLoc = view.annotation?.coordinate
        }
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
            if participant.isReady == true {
                cell.statusImg.image = UIImage(named: "ready")!
            }
        }
        return cell
        //        let participant = event?.participants[indexPath.row]
        //        cell.statusLabel.text = participant
    }
}
extension ScheduleVC: UIGestureRecognizerDelegate{
    
}
