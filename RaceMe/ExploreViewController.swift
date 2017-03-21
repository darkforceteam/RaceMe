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

class ExploreViewController: UIViewController {
    var duration = 0.0
    var distance = 0.0
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .fitness
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    
    @available(iOS 10.0, *)
    @IBAction func startRun(_ sender: UIButton) {
        duration = 0.0
        distance = 0.0
        locations.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            self.eachSecond(timer: Timer)
        })
        startLocationUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locationManager.requestAlwaysAuthorization()
    }
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        timer.invalidate()
    //    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func eachSecond(timer: Timer) {
        duration += 1
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: duration)
        print("Time: " + secondsQuantity.description)
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        print("Distance: " + distanceQuantity.description)
        
        let paceUnit = HKUnit.second().unitDivided(by: HKUnit.meter())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: duration / distance)
        print("Pace: " + paceQuantity.description)
    }
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension ExploreViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        for location in locations {

            if location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distance(from: self.locations.last!)
                    print("Lat: \(self.locations.last!.coordinate.latitude) Long: \(self.locations.last!.coordinate.longitude)")
                    print("Timestamp: \(self.locations.last!.timestamp)")
                    print("horizontalAccuracy: \(self.locations.last!.horizontalAccuracy)")
                    print("horizontalAccuracy: \(self.locations.last!.speed)")
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
}
