//
//  ParticipantViewCell.swift
//  RaceMe
//
//  Created by LVMBP on 4/4/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class ParticipantViewCell: UITableViewCell {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
