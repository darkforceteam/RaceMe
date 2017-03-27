//
//  DatePickerSettingCell.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/26/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DatePickerSettingCell: UITableViewCell {
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingTextField: UITextField!
    
    var dataRef: String?
    var datePicker = UIDatePicker()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var components = DateComponents()
        components.year = -100
        let minDate = Calendar.current.date(byAdding: components, to: Date())
        
        components.year = -10
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.datePickerMode = .date

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = primaryColor
        toolBar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DatePickerSettingCell.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DatePickerSettingCell.donePicker))
        toolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        settingTextField.inputView = datePicker
        settingTextField.inputAccessoryView = toolBar
    }

    func donePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        settingTextField.text = "\(dateFormatter.string(from: datePicker.date))"
        
        if ( nil != dataRef ) {
            FIRDatabase.database().reference().child(dataRef!).setValue("\(dateFormatter.string(from: datePicker.date))")
        }
        
        settingTextField.resignFirstResponder()
    }
    func cancelPicker() {
        settingTextField.resignFirstResponder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
