//
//  UserProfileCell.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/28/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserProfileCell: UITableViewCell, UIScrollViewDelegate {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userStatisticsScrollView: UIScrollView!
    @IBOutlet weak var userStatisticsPageControl: UIPageControl!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var workoutCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    
    var currentDistance = 0.0
    var lastDistance = 0.0
    var currentAvgPace = 0.0
    var lastAvgPace = 0.0
    var currentActivity = 0
    var lastActivity = 0
    var currentTime = 0
    var lastTime = 0
    var userStatisticsArray = [Dictionary<String,String>]()
    var ref: FIRDatabaseReference!
    
    var userStats1 = [String:String]()
    var userStats2 = [String:String]()
    var userStats3 = [String:String]()
    var userStats4 = [String:String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ref = FIRDatabase.database().reference()
        
        // Config Avatar
        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2
        avatarImage.clipsToBounds = true
        followButton.layer.cornerRadius = 3
        
        // Config Scroll View
        userStatisticsScrollView.isPagingEnabled = true
        userStatisticsScrollView.contentSize = CGSize(width: frame.width * 4, height: 120)
        userStatisticsScrollView.showsHorizontalScrollIndicator = false
        userStatisticsScrollView.delegate = self
        
        loadUserStatistics()
    }
    
    func loadUserStatistics() {
        ref.child("WORKOUTS").queryOrdered(byChild: "user_id").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren() {
                for activityData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    let oneActivity = Workout(snapshot: activityData)
                    self.currentDistance = self.currentDistance + oneActivity.distanceKm!
                    self.currentActivity = self.currentActivity + 1
                    self.currentTime = self.currentTime + oneActivity.duration!
                }
            }
            
            let theCurrentDistance = String(format: "%.1f", self.currentDistance)
            self.currentAvgPace = Double(self.currentTime) / self.currentDistance
            
            self.userStats1 = ["title":"Kilometers", "current_period": theCurrentDistance, "last_period": "\(self.lastDistance)"]
            self.userStats2 = ["title":"Average Pace (Min/Km)", "current_period": "\(self.currentAvgPace.stringWithPaceFormat)", "last_period": "\(self.lastAvgPace.stringWithPaceFormat)"]
            self.userStats3 = ["title":"Activities", "current_period": "\(self.currentActivity)", "last_period": "\(self.lastActivity)"]
            self.userStats4 = ["title":"Time Spent", "current_period": "\(self.currentTime.toMinutes):\(self.currentTime.toSeconds)", "last_period": "\(self.lastTime.toMinutes):\(self.lastTime.toSeconds)"]
            
            self.userStatisticsArray = [self.userStats1,self.userStats2,self.userStats3,self.userStats4]
            for (index, userStatistics) in self.userStatisticsArray.enumerated() {
                if let userStatisticsView = Bundle.main.loadNibNamed("UserStatistics", owner: self, options: nil)?.first as? UserStatisticsView {
                    userStatisticsView.titleLabel.text = userStatistics["title"]
                    userStatisticsView.currentPeriodCount.text = userStatistics["current_period"]
                    userStatisticsView.lastPeriodCount.text = userStatistics["last_period"]
                    self.userStatisticsScrollView.addSubview(userStatisticsView)
                    userStatisticsView.frame.size.width = self.frame.width
                    userStatisticsView.frame.origin.x = CGFloat(index) * self.frame.width
                }
            }
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = userStatisticsScrollView.contentOffset.x / userStatisticsScrollView.frame.size.width
        userStatisticsPageControl.currentPage = Int(page)
    }
    
}
