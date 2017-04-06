//
//  ActivityDetailsViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/5/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class ActivityDetailsViewController: UIViewController {
    
    var workout: Workout!
    var locations = [CLLocation]()
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var avgPaceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        
        timeLabel.text = workout.startTime!.toDate
        durationLabel.text = "\(workout.duration!.toMinutes):\(workout.duration!.toSeconds)"
        distanceLabel.text = String(format: "%.1f", workout.distanceKm!)
        let pace = Double(workout.duration!) / workout.distanceKm!
        avgPaceLabel.text = "\(pace.stringWithPaceFormat) /km"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
