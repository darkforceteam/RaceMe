//
//  ActivitiesVC.swift
//  RaceMe
//
//  Created by Duc Pham Viet on 4/2/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Firebase

class ActivitiesVC: UITableViewController {
    
    fileprivate let cellId = "cell"
    var user: User!
    fileprivate var workouts = [Workout]()
    fileprivate let workoutRef = FIRDatabase.database().reference(withPath: "WORKOUTS")
}

extension ActivitiesVC {
    
    override func viewDidLoad() {
        setupViews()
        dataObserving()
        
    }
    
    fileprivate func setupViews() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func dataObserving() {
        
        workoutRef.observe(.value, with: { (snapshot) in
            for item in snapshot.children {
                let workout = Workout(snapshot: item as! FIRDataSnapshot)
                if workout.userId == self.user.uid {
                    self.workouts.append(workout)
                }
                self.tableView.reloadData()
            }
        })
    }
}

extension ActivitiesVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let distanceKm = workouts[indexPath.row].distanceKm
        let duration = workouts[indexPath.row].duration
        cell.textLabel?.text = String(format: "Distance: %.1f km", distanceKm)
        cell.detailTextLabel?.text = "Duration: \(duration)"
        return cell
    }
}
