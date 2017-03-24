//
//  RecordViewController.swift
//  iRun
//
//  Created by Duc Pham Viet on 3/23/17.
//  Copyright © 2017 Duc Pham Viet. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import Neon

class RecordViewController: UIViewController, MKMapViewDelegate {
    
    private var seconds = 0
    var distance = 0.0
    lazy var locations = [CLLocation]()
    private lazy var timer = Timer()
    var mapOverlay: MKTileOverlay!
    var user: User!
    var run: Run!
    
    let ref = FIRDatabase.database().reference()
    let onlineRef = FIRDatabase.database().reference(withPath: "online")

    private lazy var locationManager: CLLocationManager = {
        var lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.activityType = .fitness
        lm.distanceFilter = 10.0
        lm.requestAlwaysAuthorization()
        return lm
    }()
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.userTrackingMode = .follow
        mv.showsPointsOfInterest = false
        mv.showsBuildings = false
        mv.showsUserLocation = true
        return mv
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "TIME"
        label.textColor = .darkGray
        //label.backgroundColor = .blue
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private var hourDisplay: UILabel = {
        let label = UILabel()
        label.text = "00"
        //label.textColor = .white
        //label.backgroundColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightMedium)
        return label
    }()
    
    private var minDisplay: UILabel = {
        let label = UILabel()
        label.text = "00"
        //label.textColor = .white
        //label.backgroundColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightMedium)
        return label
    }()
    
    private var secDisplay: UILabel = {
        let label = UILabel()
        label.text = "00"
        //label.textColor = .white
        //label.backgroundColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightMedium)
        return label
    }()
    
