////
////  TrackingViewController.swift
////  RaceMe
////
////  Created by vulong.com on 3/19/17.
////  Copyright © 2017 CoderSchool. All rights reserved.
////
//
//import UIKit
//import CoreLocation
//import HealthKit
//import FirebaseDatabase
//
//class TrackingViewController: UIViewController {
//    let WO_STARTED = 1
//    let WO_STOPPED = 2
//    let WO_SAVED = 3
//    var workOutStatus = 0
//    
//    var ref: FIRDatabaseReference!
//    fileprivate var _refHandle: FIRDatabaseHandle!
//    
//    var duration = 0.0
//    var distanceKm = 0.0
//    var newWorkOut: Workout?
//    @IBOutlet weak var currentPaceLabel: UILabel!
//    @IBOutlet weak var distanceLabel: UILabel!
//    @IBOutlet weak var durationLabel: UILabel!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view.
//        configureDatabase()
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        locationManager.requestAlwaysAuthorization()
//    }
//    
//    lazy var locationManager: CLLocationManager = {
//        var _locationManager = CLLocationManager()
//        _locationManager.delegate = self
//        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        _locationManager.activityType = .fitness
//        // Movement threshold for new events
//        _locationManager.distanceFilter = 10.0
//        return _locationManager
//    }()
//    
//    lazy var locations = [CLLocation]()
//    lazy var timer = Timer()
//    
//    @IBAction func startRun(_ sender: UIButton) {
//        duration = 0.0
//        distanceKm = 0.0
//        locations.removeAll(keepingCapacity: false)
//        newWorkOut = Workout.init(userId: "123456", type: "RUN", startTime: "111111", routeId: "1", startLocation: nil)
//        if #available(iOS 10.0, *) {
//            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
//                self.eachSecond(timer: Timer)
//            })
//        } else {
//            // Fallback on earlier versions
//            //LONGV TODO: write code for previous version of iOS
//        }
//        startLocationUpdates()
//        workOutStatus = WO_STARTED
//    }
//    
//    @IBAction func stopRun(_ sender: UIButton) {
//        if workOutStatus == WO_STARTED
//        {
//            locationManager.stopUpdatingLocation()
//            timer.invalidate()
//            newWorkOut?.completed(endTime: "999999", endLocation: nil, distanceKm: self.distanceKm, duration: duration)
//            print("Workout completed")
//            workOutStatus = WO_STOPPED
//        }
//    }
//    
//    @IBAction func saveRun(_ sender: UIButton) {
//        if workOutStatus == WO_STOPPED {
//            let locs = Location.initArray(gpsLocs: locations)
//            saveRoute(locs: locs)
//        }
//    }
//    
//    func saveRoute(locs: [Location]){
//        let routeID = ref.child(Constants.Route.TABLE_NAME).childByAutoId().key
//        
//        let routeRef = ref.child("\(Constants.Route.TABLE_NAME)/\(routeID)")
//        
//        routeRef.child(Constants.Route.ROUTE_DISTANCE ).setValue("\(distanceKm)")
//        var i = 0
//        for loc in locs{
//            routeRef.child("\(i)").setValue(loc.toAnyObject())
//            i += 1
//        }
//        saveWorkout(routeID: routeID)
//    }
//    
//    func saveWorkout(routeID: String){
//        newWorkOut?.routeId = routeID
//        ref.child(Constants.Workout.TABLE_NAME).childByAutoId().setValue(newWorkOut?.toAnyObject())
//        workOutStatus = WO_SAVED
//    }
//    
//    func eachSecond(timer: Timer) {
//        duration += 1
//        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: duration)
//        //        print("Time: " + secondsQuantity.description)
//        durationLabel.text = secondsQuantity.description
//        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distanceKm)
//        //        print("Distance: " + distanceQuantity.description)
//        distanceLabel.text = distanceQuantity.description
//        let paceUnit = HKUnit.second().unitDivided(by: HKUnit.meter())
//        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: duration / distanceKm)
//        //        print("Pace: " + paceQuantity.description)
//        currentPaceLabel.text = paceQuantity.description
//    }
//    func startLocationUpdates() {
//        // Here, the location manager will be lazily instantiated
//        locationManager.startUpdatingLocation()
//    }
//    /*
//     // MARK: - Navigation
//     
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//     }
//     */
//    func configureDatabase() {
//        // TODO: configure database to sync messages
//        ref = FIRDatabase.database().reference()
//        //        _refHandle = ref.child("workouts").observe(.childAdded){ (snapshot: FIRDataSnapshot) in
//        ////            self.messages.append(snapshot)
//        ////            self.messagesTable.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)],with: .automatic)
//        ////            self.scrollToBottomMessage()
//        //        }
//    }
//    deinit {
//        // TODO: set up what needs to be deinitialized when view is no longer being used
//        //        ref.child("workouts").removeObserver(withHandle: _refHandle)
//        
//    }
//}
//extension TrackingViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        for location in locations {
//            
//            if location.horizontalAccuracy < 20 {
//                //update distance
//                if self.locations.count > 0 {
//                    distanceKm += location.distance(from: self.locations.last!)
//                    print("Lat: \(self.locations.last!.coordinate.latitude) Long: \(self.locations.last!.coordinate.longitude)")
//                    print("Timestamp: \(self.locations.last!.timestamp)")
//                    print("horizontalAccuracy: \(self.locations.last!.horizontalAccuracy)")
//                    print("speed: \(self.locations.last!.speed)")
//                }
//                
//                //save location
//                self.locations.append(location)
//            }
//        }
//    }
//}
