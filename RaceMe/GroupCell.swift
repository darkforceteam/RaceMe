//
//  GroupCell.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/8/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = 5
        bannerImageView.layer.cornerRadius = 5
        bannerImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
