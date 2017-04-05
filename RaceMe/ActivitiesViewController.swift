//
//  ActivitiesViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/29/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ActivitiesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var ref: FIRDatabaseReference!
    var items = [Workout]()
    var sections = Dictionary<String, Array<Workout>>()
    var sortedSections = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        loadActivities()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: Int(self.tableView.frame.size.width), height: 1))
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        tableView.register(UINib(nibName: "UserInfoCell", bundle: nil), forCellReuseIdentifier: "UserInfoCell")
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[sortedSections[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateString = "\(sortedSections[section])"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "EEE (mm/dd)"
        let headerTitle = "\(dateFormatter.string(from: dateObj!))"
        return headerTitle
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
        
        let tableSection = sections[sortedSections[indexPath.section]]
        let tableItem = tableSection![indexPath.row]
        cell.iconImageView.image = UIImage(named: "ic_directions_run")?.withRenderingMode(.alwaysTemplate)
        cell.iconImageView.tintColor = darkColor
        cell.titleLabel.text = String(format: "%.1f km", tableItem.distanceKm!)
        cell.descLabel.text = "\((tableItem.duration?.toMinutes)!):\((tableItem.duration?.toSeconds)!)"
        return cell
    }
    
    func loadActivities() {
        ref.child("WORKOUTS").queryOrdered(byChild: "user_id").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren() {
                for activityData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    let oneActivity = Workout(snapshot: activityData)

                    let date = "\(oneActivity.startTime!)"
                    let index = date.index(date.startIndex, offsetBy: 10)
                    let subDate = date.substring(to: index)
                    
                    if self.sections.index(forKey: subDate) == nil {
                        self.sections[subDate] = [oneActivity]
                    } else {
                        self.sections[subDate]!.append(oneActivity)
                    }
                    self.sortedSections = self.sections.keys.sorted().reversed()
                }
                self.tableView.reloadData()
            }
        })
    }
}
