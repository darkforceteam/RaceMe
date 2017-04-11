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
