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
    var items = ["Hung Dinh", "John Doe", "Thanh LuuThanh LuuThanh LuuThanh Luu", "Long Vu"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
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
        loadActivities()
    }
}

extension ActivitiesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailArrowCell", for: indexPath) as! RightDetailArrowCell
        cell.titleLabel.text = items[indexPath.row]
        cell.detailLabel.text = items[indexPath.row]
        return cell
    }
    
    func loadActivities() {
        ref.child("WORKOUTS").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren() {
                print(snapshot)
            }
        })
    }
}
