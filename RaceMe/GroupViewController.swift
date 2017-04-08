//
//  GroupViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MBProgressHUD

class GroupViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var groups = [Group]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "GroupCell")
        refreshControl.addTarget(self, action: #selector(GroupViewController.loadGroups), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let addButton = UIBarButtonItem(image: UIImage(named: "ic_add"), style: .plain, target: self, action: #selector(GroupViewController.addGroup))
        navigationItem.rightBarButtonItem = addButton
        
        loadGroups()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 225
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        cell.nameLabel.text = groups[indexPath.row].name
        cell.bannerImageView.setImageWith(URL(string: groups[indexPath.row].banner!)!)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupDetailVC = GroupDetailViewController()
        groupDetailVC.group = groups[indexPath.row]
        navigationController?.pushViewController(groupDetailVC, animated: true)
    }
    
    func addGroup() {
        let addGroupViewController = AddGroupViewController(nibName: "AddGroupViewController", bundle: nil)
        navigationController?.pushViewController(addGroupViewController, animated: true)
    }
    
    func loadGroups() {
        groups = [Group]()
        FIRDatabase.database().reference().child("GROUPS").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren() {
                for groupData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    let oneGroup = Group(snapshot: groupData)
                    self.groups.append(oneGroup)
                }
                self.groups.reverse()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
}
