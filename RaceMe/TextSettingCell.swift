//
//  TextSettingCell.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/24/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class TextSettingCell: UITableViewCell {
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingTextField: UITextField!
    
    var name = ""
    var value = ""
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        settingTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if ( "" != textField.text ) {
            name = textField.text!
        }
    }
    
}
