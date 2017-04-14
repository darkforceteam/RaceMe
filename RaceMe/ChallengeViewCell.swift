//
//  ChallengeViewCell.swift
//  RaceMe
//
//  Created by LVMBP on 4/10/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class ChallengeViewCell: UITableViewCell {

    @IBOutlet weak var chalImage: UIImageView!
    @IBOutlet weak var chalNameLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!

    @IBOutlet weak var chalDescLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //chalImage.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
