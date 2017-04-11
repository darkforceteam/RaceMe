//
//  AddChallengeVC.swift
//  RaceMe
//
//  Created by LVMBP on 4/11/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class AddChallengeVC: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var groupPick: UITextField!
    @IBOutlet weak var startDatePick: UITextField!
    @IBOutlet weak var endDatePick: UITextField!
    @IBOutlet weak var chalTotLongRunDist: UITextField!
    @IBOutlet weak var chalTotLongRun: UITextField!
    @IBOutlet weak var chalTotWOPick: UITextField!
    @IBOutlet weak var chalToDistPick: UITextField!
    @IBOutlet weak var weekTotWOPick: UITextField!
    @IBOutlet weak var weekTotDistPick: UITextField!
    @IBOutlet weak var weekLongRunPick: UITextField!
    @IBOutlet weak var weekLongRunDistPick: UITextField!
    @IBOutlet weak var woMinDistPick: UITextField!
    @IBOutlet weak var woMinPacePick: UITextField!

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let dataPicker = UIPickerView()
    var groups = [Group]()
    var ref: FIRDatabaseReference!
    var selectedGroupId: String?
    let fixedData = ["Public","Friends"]
    var startDate: Date?
    var endDate: Date?
    var challenge: Challenge?
    var userId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        loadGroup()
        if challenge == nil{
            deleteBtn.isHidden = true
            createBtn.isEnabled = false
            groupPick.text = fixedData[0]
        } else {
            createBtn.isHidden = true
        }
        createBtn.backgroundColor = UIColor(136, 192, 87)
        createBtn.layer.cornerRadius = 5
        dataPicker.delegate = self
        groupPick.inputView = dataPicker
        hideKeyboardWhenTappedAround()
        dateFormatter.dateStyle = .medium
        setupDatePicker()
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        startDatePick.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        endDatePick.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        chalTotWOPick.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    func textFieldDidChange(textField: UITextField) {
        if nameTextField.text == "" || startDatePick.text == "" || endDatePick.text == "" || chalTotWOPick.text == "" {
            //Disable button
            createBtn.isEnabled = false
        } else {
            //Enable button
            createBtn.isEnabled = true
        }
    }
    
    func setupDatePicker(){
        startDate = Date()
        startDatePicker.minimumDate = startDate
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(self.datePickerHandler), for: UIControlEvents.valueChanged)
        startDatePick.inputView = startDatePicker
        startDatePick.text = "\(dateFormatter.string(from: startDate!))"
        
        updateEndDate(startDate: startDate!)
        endDatePicker.datePickerMode = .date
        endDatePicker.addTarget(self, action: #selector(self.datePickerHandler), for: UIControlEvents.valueChanged)
        endDatePick.inputView = endDatePicker
    }

    func updateEndDate(startDate: Date){
        var components = DateComponents()
        components.day = 7
        let minEndDate = Calendar.current.date(byAdding: components, to: startDate)
        endDatePicker.minimumDate = minEndDate
        
        components.day = 30
        endDate = Calendar.current.date(byAdding: components, to: startDate)
        endDatePick.text = "\(dateFormatter.string(from: endDate!))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func datePickerHandler(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if sender == startDatePicker {
            startDate = startDatePicker.date
            startDatePick.text = "\(dateFormatter.string(from: startDate!))"
            updateEndDate(startDate: startDatePicker.date)
            startDatePick.resignFirstResponder()
        } else {
            endDate = endDatePicker.date
            endDatePick.text = "\(dateFormatter.string(from: endDate!))"
            endDatePick.resignFirstResponder()
        }
    }
    
    @IBAction func createChallenge(_ sender: UIButton) {
        let chalRef = ref.child(Constants.Challenge.table_name).childByAutoId()
        chalRef.child(Constants.Challenge.created_by).setValue(userId)
        if nameTextField.text != "" {
            chalRef.child(Constants.Challenge.challenge_name).setValue("\(nameTextField.text!)")
        }
        if groupPick.text != "" {
            chalRef.child(Constants.Challenge.for_group).setValue("\(groupPick.text!)")
        }
        if startDatePick.text != "" {
            chalRef.child(Constants.Challenge.start_date).setValue(self.startDate!.timeIntervalSince1970)
        }
        if endDatePick.text != "" {
            chalRef.child(Constants.Challenge.end_date).setValue(self.endDate!.timeIntervalSince1970)
        }
        if chalTotLongRunDist.text != "" {
            chalRef.child(Constants.Challenge.total_long_wo_dist).setValue(Double(chalTotLongRunDist.text!))
        }
        if chalTotLongRun.text != "" {
            chalRef.child(Constants.Challenge.total_long_wo_no).setValue(Int(chalTotLongRun.text!))
        }
        if chalTotWOPick.text != "" {
            chalRef.child(Constants.Challenge.total_wo_no).setValue(Int(chalTotWOPick.text!))
        }
        if chalToDistPick.text != "" {
            chalRef.child(Constants.Challenge.total_distant).setValue(Double(chalToDistPick.text!))
        }
        if weekTotWOPick.text != "" {
            chalRef.child(Constants.Challenge.week_wo_no).setValue(Int(weekTotWOPick.text!))
        }
        if weekTotDistPick.text != "" {
            chalRef.child(Constants.Challenge.week_distant).setValue(Double(weekTotDistPick.text!))
        }
        if weekLongRunPick.text != "" {
            chalRef.child(Constants.Challenge.week_long_wo_no).setValue(Int(weekLongRunPick.text!))
        }
        if weekLongRunDistPick.text != "" {
            chalRef.child(Constants.Challenge.week_long_wo_dist).setValue(Double(weekLongRunDistPick.text!))
        }
        if woMinDistPick.text != "" {
            chalRef.child(Constants.Challenge.min_wo_dist).setValue(Double(woMinDistPick.text!))
        }
        if woMinPacePick.text != "" {
            chalRef.child(Constants.Challenge.min_wo_pace).setValue(Double(woMinPacePick.text!))
        }
        chalRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value as? NSDictionary) != nil{
                self.challenge = Challenge(snapshot: snapshot)
                self.createBtn.isHidden = true
            }
        })
    }
    func loadGroup(){
        self.ref.child(Constants.Group.TABLE_NAME).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren(){
                for challengeData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    let group = Group(snapshot: challengeData)
                    self.groups.append(group)
                }
            }
        }, withCancel: { (error) in
            print(error)
        })
    }

    @IBAction func deleteChallenge(_ sender: UIButton) {
        let challengePath = "\(Constants.Challenge.table_name)/\(self.challenge!.id)"
        
        let chalRecord = ref.child(challengePath)
        //        print(userRecord)
        chalRecord.removeValue { (error, refer) in
            if error != nil {
                print(error!)
            } else {
                self.deleteBtn.isHidden = true
                self.createBtn.isHidden = false
                self.clearInput()
            }
        }
    }
    func clearInput(){
        setupDatePicker()
        chalTotLongRunDist.text = ""
        chalTotLongRun.text = ""
        chalTotWOPick.text = ""
        chalToDistPick.text = ""
        weekTotWOPick.text = ""
        weekTotDistPick.text = ""
        weekLongRunPick.text = ""
        weekLongRunDistPick.text = ""
        woMinDistPick.text = ""
        woMinPacePick.text = ""
    }
}
extension AddChallengeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groups.count + 2
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0{
            selectedGroupId = fixedData[0]
            groupPick.text = fixedData[0]
        } else if row == 1{
            selectedGroupId = fixedData[1]
            groupPick.text = fixedData[1]
        } else {
            if groups.count > 0 {
                selectedGroupId = groups[row-2].key
                groupPick.text = groups[row-2].name
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0{
            return fixedData[0]
        } else if row == 1{
            return  fixedData[1]
        } else {
            return groups[row-2].name
        }
    }
    func closePicker() {
        groupPick.resignFirstResponder()
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
