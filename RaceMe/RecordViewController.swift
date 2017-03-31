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
    
    fileprivate lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start Running", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = customRed
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: UIFontWeightMedium)
        return button
    }()
    
    fileprivate lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
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
}

extension RecordViewController {
    
    override func viewDidLoad() {
        setupViews()
        authObserving()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        centerMapOnLocation()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        view.addSubview(startButton)
        //view.addSubview(mockupImage)
        navigationItem.rightBarButtonItem = addButton
        mapView.delegate = self
    }
    
    func startButtonTapped() {
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
    
    func addButtonTapped() {
        let manualController = ManualEntryController()
        manualController.user = self.user
        let manualNav = UINavigationController(rootViewController: manualController)
        manualNav.navigationBar.barTintColor = primaryColor
        manualNav.navigationBar.isTranslucent = false
        manualNav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        manualNav.navigationBar.barStyle = UIBarStyle.black
        manualNav.navigationBar.tintColor = .white
        present(manualNav, animated: true, completion: nil)
    }
    
    func centerMapOnLocation() {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        startButton.anchorToEdge(.bottom, padding: 49, width: view.frame.width, height: 61)
        //mockupImage.align(.aboveCentered, relativeTo: startButton, padding: 0, width: view.frame.width, height: view.frame.width * 11/32)
        //let mapViewHeight = view.frame.height - mockupImage.frame.height - 174
        //mapView.align(.aboveCentered, relativeTo: mockupImage, padding: 0, width: view.frame.width, height: mapViewHeight)
        
        let mapViewHeight = view.frame.height - 110
        mapView.align(.aboveCentered, relativeTo: startButton, padding: 0, width: view.frame.width, height: mapViewHeight)
    }
}
