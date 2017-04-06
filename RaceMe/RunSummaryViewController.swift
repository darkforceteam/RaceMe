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
            if let distance = workout?.distanceKm, let duration = workout?.duration {
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
    
    fileprivate var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "DURATION"
        label.textColor = labelGray1
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans-Light", size: 16)
        return label
    }()
    
    fileprivate var durationDisplay: UILabel = {
        let label = UILabel()
        label.textColor = labelGray2
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans", size: 18)
        return label
    }()
    
    fileprivate var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "DISTANCE"
        label.textColor = labelGray1
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans-Light", size: 16)
        return label
    }()
    
    fileprivate var distanceDisplay: UILabel = {
        let label = UILabel()
        label.textColor = labelGray2
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans", size: 18)
        return label
    }()
    
    fileprivate var paceDisplay: UILabel = {
        let label = UILabel()
        label.textColor = labelGray2
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans", size: 18)
        return label
    }()
    
    fileprivate var paceLabel: UILabel = {
        let label = UILabel()
        label.text = "AVG PACE"
        label.textColor = labelGray1
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans-Light", size: 16)
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
        sw.isOn = true
        return sw
    }()
    
    fileprivate var shareLabel: UILabel = {
        let label = UILabel()
        label.text = "SHARE THIS ROUTE?"
        label.textColor = labelGray2
        label.font = UIFont(name: "OpenSans-Semibold", size: 14)
        return label
    }()
    
    fileprivate lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("SAVE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = customOrange
        button.addTarget(self, action: #selector(saveButtonDidTouch), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "OpenSans-Semibold", size: 20)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    fileprivate lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
        return button
    }()
    
    fileprivate let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "insert_photo")
        return iv
    }()
    
    fileprivate var addPictureLabel: UILabel = {
        let label = UILabel()
        label.text = "ADD A PICTURE"
        label.textColor = labelGray2
        label.font = UIFont(name: "OpenSans-Semibold", size: 14)
        return label
    }()
    
    fileprivate lazy var addButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "add_box").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(136, 194, 95)
        button.addTarget(self, action: #selector(addButtonDidTouch), for: .touchUpInside)
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
            polylineRenderer.strokeColor = strokeColor
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
    
    @objc fileprivate func addButtonDidTouch() {
        print(123)
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
        view.addSubview(shareLabel)
        view.addSubview(saveButton)
        view.addSubview(photoImageView)
        view.addSubview(addPictureLabel)
        view.addSubview(addButton)
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = primaryColor
        navigationController?.navigationBar.barStyle = .black
        setupLeftButton()
    }
    
    fileprivate func setupLeftButton() {
        let deleteButton = UIButton()
        deleteButton.setBackgroundImage(#imageLiteral(resourceName: "delete"), for: .normal)
        deleteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.transform = CGAffineTransform(translationX: -10, y: 0)
        let buttonContainer = UIView(frame: deleteButton.frame)
        buttonContainer.addSubview(deleteButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: buttonContainer)
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
        shareSwitch.anchorInCorner(.bottomRight, xPad: 0, yPad: 212, width: 65, height: 31)
        shareLabel.align(.toTheLeftCentered, relativeTo: shareSwitch, padding: 0, width: view.frame.width - 80, height: 31)
        distanceLabel.anchorToEdge(.bottom, padding: 170, width: xPad, height: 22)
        distanceDisplay.align(.underCentered, relativeTo: distanceLabel, padding: 0, width: xPad, height: 20)
        durationLabel.anchorInCorner(.bottomLeft, xPad: 0, yPad: 170, width: xPad, height: 22)
        durationDisplay.align(.underCentered, relativeTo: durationLabel, padding: 0, width: xPad, height: 20)
        paceLabel.anchorInCorner(.bottomRight, xPad: 0, yPad: 170, width: xPad, height: 22)
        paceDisplay.align(.underCentered, relativeTo: paceLabel, padding: 0, width: xPad, height: 20)
        photoImageView.anchorInCorner(.bottomLeft, xPad: 15, yPad: 105, width: 16, height: 16)
        addPictureLabel.align(.toTheRightCentered, relativeTo: photoImageView, padding: 15, width: 150, height: 44)
        addButton.anchorInCorner(.bottomRight, xPad: 15, yPad: 100, width: 26, height: 26)
    }
}
