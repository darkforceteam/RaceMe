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

    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            let userRef = dataBaseRef.child("USERS/\(FIRAuth.auth()!.currentUser!.uid)")
            userRef.observe(.value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                cell.nameLabel.text = user.displayName
                if nil != user.photoUrl {
                    let avatarURL = URL(string: user.photoUrl!)
                    cell.avatarImage.setImageWith(avatarURL!)
                }
            })
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            cell.iconImageView.image = UIImage(named: "ic_history")?.withRenderingMode(.alwaysTemplate)
            cell.iconImageView.tintColor = darkColor
            cell.descLabel.text = "0 Tracked"
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
}
