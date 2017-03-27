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

class ProfileViewController: UIViewController, UIScrollViewDelegate {
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
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: UIScreen.main.bounds.height))
        scrollView.addSubview(view)
        view = scrollView
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollView.backgroundColor = .white
        
        userStatisticsArray = [userStats1,userStats2,userStats3,userStats4]
        userStatisticsScrollView.isPagingEnabled = true
        userStatisticsScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(userStatisticsArray.count), height: 120)
        userStatisticsScrollView.showsHorizontalScrollIndicator = false
        userStatisticsScrollView.delegate = self
        loadUserStatistics()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.width / 2
        self.avatarImage.layer.borderColor = UIColor.white.cgColor
        self.avatarImage.layer.borderWidth = 3
        self.avatarImage.clipsToBounds = true
        loadUserInfo()
    }

    func loadUserInfo() {
        let userRef = dataBaseRef.child("USERS/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            self.nameLabel.text = user.displayName
            if nil != user.photoUrl {
                let avatarURL = URL(string: user.photoUrl!)
                self.avatarImage.setImageWith(avatarURL!)
            }
        })
    }

    func loadUserStatistics() {
        for (index, userStatistics) in userStatisticsArray.enumerated() {
            if let userStatisticsView = Bundle.main.loadNibNamed("UserStatistics", owner: self, options: nil)?.first as? UserStatisticsView {
                userStatisticsView.titleLabel.text = userStatistics["title"]
                userStatisticsView.currentPeriodCount.text = userStatistics["current_period"]
                userStatisticsView.lastPeriodCount.text = userStatistics["last_period"]
                userStatisticsScrollView.addSubview(userStatisticsView)
                userStatisticsView.frame.size.width = self.view.bounds.size.width
                userStatisticsView.frame.origin.x = CGFloat(index) * UIScreen.main.bounds.width
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        userStatisticsPageControl.currentPage = Int(page)
    }

    @IBAction func onSettingsButton(_ sender: UIButton) {
        let profileSettingsViewController = ProfileSettingsViewController(nibName: "ProfileSettingsViewController", bundle: nil)
        navigationController?.pushViewController(profileSettingsViewController, animated: true)
        
    }
    
    @IBAction func onNotificationsButton(_ sender: UIButton) {
        let notificationsViewController = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
        navigationController?.pushViewController(notificationsViewController, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
