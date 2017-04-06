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
    
    fileprivate var user: User!
    fileprivate let onlineRef = FIRDatabase.database().reference(withPath: "online")
    fileprivate let workoutRef = FIRDatabase.database().reference(withPath: "WORKOUTS")
    
    fileprivate var workouts = [Workout]()
    
    fileprivate let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "Turn off your screen while running"
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(84, 106, 120)
        label.font = UIFont(name: "OpenSans-Semibold", size: 14)
        return label
    }()
    
    fileprivate let mapView: MKMapView = {
        let mv = MKMapView()
        mv.userTrackingMode = .follow
        mv.showsPointsOfInterest = false
        mv.showsBuildings = false
        mv.showsUserLocation = true
        return mv
    }()
    
    fileprivate lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("GO RUNNING", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = goRunning
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "OpenSans-Semibold", size: 15)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
}

extension RecordViewController {
    
    @objc fileprivate func startButtonTapped() {
        let trackingController = RunTrackingVC()
        trackingController.user = self.user
        let trackingNav = UINavigationController(rootViewController: trackingController)
        trackingNav.navigationBar.barTintColor = primaryColor
        trackingNav.navigationBar.isTranslucent = false
        trackingNav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        trackingNav.navigationBar.barStyle = UIBarStyle.black
        trackingNav.navigationBar.tintColor = .white
        present(trackingNav, animated: true, completion: nil)
    }
    
    @objc fileprivate func addButtonTapped() {
//        let manualController = ManualEntryController()
//        manualController.user = self.user
//        let manualNav = UINavigationController(rootViewController: manualController)
//        present(manualNav, animated: true, completion: nil)
        print("Rebuilding UI")
    }
    
    fileprivate func centerMapOnLocation() {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    fileprivate func authObserving() {
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            guard let user = user else { return }
            self.user = User(authData: user)
            let currentUserRef = self.onlineRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        })
    }
    
    fileprivate func loadWorkouts() {
        
        workoutRef.observe(.value, with: { (snapshot) in
            
            for item in snapshot.children {
                let workout = Workout(snapshot: item as! FIRDataSnapshot)
                self.workouts.append(workout)
                
            }
        })
    }
}

extension RecordViewController {
    
    override func viewDidLoad() {
        setupViews()
        authObserving()
        loadWorkouts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        centerMapOnLocation()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        view.addSubview(startButton)
        view.addSubview(notificationLabel)
        setupRightButton()
        mapView.delegate = self
    }
    
    fileprivate func setupRightButton() {
        let addButton = UIButton()
        addButton.setImage(#imageLiteral(resourceName: "add"), for: .normal)
        addButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.transform = CGAffineTransform(translationX: 10, y: 0)
        let buttonContainer = UIView(frame: addButton.frame)
        buttonContainer.addSubview(addButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainer)
    }
    
    override func viewWillLayoutSubviews() {
        notificationLabel.anchorToEdge(.top, padding: 0, width: view.frame.width, height: 30)
        startButton.anchorToEdge(.bottom, padding: 64, width: view.frame.width - 30, height: 60)
        mapView.align(.aboveCentered, relativeTo: startButton, padding: 15, width: view.frame.width, height: view.frame.height - 169)
    }
}
