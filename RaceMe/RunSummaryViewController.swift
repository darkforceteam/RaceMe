//
//  RunSummaryViewController.swift
//  iRun
//
//  Created by Duc Pham Viet on 3/23/17.
//  Copyright © 2017 Duc Pham Viet. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Neon
import Firebase

class RunSummaryViewController: UIViewController, MKMapViewDelegate {
    
    var locations = [CLLocation]()
    var workout: Workout! {
        didSet {
            if let distance = workout?.distanceKm, let timestamp = workout?.startTime, let duration = workout?.duration {
                dateLabel.text = timestamp
                durationDisplay.text = "\(duration.toMinutes):\(duration.toSeconds)"
                distanceDisplay.text = String(format: "%.1f km", distance)
                let pace = Double(duration) / distance
                paceDisplay.text = "\(pace.stringWithPaceFormat) /km"
            }
        }
    }
    
    let ref = FIRDatabase.database().reference()
    
    var mapOverlay: MKTileOverlay!
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.userTrackingMode = .follow
        mv.showsPointsOfInterest = false
        mv.showsBuildings = false
        mv.showsUserLocation = false
        return mv
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        return label
    }()
    
    private var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "DURATION"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private var durationDisplay: UILabel = {
        let label = UILabel()
        //label.textColor = .white
        //label.backgroundColor = .blue
        label.textAlignment = .center
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
        //label.textColor = .white
        //label.backgroundColor = .blue
        label.textAlignment = .center
        return label
    }()
    
    private var paceDisplay: UILabel = {
        let label = UILabel()
        //label.textColor = .white
        //label.backgroundColor = .blue
        label.textAlignment = .center
        return label
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
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = customOrange
        button.addTarget(self, action: #selector(saveButtonDidTouch), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: UIFontWeightMedium)
        return button
    }()
    
    private lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
        return button
    }()
    
    override func viewDidLoad() {
        setupViews()
        loadMap()
    }
    
    private func setupViews() {
        title = "Run Summary"
        view.backgroundColor = .white
        view.addSubview(dateLabel)
        view.addSubview(mapView)
        mapView.delegate = self
        view.addSubview(durationLabel)
        view.addSubview(durationDisplay)
        view.addSubview(distanceDisplay)
        view.addSubview(distanceLabel)
        view.addSubview(paceDisplay)
        view.addSubview(paceLabel)
        view.addSubview(seperatorLineView1)
        view.addSubview(seperatorLineView2)
        view.addSubview(saveButton)
        navigationItem.leftBarButtonItem = deleteButton
    }
    
    func setMapRegion() -> MKCoordinateRegion {
        let firstPointCoordinate = locations[0].coordinate
        
        var minLatitude: Double!
        var minLongitude: Double!
        var maxLatitude: Double!
        var maxLongitude: Double!
        
        for location in locations {
            let locationCoordinate = location.coordinate
            minLatitude = min(firstPointCoordinate.latitude, locationCoordinate.latitude)
            minLongitude = min(firstPointCoordinate.longitude, locationCoordinate.longitude)
            maxLatitude = max(firstPointCoordinate.latitude, locationCoordinate.latitude)
            maxLongitude = max(firstPointCoordinate.longitude, locationCoordinate.longitude)
        }
        
        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        let latDelta = (maxLatitude - minLatitude) * 2
        let longDelta = (maxLongitude - minLongitude) * 2
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude), span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
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
    
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //
    //    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        for location in locations {
            let coordinate = location.coordinate
            coords.append(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        
        return MKPolyline(coordinates: coords, count: locations.count)
    }
    
    func loadMap() {
        mapView.region = setMapRegion()
        mapView.add(polyline())
    }
    
    func saveButtonDidTouch() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func deleteButtonTapped() {
        let routeRef = ref.child(Constants.Route.TABLE_NAME).child(workout.routeId)
        routeRef.removeValue()
        let workoutRef = ref.child(Constants.Workout.TABLE_NAME).child(workout.routeId)
        workoutRef.removeValue()
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        let customWidth = (view.frame.width - 1) / 3
        dateLabel.anchorToEdge(.top, padding: 64, width: view.frame.width, height: 40)
        mapView.align(.underCentered, relativeTo: dateLabel, padding: 0, width: view.frame.width, height: view.frame.width)
        durationDisplay.align(.underMatchingLeft, relativeTo: mapView, padding: 0, width: customWidth, height: 40)
        durationLabel.align(.underCentered, relativeTo: durationDisplay, padding: 0, width: customWidth, height: 20)
        distanceDisplay.align(.toTheRightCentered, relativeTo: durationDisplay, padding: 0, width: customWidth, height: 40)
        distanceLabel.align(.underCentered, relativeTo: distanceDisplay, padding: 0, width: customWidth, height: 20)
        paceDisplay.align(.toTheRightCentered, relativeTo: distanceDisplay, padding: 0, width: customWidth, height: 40)
        paceLabel.align(.underCentered, relativeTo: paceDisplay, padding: 0, width: customWidth, height: 20)
        seperatorLineView1.align(.toTheRightMatchingTop, relativeTo: durationDisplay, padding: 0, width: 0.5, height: 45, offset: 10)
        seperatorLineView2.align(.toTheRightMatchingTop, relativeTo: distanceDisplay, padding: 0, width: 0.5, height: 45, offset: 10)
        saveButton.anchorToEdge(.bottom, padding: 0, width: view.frame.width, height: 61)
    }
}
