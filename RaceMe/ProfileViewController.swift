//
//  ProfileViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

import AFNetworking

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var ref: FIRDatabaseReference!
    var workoutCount = 0
    var uid: String = FIRAuth.auth()!.currentUser!.uid
    let current_uid = FIRAuth.auth()!.currentUser!.uid
    
    var currentDistance = 0.0
    var lastDistance = 0.0
    var currentAvgPace = 0.0
    var lastAvgPace = 0.0
    var currentActivity = 0
    var lastActivity = 0
    var currentTime = 0
    var lastTime = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: Int(self.tableView.frame.size.width), height: 1))
        tableView.register(UINib(nibName: "UserProfileCell", bundle: nil), forCellReuseIdentifier: "UserProfileCell")
        tableView.register(UINib(nibName: "UserInfoCell", bundle: nil), forCellReuseIdentifier: "UserInfoCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        let editButton = UIBarButtonItem(image: UIImage(named: "pencil"), style: .plain, target: self, action: #selector(ProfileViewController.editProfile))
        navigationItem.rightBarButtonItem = editButton
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return view.frame.height - 49 - 150
        default:
            return 50
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell", for: indexPath) as! UserProfileCell
            let userRef = ref.child("USERS/\(uid)")
            userRef.observe(.value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                cell.nameLabel.text = user.displayName
                if nil != user.photoUrl {
                    let avatarURL = URL(string: user.photoUrl!)
                    cell.avatarImage.setImageWith(avatarURL!)
                }
                
                if ( self.current_uid == self.uid ) {
                    cell.followButton.isHidden = true
                } else {
                    user.hasFollower(uid: self.current_uid) { (status) in
                        if ( false == status ) {
                            cell.followButton.tag = 2
                            cell.followButton.setTitle("FOLLOW", for: .normal)
                            cell.followButton.backgroundColor = successColor
                        } else {
                            cell.followButton.tag = 1
                            cell.followButton.setTitle("UNFOLLOW", for: .normal)
                            cell.followButton.backgroundColor = darkColor
                        }
                        cell.followButton.addTarget(self, action: #selector(ProfileViewController.follow), for: .touchUpInside)
                    }
                }
                
                user.followersCount(completion: { (count) in
                    cell.followerCount.text = "\(count)"
                })
                
                user.followingCount(completion: { (count) in
                    cell.followingCount.text = "\(count)"
                })
            })
            
            ref.child("WORKOUTS").queryOrdered(byChild: "user_id").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChildren() {
                    cell.workoutCount.text = "\(Int(snapshot.childrenCount))"
                    for activityData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        let oneActivity = Workout(snapshot: activityData)
                        self.currentDistance = self.currentDistance + oneActivity.distanceKm!
                        self.currentActivity = self.currentActivity + 1
                        self.currentTime = self.currentTime + oneActivity.duration!
                    }
                }
                
                let theCurrentDistance = String(format: "%.1f", self.currentDistance)
                if 0 < self.currentDistance {
                    self.currentAvgPace = Double(self.currentTime) / self.currentDistance
                }
                
                let userStats1 = ["title":"Kilometers", "current_period": theCurrentDistance, "last_period": "\(self.lastDistance)"]
                let userStats2 = ["title":"Average Pace (Min/Km)", "current_period": "\(self.currentAvgPace.stringWithPaceFormat)", "last_period": "\(self.lastAvgPace.stringWithPaceFormat)"]
                let userStats3 = ["title":"Activities", "current_period": "\(self.currentActivity)", "last_period": "\(self.lastActivity)"]
                let userStats4 = ["title":"Time Spent", "current_period": "\(self.currentTime.toMinutes):\(self.currentTime.toSeconds)", "last_period": "\(self.lastTime.toMinutes):\(self.lastTime.toSeconds)"]
                
                let userStatisticsArray = [userStats1,userStats2,userStats3,userStats4]
                for (index, userStatistics) in userStatisticsArray.enumerated() {
                    if let userStatisticsView = Bundle.main.loadNibNamed("UserStatistics", owner: self, options: nil)?.first as? UserStatisticsView {
                        userStatisticsView.titleLabel.text = userStatistics["title"]
                        userStatisticsView.currentPeriodCount.text = userStatistics["current_period"]
                        userStatisticsView.lastPeriodCount.text = userStatistics["last_period"]
                        cell.userStatisticsScrollView.addSubview(userStatisticsView)
                        userStatisticsView.frame.size.width = cell.frame.width
                        userStatisticsView.frame.origin.x = CGFloat(index) * cell.frame.width
                    }
                }
            })
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            cell.iconImageView.image = UIImage(named: "ic_history")?.withRenderingMode(.alwaysTemplate)
            cell.iconImageView.tintColor = darkColor
            ref.child("WORKOUTS").queryOrdered(byChild: "user_id").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChildren() {
                    cell.descLabel.text = "\(Int(snapshot.childrenCount)) Tracked"
                }
            })
            cell.titleLabel.text = "Activities"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            cell.iconImageView.image = UIImage(named: "ic_timeline")?.withRenderingMode(.alwaysTemplate)
            cell.iconImageView.tintColor = darkColor
            cell.descLabel.text = ""
            cell.titleLabel.text = "Records"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            cell.iconImageView.image = UIImage(named: "ic_group")?.withRenderingMode(.alwaysTemplate)
            cell.iconImageView.tintColor = darkColor
            cell.descLabel.text = ""
            cell.titleLabel.text = "Groups"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            let activitiesViewController = ActivitiesViewController(nibName: "ActivitiesViewController", bundle: nil)
            activitiesViewController.uid = uid
            navigationController?.pushViewController(activitiesViewController, animated: true)
        case 2:
            let profileRecordsViewController = ProfileRecordsViewController(nibName: "ProfileRecordsViewController", bundle: nil)
            navigationController?.pushViewController(profileRecordsViewController, animated: true)
        case 3:
            let profileGroupsViewController = ProfileGroupsViewController(nibName: "ProfileGroupsViewController", bundle: nil)
            navigationController?.pushViewController(profileGroupsViewController, animated: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func follow(sender: UIButton) {
        if ( sender.tag == 1 ) {
            ref.child("USERS/\(current_uid)/following/\(uid)").removeValue()
            ref.child("USERS/\(uid)/followers/\(current_uid)").removeValue()
            print("Unfollowed")
        } else {
            print("Followed")
            ref.child("USERS/\(current_uid)/following/\(uid)").setValue(NSDate().timeIntervalSince1970 * 1000)
            ref.child("USERS/\(uid)/followers/\(current_uid)").setValue(NSDate().timeIntervalSince1970 * 1000)
        }
    }
}
