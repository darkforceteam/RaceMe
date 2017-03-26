//
//  PickerSettingCell.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/25/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class PickerSettingCell: UITableViewCell {
    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingTextField: UITextField!
    
    var pickerData = [(value: String, title: String)]()
    var picker = UIPickerView()

    override func awakeFromNib() {
        super.awakeFromNib()

        picker.delegate = self
        picker.dataSource = self

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = primaryColor
        toolBar.sizeToFit()
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PickerSettingCell.closePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton,closeButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        settingTextField.inputView = picker
        settingTextField.inputAccessoryView = toolBar
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension PickerSettingCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        settingTextField.text = pickerData[row].value
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].title
    }
    
    func closePicker() {
        settingTextField.resignFirstResponder()
    }
}
