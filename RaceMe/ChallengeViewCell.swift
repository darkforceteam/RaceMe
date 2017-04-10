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

    
    @IBOutlet weak var totWOLabel: UILabel!
    
    @IBOutlet weak var totDistLabel: UILabel!
    @IBOutlet weak var weeklyWOLabel: UILabel!
    @IBOutlet weak var weeklyDistLabel: UILabel!
    @IBOutlet weak var miWODistLabel: UILabel!
    
    @IBOutlet weak var longRunDistLabel: UILabel!
    @IBOutlet weak var longRunNoLabel: UILabel!
    @IBOutlet weak var minWOPaceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
