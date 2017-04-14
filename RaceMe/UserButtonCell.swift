//
//  UserButtonCell.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/13/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class UserButtonCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
