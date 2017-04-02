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
        button.setTitle("Start Running", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = customOrange
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: UIFontWeightMedium)
        return button
    }()
    
    fileprivate lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        return button
    }()
    
    fileprivate lazy var activitiesButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Activities", style: .plain, target: self, action: #selector(showActivities))
        return button
    }()
}

extension RecordViewController {
    
    @objc fileprivate func startButtonTapped() {
        let trackingController = RunTrackingVC()
        trackingController.user = self.user
        let trackingNav = UINavigationController(rootViewController: trackingController)
        present(trackingNav, animated: true, completion: nil)
    }
    
    @objc fileprivate func addButtonTapped() {
        let manualController = ManualEntryController()
        manualController.user = self.user
        let manualNav = UINavigationController(rootViewController: manualController)
        present(manualNav, animated: true, completion: nil)
    }
    
    @objc fileprivate func showActivities() {
        let activitiesControlller = ActivitiesVC()
        activitiesControlller.user = self.user
        let activitiesNav = UINavigationController(rootViewController: activitiesControlller)
        present(activitiesNav, animated: true, completion: nil)
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
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = activitiesButton
        mapView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        startButton.anchorToEdge(.bottom, padding: 49, width: view.frame.width, height: 61)
        mapView.align(.aboveCentered, relativeTo: startButton, padding: 0, width: view.frame.width, height: view.frame.height - 174)
    }
}
