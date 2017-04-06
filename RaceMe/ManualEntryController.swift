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

class ManualEntryController: UIViewController {
    
    fileprivate let ref = FIRDatabase.database().reference()
    fileprivate var isPublic = true
    var user: User!
    
    fileprivate lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("SAVE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = customOrange
        button.addTarget(self, action: #selector(saveButtonDidTouch), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: UIFontWeightLight)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    fileprivate let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Distance"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    fileprivate let distanceField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "distance in meters"
        tf.textAlignment = .right
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        return tf
    }()
    
    fileprivate let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Duration"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    fileprivate let durationField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "duration in seconds"
        tf.textAlignment = .right
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        return tf
    }()
    
    fileprivate let isPublicLabel: UILabel = {
        let label = UILabel()
        label.text = "Public"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    fileprivate let publicSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = true
        sw.addTarget(self, action: #selector(publicSwitchDidChange), for: .valueChanged)
        return sw
    }()
}

extension ManualEntryController {
    
    @objc fileprivate func saveButtonDidTouch() {
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
    
    @objc fileprivate func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func publicSwitchDidChange() {
        isPublic = publicSwitch.isOn ? true : false
    }
    
    fileprivate func showAlert() {
        let alertController = UIAlertController(title: nil, message: "Your input cannot be empty or zero!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ManualEntryController {
    
    override func viewDidLoad() {
        setupViews()
    }
    
    fileprivate func setupViews() {
        title = "Manual Entry"
        view.backgroundColor = .white
        view.addSubview(saveButton)
    }
    
    override func viewWillLayoutSubviews() {
        saveButton.anchorToEdge(.bottom, padding: 15, width: view.frame.width - 30, height: 60)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

