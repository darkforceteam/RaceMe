//
//  RunTrackingVC.swift
//  RaceMe
//
//  Created by Duc Pham Viet on 3/25/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import Neon
import AVFoundation

class RunTrackingVC: UIViewController {
    
    fileprivate var duration = 0
    fileprivate var distance = 0.0
    fileprivate lazy var locations = [CLLocation]()
    fileprivate lazy var timer = Timer()
    fileprivate var mapOverlay: MKTileOverlay!
    var user: User!
    fileprivate var workout: Workout!
    fileprivate var isRunning = true
    fileprivate let speechSynthesizer = AVSpeechSynthesizer()
    fileprivate let ref = FIRDatabase.database().reference()
    
    fileprivate lazy var locationManager: CLLocationManager = {
        var lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.activityType = .fitness
        lm.distanceFilter = 10.0
        lm.requestAlwaysAuthorization()
        return lm
    }()
    
    fileprivate let mapView: MKMapView = {
        let mv = MKMapView()
        mv.userTrackingMode = .follow
        mv.showsPointsOfInterest = false
        mv.showsBuildings = false
        mv.showsUserLocation = true
        return mv
    }()
    
    fileprivate let mockupImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "mockup")
        return iv
    }()
    
    fileprivate var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "TIME"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    fileprivate var hourDisplay: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate var minDisplay: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate var secDisplay: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate var hourColon: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate var minColon: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate let seperatorLineView1: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = backgroundGray
        return lineView
    }()
    
    fileprivate let seperatorLineView2: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    fileprivate var paceLabel: UILabel = {
        let label = UILabel()
        label.text = "AVG PACE"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    fileprivate var paceDisplay: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 50, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate var paceUnit: UILabel = {
        let label = UILabel()
        label.text = "/KM"
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "DISTANCE"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    fileprivate var distanceDisplay: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 50, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate var distanceUnit: UILabel = {
        let label = UILabel()
        label.text = "KILOMETERS"
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate let seperatorLineView3: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    fileprivate let seperatorLineView4: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = backgroundGray
        return lineView
    }()
    
    fileprivate lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setTitle("Stop", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = stopColor
        button.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        return button
    }()
    
    fileprivate lazy var pauseResumeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pause", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = pauseColor
        button.addTarget(self, action: #selector(pauseResumeButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        return button
    }()
}

extension RunTrackingVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
    @objc fileprivate func eachSecond(timer: Timer) {
        duration += 1
        
        hourDisplay.text = "\(duration.toHours)"
        minDisplay.text = "\(duration.toMinutes)"
        secDisplay.text = "\(duration.toSeconds)"
        
        let totalTime = Double(duration)
        let paceQuantity = totalTime * 1000 / distance
        paceDisplay.text = "\(paceQuantity.stringWithPaceFormat)"
        distanceDisplay.text = String(format: "%.1f", distance / 1000)
    }
    
    fileprivate func startCounting() {
        duration = 0
        distance = 0
        locations.removeAll(keepingCapacity: false)
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond), userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(audioUpdate), userInfo: nil, repeats: true)
    }
    
    fileprivate func saveData() {
        let key = ref.child(Constants.Route.TABLE_NAME).childByAutoId().key
        let routeID = Constants.Route.TABLE_NAME + "/" + key
        let routeRef = ref.child(routeID)
        
        for (i, loc) in locations.enumerated() {
            let locationRef = routeRef.child("\(i)")
            let location = Location(loc)
            locationRef.setValue(location.toAnyObject())
        }
        let startLoc = locations.first
        let endLoc = locations.last
        
        let geoFire = GeoFire(firebaseRef: ref.child(Constants.GEOFIRE))
        //geoFire?.setLocation(startLoc, forKey: "\(routeID)/\(Constants.Route.ROUTE_DISTANCE)")
        geoFire?.setLocation(startLoc!, forKey: key)
        
        let distanceRef = routeRef.child(Constants.Route.ROUTE_DISTANCE)
        distanceRef.setValue(distance)
        
        let workoutRef = ref.child(Constants.Workout.TABLE_NAME).child(routeRef.key)
        workout = Workout(user, routeRef.key, locations, distance, duration)
        workoutRef.setValue(workout.toAnyObject())
    }
    
    @objc fileprivate func audioUpdate() {
        let currentDistance = Int(distance)
        let stringToSpeak = "You have run \(currentDistance) meters."
        let speechUtterrance = AVSpeechUtterance(string: stringToSpeak)
        speechUtterrance.rate = 0.4
        speechUtterrance.pitchMultiplier = 1
        speechSynthesizer.speak(speechUtterrance)
    }
    
    fileprivate func reset() {
        timer.invalidate()
        distance = 0
        duration = 0
        hourDisplay.text = "00"
        minDisplay.text = "00"
        secDisplay.text = "00"
        paceDisplay.text = "0:00"
        distanceDisplay.text = "0.0"
        
        for overlay in mapView.overlays {
            mapView.remove(overlay)
        }
    }
    
    fileprivate func centerMapOnLocation() {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc fileprivate func stopButtonTapped() {
        pauseCounting()
        
        if locations.count > 1 {
            let alertController = UIAlertController(title: nil, message: "Are you sure you'd like to complete this run?", preferredStyle: .actionSheet)
            let saveAction = UIAlertAction(title: "Yes I'm Done", style: .default) { (action) in
                self.saveData()
                self.reset()
                
                let summaryController = RunSummaryViewController()
                summaryController.workout = self.workout
                summaryController.locations = self.locations
                let summaryNav = UINavigationController(rootViewController: summaryController)
                
                self.dismiss(animated: false, completion: {
                    if let topController = UIApplication.topViewController() {
                        topController.present(summaryNav, animated: true, completion: nil)
                    }
                })
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.continueCounting()
            })
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: nil, message: "Looks like you haven't run yet. Would you like to continue or discard this run?", preferredStyle: .alert)
            let discardAction = UIAlertAction(title: "Discard", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
                
            })
            let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                self.setButtonTitleAndColor()
                self.continueCounting()
            })
            alertController.addAction(discardAction)
            alertController.addAction(continueAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func pauseResumeButtonTapped() {
        setButtonTitleAndColor()
        isRunning ? pauseCounting() : continueCounting()
    }
    
    fileprivate func continueCounting() {
        isRunning = true
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond), userInfo: nil, repeats: true)
    }
    
    fileprivate func pauseCounting() {
        isRunning = false
        timer.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    fileprivate func setButtonTitleAndColor() {
        pauseResumeButton.backgroundColor = isRunning ? resumeColor : pauseColor
        let buttonTitle = isRunning ? "Resume" : "Pause"
        pauseResumeButton.setTitle(buttonTitle, for: .normal)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 20 {
                if self.locations.count > 0 {
                    distance += location.distance(from: self.locations.last!)
                    
                    var coordinates = [CLLocationCoordinate2D]()
                    coordinates.append(self.locations.last!.coordinate)
                    coordinates.append(location.coordinate)
                    mapView.add(MKPolyline(coordinates: coordinates, count: coordinates.count))
                    
                }
                self.locations.append(location)
            }
        }
    }
}

