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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Config Avatar
        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2
        avatarImage.layer.borderColor = UIColor.white.cgColor
        avatarImage.layer.borderWidth = 3
        avatarImage.clipsToBounds = true
        
        // Config Scroll View
        userStatisticsScrollView.isPagingEnabled = true
        userStatisticsScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 4, height: 120)
        userStatisticsScrollView.showsHorizontalScrollIndicator = true
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
