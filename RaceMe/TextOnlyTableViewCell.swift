//
//  TextOnlyTableViewCell.swift
//  RaceMe
//
//  Created by LVMBP on 3/25/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class TextOnlyTableViewCell: UITableViewCell {
    @IBOutlet weak var cellValueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
