//
//  ProfileViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FacebookCore
import FacebookLogin
import AFNetworking

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userStatisticsScrollView: UIScrollView!
    @IBOutlet weak var userStatisticsPageControl: UIPageControl!
    
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }

    let userStats1 = ["title":"Kilometers", "current_period":"8.3", "last_period":"0"]
    let userStats2 = ["title":"Average Pace (Min/Km)", "current_period":"1:15:08", "last_period":"2:33:54"]
    let userStats3 = ["title":"Activities", "current_period":"2", "last_period":"1"]
    let userStats4 = ["title":"Time Spent", "current_period":"31:52", "last_period":"04:50"]
    
    var userStatisticsArray = [Dictionary<String,String>]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "UserProfileCell", bundle: nil), forCellReuseIdentifier: "UserProfileCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        let editButton = UIBarButtonItem(image: UIImage(named: "pencil"), style: .plain, target: self, action: #selector(ProfileViewController.editProfile))
        navigationItem.rightBarButtonItem = editButton
        
        let notificationsButton = UIBarButtonItem(image: UIImage(named: "notifications"), style: .plain, target: self, action: #selector(ProfileViewController.notifications))
        navigationItem.leftBarButtonItem = notificationsButton
    }
    
    func editProfile() {
        let profileSettingsViewController = ProfileSettingsViewController(nibName: "ProfileSettingsViewController", bundle: nil)
        navigationController?.pushViewController(profileSettingsViewController, animated: true)
    }
    
    func notifications() {
        let notificationsViewController = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
        navigationController?.pushViewController(notificationsViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell", for: indexPath) as! UserProfileCell

        let userRef = dataBaseRef.child("USERS/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            cell.nameLabel.text = user.displayName
            if nil != user.photoUrl {
                let avatarURL = URL(string: user.photoUrl!)
                cell.avatarImage.setImageWith(avatarURL!)
            }
        })
        
        userStatisticsArray = [userStats1,userStats2,userStats3,userStats4]
        for (index, userStatistics) in userStatisticsArray.enumerated() {
            if let userStatisticsView = Bundle.main.loadNibNamed("UserStatistics", owner: self, options: nil)?.first as? UserStatisticsView {
                userStatisticsView.titleLabel.text = userStatistics["title"]
                userStatisticsView.currentPeriodCount.text = userStatistics["current_period"]
                userStatisticsView.lastPeriodCount.text = userStatistics["last_period"]
                cell.userStatisticsScrollView.addSubview(userStatisticsView)
                userStatisticsView.frame.size.width = self.view.bounds.size.width
                userStatisticsView.frame.origin.x = CGFloat(index) * UIScreen.main.bounds.width
            }
        }
        
        return cell
    }
}
