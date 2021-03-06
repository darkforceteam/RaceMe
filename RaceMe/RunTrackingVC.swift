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
    fileprivate lazy var audioTimer = Timer()
    fileprivate var mapOverlay: MKTileOverlay!
    var user: User!
    fileprivate var workout: Workout!
    fileprivate var isRunning = true
    fileprivate let speechSynthesizer = AVSpeechSynthesizer()
    fileprivate let ref = FIRDatabase.database().reference()
    var selectedRoute: Route?
    var currentColor: UIColor?
    var startedRunning = false
    
    fileprivate lazy var locationManager: CLLocationManager = {
        var lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.activityType = .fitness
        lm.distanceFilter = 10.0
        lm.requestAlwaysAuthorization()
        lm.allowsBackgroundLocationUpdates = true
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
    
    fileprivate let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "TIME"
        label.textColor = labelGray1
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans-Light", size: 14)
        return label
    }()
    
    fileprivate let hourDisplay: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.textColor = labelGray2
        label.font = UIFont(name: "OpenSans-Semibold", size: 32)
        return label
    }()
    
    fileprivate let minDisplay: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.textColor = labelGray2
        label.font = UIFont(name: "OpenSans-Semibold", size: 32)
        return label
    }()
    
    fileprivate let secDisplay: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.textColor = labelGray2
        label.font = UIFont(name: "OpenSans-Semibold", size: 32)
        return label
    }()
    
    fileprivate let hourColon: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.textAlignment = .center
        label.textColor = labelGray2
        label.font = UIFont(name: "OpenSans-Semibold", size: 32)
        return label
    }()
    
    fileprivate let minColon: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.textAlignment = .center
        label.textColor = labelGray2
        label.font = UIFont(name: "OpenSans-Semibold", size: 32)
        return label
    }()
    
    fileprivate let statusBarView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(73, 158, 217)
        return lineView
    }()
    
    fileprivate let seperatorLineView1: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    fileprivate let seperatorLineView2: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    fileprivate let paceLabel: UILabel = {
        let label = UILabel()
        label.text = "AVG PACE (min/km)"
        label.textColor = labelGray1
        label.font = UIFont(name: "OpenSans-Light", size: 14)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let paceDisplay: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.textAlignment = .center
        label.textColor = labelGray2
        label.font = UIFont(name: "OpenSans-Semibold", size: 25)
        return label
    }()
    
    fileprivate let navImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "nav").withRenderingMode(.alwaysTemplate)
        iv.tintColor = imageGray
        return iv
    }()
    
    fileprivate let runImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "run").withRenderingMode(.alwaysTemplate)
        iv.tintColor = imageGray
        return iv
    }()
    
    fileprivate let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "DISTANCE (km)"
        label.textColor = labelGray1
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans-Light", size: 14)
        return label
    }()
    
    fileprivate let distanceDisplay: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        label.textAlignment = .center
        label.textColor = labelGray2
        label.font = UIFont(name: "OpenSans-Semibold", size: 25)
        return label
    }()
    
    fileprivate lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setTitle("Stop", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = stopColor
        button.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 20)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    fileprivate lazy var pauseResumeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pause", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = pauseColor
        button.addTarget(self, action: #selector(pauseResumeButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 20)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    func drawRoute(route: Route){
        let myPolyline = MKGeodesicPolyline(coordinates: route.locations, count: route.locations.count)
        mapView.add(myPolyline)
    }
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
        audioTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(audioUpdate), userInfo: nil, repeats: true)
    }
    
    fileprivate func saveData() {
        let key = ref.child(Constants.Route.TABLE_NAME).childByAutoId().key
        let routeID = Constants.Route.TABLE_NAME + "/" + key
        let routeRef = ref.child(routeID)
        
        for (i, loc) in locations.enumerated() {
            let firstTimestamp = locations[0].timestamp
            let locationRef = routeRef.child("\(i)")
            let location = Location(loc, firstTimestamp, loc.timestamp)
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
        var stringToSpeak = ""
        if currentDistance < 1000 {
            stringToSpeak = "You have run \(currentDistance) meters."
        } else {
            let string = String(format: "%.1f", distance / 1000)
            stringToSpeak = "You have run \(string) kilometers."
        }
        let speechUtterrance = AVSpeechUtterance(string: stringToSpeak)
        speechUtterrance.rate = 0.4
        speechUtterrance.pitchMultiplier = 1
        speechSynthesizer.speak(speechUtterrance)
    }
    
    fileprivate func reset() {
        timer.invalidate()
        audioTimer.invalidate()
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
        audioTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(audioUpdate), userInfo: nil, repeats: true)
        
    }
    
    fileprivate func pauseCounting() {
        isRunning = false
        timer.invalidate()
        audioTimer.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    fileprivate func setButtonTitleAndColor() {
        pauseResumeButton.backgroundColor = isRunning ? resumeColor : pauseColor
        let buttonTitle = isRunning ? "Resume" : "Pause"
        pauseResumeButton.setTitle(buttonTitle, for: .normal)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = currentColor
        renderer.lineWidth = 4.0
        if startedRunning != true {
            let mapRect = MKPolygon(points: renderer.polyline.points(), count: renderer.polyline.pointCount)
            mapView.setVisibleMapRect(mapRect.boundingMapRect, edgePadding: UIEdgeInsets(top: 20.0,left: 20.0,bottom: 20.0,right: 20.0), animated: false)
        }
        return renderer
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 20 {
                if self.locations.count > 0 {
                    currentColor = strokeColor
                    isRunning = true
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
        currentColor = dangerColor
        setupViews()
        startCounting()
        if self.selectedRoute != nil{
            drawRoute(route: self.selectedRoute!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        centerMapOnLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
        audioTimer.invalidate()
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
        view.addSubview(statusBarView)
        view.addSubview(paceLabel)
        view.addSubview(distanceLabel)
        view.addSubview(seperatorLineView2)
        view.addSubview(paceDisplay)
        view.addSubview(distanceDisplay)
        view.addSubview(stopButton)
        view.addSubview(pauseResumeButton)
        view.addSubview(seperatorLineView1)
        view.addSubview(runImageView)
        mapView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        let buttonWidth = (view.frame.width - 45) / 2
        stopButton.anchorInCorner(.bottomLeft, xPad: 15, yPad: 15, width: buttonWidth, height: 45)
        pauseResumeButton.anchorInCorner(.bottomRight, xPad: 15, yPad: 15, width: buttonWidth, height: 45)
        mapView.anchorToEdge(.bottom, padding: 75, width: view.frame.width, height: view.frame.height - 205)
        timeLabel.anchorInCorner(.topLeft, xPad: 0, yPad: 45, width: view.frame.width * 0.57, height: 20)
        minDisplay.align(.underCentered, relativeTo: timeLabel, padding: 0, width: 44, height: 40)
        hourColon.align(.toTheLeftCentered, relativeTo: minDisplay, padding: 0, width: 10, height: 40)
        hourDisplay.align(.toTheLeftCentered, relativeTo: hourColon, padding: 0, width: 44, height: 40)
        minColon.align(.toTheRightCentered, relativeTo: minDisplay, padding: 0, width: 10, height: 40)
        secDisplay.align(.toTheRightCentered, relativeTo: minColon, padding: 0, width: 44, height: 40)
        seperatorLineView1.align(.toTheRightMatchingTop, relativeTo: timeLabel, padding: 0, width: 1, height: 110, offset: -25)
        seperatorLineView2.alignAndFillWidth(align: .toTheRightCentered, relativeTo: seperatorLineView1, padding: 0, height: 1)
        
        navImageView.align(.aboveMatchingLeft, relativeTo: seperatorLineView2, padding: 10, width: 16, height: 16, offset: 10)
        
        distanceLabel.align(.aboveCentered, relativeTo: seperatorLineView2, padding: 32, width: seperatorLineView2.width, height: 22.5)
        
        distanceDisplay.align(.underCentered, relativeTo: distanceLabel, padding: 0, width: distanceLabel.width , height: 32)
        
        paceLabel.align(.underCentered, relativeTo: seperatorLineView2, padding: 0, width: seperatorLineView2.width, height: 22.5)
        paceDisplay.align(.underCentered, relativeTo: paceLabel, padding: 0, width: paceLabel.width, height: 32)
        
        statusBarView.anchorToEdge(.top, padding: 0, width: view.frame.width, height: 20)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

