//
//  ActivitiesViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/29/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ActivitiesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var ref: FIRDatabaseReference!
    var items = [Workout]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        loadActivities()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: Int(self.tableView.frame.size.width), height: 1))
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        tableView.register(UINib(nibName: "RightDetailArrowCell", bundle: nil), forCellReuseIdentifier: "RightDetailArrowCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Activities"
        
    }
}

extension ActivitiesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailArrowCell", for: indexPath) as! RightDetailArrowCell
        cell.titleLabel.text = String(format: "%.1f km", items[indexPath.row].distanceKm)
        cell.detailLabel.text = "\(items[indexPath.row].duration.toMinutes):\(items[indexPath.row].duration.toSeconds)"
        return cell
    }
    
    func loadActivities() {
        ref.child("WORKOUTS").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren() {
                for activityData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    //self.items.append(activityData.value as! Workout)
                    let oneActivity = Workout(snapshot: activityData)
                    print(oneActivity.distanceKm)
                    self.items.append(oneActivity)
                }
//                print(snapshot)
                print(self.items)
                self.tableView.reloadData()
            }
        })
    }
}
