//
//  GroupInfoCell.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/9/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseAuth

class GroupInfoCell: UITableViewCell {

    @IBOutlet weak var groupBannerImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupDescriptionLabel: UILabel!
    @IBOutlet weak var groupJoinButton: UIButton!
    @IBOutlet weak var groupMemberCount: UILabel!
    @IBOutlet weak var groupActivityCount: UILabel!
    @IBOutlet weak var groupDiscussionCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        groupJoinButton.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
