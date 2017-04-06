//
//  UserInfoCell.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/29/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class UserInfoCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        iconImageView.image = iconImageView.image!.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = darkColor
        titleLabel.textColor = darkColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
