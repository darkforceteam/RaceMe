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
    
    var user: User!
    let onlineRef = FIRDatabase.database().reference(withPath: "online")
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.userTrackingMode = .follow
        mv.showsPointsOfInterest = false
        mv.showsBuildings = false
        mv.showsUserLocation = true
        return mv
    }()
    
    private let mockupImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "mockup")
        return iv
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start Running", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = customOrange
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: UIFontWeightMedium)
        return button
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        return button
    }()
    
    override func viewDidLoad() {
        setupViews()
        authObserving()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        centerMapOnLocation()
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
        view.backgroundColor = .white
        view.addSubview(mapView)
        view.addSubview(startButton)
        view.addSubview(mockupImage)
        navigationItem.rightBarButtonItem = addButton
        mapView.delegate = self
    }
    
    func startButtonTapped() {
        let trackingController = RunTrackingVC()
        trackingController.user = self.user
        let trackingNav = UINavigationController(rootViewController: trackingController)
        present(trackingNav, animated: true, completion: nil)
    }
    
    func addButtonTapped() {
        let manualController = ManualEntryController()
        manualController.user = self.user
        let manualNav = UINavigationController(rootViewController: manualController)
        present(manualNav, animated: true, completion: nil)
    }
    
    func centerMapOnLocation() {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        startButton.anchorToEdge(.bottom, padding: 49, width: view.frame.width, height: 61)
        mockupImage.align(.aboveCentered, relativeTo: startButton, padding: 0, width: view.frame.width, height: view.frame.width * 11/32)
        let mapViewHeight = view.frame.height - mockupImage.frame.height - 174
        mapView.align(.aboveCentered, relativeTo: mockupImage, padding: 0, width: view.frame.width, height: mapViewHeight)
    }
}
