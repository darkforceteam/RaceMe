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

class RunSummaryViewController: UIViewController {
    
    var workout: Workout! {
        didSet {
            if let distance = workout?.distanceKm, let timestamp = workout?.startTime, let duration = workout?.duration {
                dateLabel.text = timestamp.toDate
                durationDisplay.text = "\(duration.toMinutes):\(duration.toSeconds)"
                distanceDisplay.text = String(format: "%.1f km", distance)
                let pace = Double(duration) / distance
                paceDisplay.text = "\(pace.stringWithPaceFormat) /km"
            }
        }
    }
    
    var locations = [CLLocation]()
    fileprivate let ref = FIRDatabase.database().reference()
    fileprivate var mapOverlay: MKTileOverlay!
    
    fileprivate let mapView: MKMapView = {
        let mv = MKMapView()
        mv.userTrackingMode = .follow
        mv.showsPointsOfInterest = false
        mv.showsBuildings = false
        mv.showsUserLocation = false
        return mv
    }()
    
    fileprivate var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        return label
    }()
    
    fileprivate var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "DURATION"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    fileprivate var durationDisplay: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
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
        label.textAlignment = .center
        return label
    }()
    
    fileprivate var paceDisplay: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    fileprivate var paceLabel: UILabel = {
        let label = UILabel()
        label.text = "AVG PACE"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
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
    
    fileprivate let seperatorLineView3: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    fileprivate let seperatorLineView4: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    fileprivate let seperatorLineView5: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = customGray
        return lineView
    }()
    
    fileprivate let shareSwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()
    
    fileprivate lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("SAVE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = customOrange
        button.addTarget(self, action: #selector(saveButtonDidTouch), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: UIFontWeightLight)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    fileprivate lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
        return button
    }()
}

extension RunSummaryViewController: MKMapViewDelegate {
    
    fileprivate func setMapRegion() -> MKCoordinateRegion {
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
    
    fileprivate func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        for location in locations {
            let coordinate = location.coordinate
            coords.append(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        
        return MKPolyline(coordinates: coords, count: locations.count)
    }
    
    fileprivate func loadMap() {
        mapView.region = setMapRegion()
        mapView.add(polyline())
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = primaryColor
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
}

extension RunSummaryViewController {
    
    @objc fileprivate func saveButtonDidTouch() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func deleteButtonTapped() {
        if let routeId = workout.routeId {
            let alertController = UIAlertController(title: "Discard Run?", message: "Are you sure you would like to discard this run?", preferredStyle: .alert)
            let routeRef = ref.child(Constants.Route.TABLE_NAME).child(routeId)
            let workoutRef = self.ref.child(Constants.Workout.TABLE_NAME).child(routeId)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                routeRef.removeValue()
                workoutRef.removeValue()
                self.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(yesAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension RunSummaryViewController {
    
    override func viewDidLoad() {
        setupViews()
        loadMap()
    }
    
    fileprivate func setupViews() {
        title = "Review and Save"
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
        view.addSubview(seperatorLineView3)
        view.addSubview(seperatorLineView4)
        view.addSubview(seperatorLineView5)
        view.addSubview(shareSwitch)
        view.addSubview(saveButton)
        navigationItem.leftBarButtonItem = deleteButton
    }
    
    override func viewWillLayoutSubviews() {
        mapView.anchorToEdge(.top, padding: 64, width: view.frame.width, height: view.frame.height - 313)
        saveButton.anchorToEdge(.bottom, padding: 15, width: view.frame.width - 30, height: 60)
        seperatorLineView1.anchorToEdge(.bottom, padding: 90, width: view.frame.width, height: 1)
        seperatorLineView2.anchorToEdge(.bottom, padding: 135, width: view.frame.width, height: 1)
        seperatorLineView3.anchorToEdge(.bottom, padding: 205, width: view.frame.width, height: 1)
        let xPad = (view.frame.width - 2) / 3
        seperatorLineView4.anchorInCorner(.bottomLeft, xPad: xPad, yPad: 135, width: 1, height: 70)
        seperatorLineView5.anchorInCorner(.bottomRight, xPad: xPad, yPad: 135, width: 1, height: 70)
        shareSwitch.anchorInCorner(.bottomRight, xPad: 0, yPad: 212, width: 66, height: 31)
        distanceLabel.anchorToEdge(.bottom, padding: 170, width: xPad, height: 22)
        durationLabel.anchorInCorner(.bottomLeft, xPad: 0, yPad: 170, width: xPad, height: 22)
        paceLabel.anchorInCorner(.bottomRight, xPad: 0, yPad: 170, width: xPad, height: 22)
    }
}