    private var hourColon: UILabel = {
        let label = UILabel()
        label.text = ":"
        //label.textColor = .white
        //label.backgroundColor = .green
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightMedium)
        return label
    }()
    
    private var minColon: UILabel = {
        let label = UILabel()
        label.text = ":"
        //label.textColor = .white
        //label.backgroundColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60, weight: UIFontWeightMedium)
        return label
    }()
    
    private let seperatorLineView1: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    private let seperatorLineView2: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    private var paceLabel: UILabel = {
        let label = UILabel()
        label.text = "AVG PACE"
        label.textColor = .darkGray
        //label.backgroundColor = .blue
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private var paceDisplay: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        //label.textColor = .white
        //label.backgroundColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 50, weight: UIFontWeightMedium)
        return label
    }()
    
    private var paceUnit: UILabel = {
        let label = UILabel()
        label.text = "/KM"
        label.textColor = .lightGray
        //label.backgroundColor = .blue
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: UIFontWeightLight)
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "DISTANCE"
        label.textColor = .darkGray
        //label.backgroundColor = .blue
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private var distanceDisplay: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        //label.textColor = .white
        //label.backgroundColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 50, weight: UIFontWeightMedium)
        return label
    }()
    
    private var distanceUnit: UILabel = {
        let label = UILabel()
        label.text = "KILOMETERS"
        label.textColor = .lightGray
        //label.backgroundColor = .blue
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: UIFontWeightLight)
        return label
    }()
    
    private let seperatorLineView3: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitle("Stop", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        return button
    }()
    
    override func viewDidLoad() {
        setupViews()
        authObserving()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.requestAlwaysAuthorization()
        startButton.isHidden = false
        stopButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        centerMapOnLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    private func authObserving() {
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            guard let user = user else { return }
            self.user = User(authData: user)
            let currentUserRef = self.onlineRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        })
    }
    
    private func setupViews() {
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
        view.addSubview(startButton)
        view.addSubview(stopButton)
        
        mapView.delegate = self
    }
    
    func eachSecond(timer: Timer) {
        seconds += 1
        
        hourDisplay.text = "\(seconds.toHours)"
        minDisplay.text = "\(seconds.toMinutes)"
        secDisplay.text = "\(seconds.toSeconds)"
        
        let totalTime = Double(seconds)
        let paceQuantity = totalTime * 1000 / distance
        paceDisplay.text = "\(paceQuantity.stringWithPaceFormat)"
        distanceDisplay.text = String(format: "%.1f", distance / 1000)
    }
    
    func startButtonTapped() {
        startButton.isHidden = true
        stopButton.isHidden = false
        seconds = 0
        distance = 0
        locations.removeAll(keepingCapacity: false)
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond), userInfo: nil, repeats: true)
    }
    
    func stopButtonTapped() {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            self.saveData()
            self.reset()
            
            let summaryController = RunSummaryViewController()
            summaryController.run = self.run
            summaryController.locations = self.locations
            let summaryNav = UINavigationController(rootViewController: summaryController)
            self.present(summaryNav, animated: true, completion: nil)
        }
        
        let discardAction = UIAlertAction(title: "Discard", style: .destructive) { (action) in
            self.reset()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionController.addAction(saveAction)
        actionController.addAction(discardAction)
        actionController.addAction(cancelAction)
        present(actionController, animated: true, completion: nil)
        locationManager.stopUpdatingLocation()
    }
    
    func saveData() {
        let routeRef = ref.child(Constants.Route.TABLE_NAME).childByAutoId()
        for (i, loc) in locations.enumerated() {
            let locationRef = routeRef.child("\(i)")
            let location = Location(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, timestamp: "\(loc.timestamp)", speed: loc.speed)
            locationRef.setValue(location.toAnyObject())
        }
        let distanceRef = routeRef.child(Constants.Route.ROUTE_DISTANCE)
        distanceRef.setValue(distance)
        
        let workoutRef = ref.child(Constants.Workout.TABLE_NAME).childByAutoId()
        let distanceKm = distance / 1000
        let distanceMi = distanceKm * Constants.UnitExchange.ONE_KM_IN_MILE
        if let startTime = locations.first?.timestamp, let endTime = locations.last?.timestamp {
            let workout = Workout(userId: user.uid, startTime: "\(startTime)", endTime: "\(endTime)", routeId: routeRef.key, distanceKm: distanceKm, distanceMi: distanceMi, duration: seconds)
            workoutRef.setValue(workout.toAnyObject())
        }
    }
    
    func reset() {
        timer.invalidate()
        distance = 0
        seconds = 0
        hourDisplay.text = "00"
        minDisplay.text = "00"
        secDisplay.text = "00"
        paceDisplay.text = "0:00"
        distanceDisplay.text = "0.0"
        
        for overlay in mapView.overlays {
            mapView.remove(overlay)
        }
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
    
    func centerMapOnLocation() {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    override func viewWillLayoutSubviews() {
        mapView.anchorToEdge(.top, padding: 64, width: view.frame.width, height: view.frame.width * 0.6)
        timeLabel.align(.underCentered, relativeTo: mapView, padding: 10, width: view.frame.width, height: 20)
        minDisplay.align(.underCentered, relativeTo: timeLabel, padding: 0, width: 80, height: 60)
        hourColon.align(.toTheLeftCentered, relativeTo: minDisplay, padding: 0, width: 15, height: 60)
        hourDisplay.align(.toTheLeftCentered, relativeTo: hourColon, padding: 0, width: 80, height: 60)
        minColon.align(.toTheRightCentered, relativeTo: minDisplay, padding: 0, width: 15, height: 60)
        secDisplay.align(.toTheRightCentered, relativeTo: minColon, padding: 0, width: 80, height: 60)
        seperatorLineView1.align(.underCentered, relativeTo: minDisplay, padding: 0, width: view.frame.width - 20, height: 0.5)
        paceLabel.align(.underMatchingLeft, relativeTo: seperatorLineView1, padding: 10, width: seperatorLineView1.width / 2, height: 20)
        paceDisplay.align(.underCentered, relativeTo: paceLabel, padding: 0, width: paceLabel.width, height: 60)
        paceUnit.align(.underCentered, relativeTo: paceDisplay, padding: 0, width: paceDisplay.width, height: 20)
        distanceLabel.align(.underMatchingRight, relativeTo: seperatorLineView1, padding: 10, width: seperatorLineView1.width / 2, height: 20)
        seperatorLineView2.align(.underCentered, relativeTo: seperatorLineView1, padding: 10, width: 0.5, height: 100)
        distanceDisplay.align(.underCentered, relativeTo: distanceLabel, padding: 0, width: distanceLabel.width, height: 60)
        distanceUnit.align(.underCentered, relativeTo: distanceDisplay, padding: 0, width: distanceDisplay.width, height: 20)
        seperatorLineView3.align(.underCentered, relativeTo: seperatorLineView2, padding: 10, width: seperatorLineView1.width, height: 0.5)
        startButton.anchorToEdge(.bottom, padding: 15, width: 70, height: 70)
        stopButton.anchorToEdge(.bottom, padding: 15, width: 70, height: 70)
    }
}

extension RecordViewController: CLLocationManagerDelegate {
    
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
