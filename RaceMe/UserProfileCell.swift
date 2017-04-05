//
//  UserProfileCell.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/28/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class UserProfileCell: UITableViewCell, UIScrollViewDelegate {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userStatisticsScrollView: UIScrollView!
    @IBOutlet weak var userStatisticsPageControl: UIPageControl!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var workoutCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    
    var distanceThisMonth = 0.0
    var distanceLastMonth = 0.0
    var avgPaceThisMonth = "0:0"
    var avgPaceLastMonth = "0:0"
    
    let userStats1 = ["title":"Kilometers", "current_period":"8.3", "last_period":"0"]
    let userStats2 = ["title":"Average Pace (Min/Km)", "current_period":"1:15:08", "last_period":"2:33:54"]
    let userStats3 = ["title":"Activities", "current_period":"2", "last_period":"1"]
    let userStats4 = ["title":"Time Spent", "current_period":"31:52", "last_period":"04:50"]
    
    var userStatisticsArray = [Dictionary<String,String>]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        userStatisticsArray = [userStats1,userStats2,userStats3,userStats4]
        for (index, userStatistics) in userStatisticsArray.enumerated() {
            if let userStatisticsView = Bundle.main.loadNibNamed("UserStatistics", owner: self, options: nil)?.first as? UserStatisticsView {
                userStatisticsView.titleLabel.text = userStatistics["title"]
                userStatisticsView.currentPeriodCount.text = userStatistics["current_period"]
                userStatisticsView.lastPeriodCount.text = userStatistics["last_period"]
                userStatisticsScrollView.addSubview(userStatisticsView)
                userStatisticsView.frame.size.width = frame.width
                userStatisticsView.frame.origin.x = CGFloat(index) * frame.width
            }
        }
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
