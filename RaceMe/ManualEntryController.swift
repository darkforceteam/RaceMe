//
//  ManualEntryController.swift
//  RaceMe
//
//  Created by Duc Pham Viet on 3/30/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Firebase
import Neon
import Font_Awesome_Swift

class ManualEntryController: UIViewController {
    
    let ref = FIRDatabase.database().reference()
    var user: User!
    var isPublic = true
    
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(doneButtonTapped))
        button.FAIcon = .FACheck
        button.tintColor = .black
        return button
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(cancelButtonTapped))
        button.FAIcon = .FAClose
        button.tintColor = .black
        return button
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Distance"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let distanceField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "distance in meters"
        tf.textAlignment = .right
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        return tf
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Duration"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let durationField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "duration in seconds"
        tf.textAlignment = .right
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        return tf
    }()
    
    private let isPublicLabel: UILabel = {
        let label = UILabel()
        label.text = "Public"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let publicSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = true
        sw.addTarget(self, action: #selector(publicSwitchDidChange), for: .valueChanged)
        return sw
    }()
    
    override func viewDidLoad() {
        setupViews()
    }
    
    private func setupViews() {
        title = "Manual Entry"
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        view.addSubview(distanceLabel)
        view.addSubview(distanceField)
        view.addSubview(durationLabel)
        view.addSubview(durationField)
        view.addSubview(isPublicLabel)
        view.addSubview(publicSwitch)
    }
    
    func doneButtonTapped() {
        if distanceField.text != "" && durationField.text != "" {
            if distanceField.text == "0" || durationField.text == "0" {
                showAlert()
            } else {
                let distance = Double(distanceField.text!)
                let duration = Int(durationField.text!)
                let workout = Workout(user, distance!, duration!, isPublic)
                let workoutRef = ref.child(Constants.Workout.TABLE_NAME).childByAutoId()
                workoutRef.setValue(workout.toAnyObject())
                dismiss(animated: true, completion: nil)
            }
        } else {
            showAlert()
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: nil, message: "Your input cannot be empty or zero!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func publicSwitchDidChange() {
        isPublic = publicSwitch.isOn ? true : false
        
        print(isPublic)
    }
    
    override func viewWillLayoutSubviews() {
        distanceLabel.anchorInCorner(.topLeft, xPad: 10, yPad: 74, width: 85, height: 30)
        distanceField.alignAndFillWidth(align: .toTheRightCentered, relativeTo: distanceLabel, padding: 10, height: 30)
        durationLabel.align(.underMatchingLeft, relativeTo: distanceLabel, padding: 10, width: 85, height: 30)
        durationField.alignAndFillWidth(align: .toTheRightCentered, relativeTo: durationLabel, padding: 10, height: 30)
        isPublicLabel.align(.underMatchingLeft, relativeTo: durationLabel, padding: 10, width: 85, height: 30)
        publicSwitch.align(.underMatchingRight, relativeTo: durationField, padding: 10, width: 50, height: 30)
    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        if textField == distanceField {
//            durationField.becomeFirstResponder()
//        }
//        
//        return false
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