extension RunTrackingVC {
    
    override func viewDidLoad() {
        setupViews()
        startCounting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        centerMapOnLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    fileprivate func setupViews() {
        title = "Run Tracking"
        view.backgroundColor = .white
        view.addSubview(mapView)
        view.addSubview(timeLabel)
        view.addSubview(minDisplay)
        view.addSubview(hourDisplay)
        view.addSubview(secDisplay)
        view.addSubview(hourColon)
        view.addSubview(minColon)
        view.addSubview(seperatorLineView1)
        view.addSubview(paceLabel)
        view.addSubview(distanceLabel)
        view.addSubview(seperatorLineView2)
        view.addSubview(paceDisplay)
        view.addSubview(paceUnit)
        view.addSubview(distanceDisplay)
        view.addSubview(distanceUnit)
        view.addSubview(seperatorLineView3)
        view.addSubview(stopButton)
        view.addSubview(pauseResumeButton)
        view.addSubview(seperatorLineView4)
        mapView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        stopButton.anchorInCorner(.bottomLeft, xPad: 10, yPad: 10, width: view.frame.width / 2 - 15, height: 60)
        pauseResumeButton.anchorInCorner(.bottomRight, xPad: 10, yPad: 10, width: view.frame.width / 2 - 15, height: 60)
        seperatorLineView1.anchorToEdge(.bottom, padding: 80, width: view.frame.width, height: 20)
        minDisplay.align(.aboveCentered, relativeTo: seperatorLineView1, padding: 0, width: 80, height: 60)
        hourColon.align(.toTheLeftCentered, relativeTo: minDisplay, padding: 0, width: 15, height: 60)
        hourDisplay.align(.toTheLeftCentered, relativeTo: hourColon, padding: 0, width: 80, height: 60)
        minColon.align(.toTheRightCentered, relativeTo: minDisplay, padding: 0, width: 15, height: 60)
        secDisplay.align(.toTheRightCentered, relativeTo: minColon, padding: 0, width: 80, height: 60)
        timeLabel.align(.aboveCentered, relativeTo: minDisplay, padding: 0, width: 200, height: 20)
        seperatorLineView2.align(.aboveCentered, relativeTo: timeLabel, padding: 5, width: view.frame.width, height: 0.5)
        seperatorLineView3.align(.aboveCentered, relativeTo: seperatorLineView2, padding: 0, width: 0.5, height: 100)
        
        paceUnit.align(.aboveMatchingLeft, relativeTo: seperatorLineView2, padding: 0, width: seperatorLineView1.width / 2, height: 30)
        distanceUnit.align(.aboveMatchingRight, relativeTo: seperatorLineView2, padding: 0, width: paceUnit.width, height: 30)
        paceDisplay.align(.aboveCentered, relativeTo: paceUnit, padding: 0, width: paceUnit.width, height: 40)
        paceLabel.align(.aboveCentered, relativeTo: paceDisplay, padding: 0, width: paceDisplay.width, height: 30)
        distanceDisplay.align(.aboveCentered, relativeTo: distanceUnit, padding: 0, width: distanceUnit.width, height: 40)
        distanceLabel.align(.aboveCentered, relativeTo: distanceDisplay, padding: 0, width: distanceDisplay.width, height: 30)
        seperatorLineView4.align(.aboveCentered, relativeTo: seperatorLineView3, padding: 0, width: view.frame.width, height: 20)
        mapView.align(.aboveCentered, relativeTo: seperatorLineView4, padding: 0, width: view.frame.width, height: view.frame.height - 289.5)
    }
}

