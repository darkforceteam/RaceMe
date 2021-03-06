//
//  ProfileSettingsViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/24/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

enum TableSection: Int {
    case accountInfo = 0, accountActions
}

enum AccountInfoRow: Int {
    case email = 0, birthday, gender, height, weight
    static var count: Int { return 5 }
}

class ProfileSettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var items = ["Email", "Birthday", "Gender", "Height (kg)", "Weight (cm)"]
    var placeholder = ["", "mm dd, yy", "Not Specified", "0", "0"]
    let userRef = FIRDatabase.database().reference().child("USERS/\(FIRAuth.auth()!.currentUser!.uid)")

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RightDetailCell", bundle: nil), forCellReuseIdentifier: "RightDetailCell")
        tableView.register(UINib(nibName: "PickerSettingCell", bundle: nil), forCellReuseIdentifier: "PickerSettingCell")
        tableView.register(UINib(nibName: "DatePickerSettingCell", bundle: nil), forCellReuseIdentifier: "DatePickerSettingCell")
        tableView.register(UINib(nibName: "DisclosureIndicatorCell", bundle: nil), forCellReuseIdentifier: "DisclosureIndicatorCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Settings"
        
        
        
//        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ProfileSettingsViewController.saveUserProfile))
//        navigationItem.rightBarButtonItem = saveButton
    }
    
//    func saveUserProfile() {
//        _ = navigationController?.popToRootViewController(animated: true)
//    }
}

extension ProfileSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection(rawValue: section)! {
        case TableSection.accountActions:
            return 1
        default:
            return AccountInfoRow.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch TableSection(rawValue: section)! {
        case TableSection.accountActions:
            return "Account Actions"
        default:
            return "Account Informations"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TableSection(rawValue: indexPath.section)! {
        case TableSection.accountActions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureIndicatorCell", for: indexPath) as! DisclosureIndicatorCell
            cell.titleLabel.text = "Logout"
            return cell
        default:
            switch AccountInfoRow(rawValue: indexPath.row)! {
            case AccountInfoRow.email:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailCell
                cell.titleLabel.text = "Email"
                cell.detailLabel.text = FIRAuth.auth()?.currentUser?.email
                return cell
            case AccountInfoRow.birthday:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerSettingCell", for: indexPath) as! DatePickerSettingCell
                cell.settingLabel.text = items[indexPath.row]
                cell.settingTextField.placeholder = placeholder[indexPath.row]
                cell.dataRef = "USERS/\((FIRAuth.auth()?.currentUser?.uid)!)/birthday"
                userRef.observe(.value, with: { (snapshot) in
                    let user = User(snapshot: snapshot)
                    if nil != user.birthday {
                        cell.settingTextField.text = user.birthday
                    }
                })
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PickerSettingCell", for: indexPath) as! PickerSettingCell
                cell.settingLabel.text = items[indexPath.row]
                cell.settingTextField.placeholder = placeholder[indexPath.row]
                switch AccountInfoRow(rawValue: indexPath.row)! {
                case AccountInfoRow.height:
                    cell.dataRef = "USERS/\((FIRAuth.auth()?.currentUser?.uid)!)/height"
                    for i in 120...220 {
                        cell.pickerData.append(("\(i)", "\(i) cm"))
                    }
                    userRef.observe(.value, with: { (snapshot) in
                        let user = User(snapshot: snapshot)
                        if nil != user.gender {
                            cell.settingTextField.text = user.height
                        }
                    })
                case AccountInfoRow.weight:
                    cell.dataRef = "USERS/\((FIRAuth.auth()?.currentUser?.uid)!)/weight"
                    for i in 20...150 {
                        cell.pickerData.append(("\(i)", "\(i) kg"))
                    }
                    userRef.observe(.value, with: { (snapshot) in
                        let user = User(snapshot: snapshot)
                        if nil != user.gender {
                            cell.settingTextField.text = user.weight
                        }
                    })
                default:
                    cell.dataRef = "USERS/\((FIRAuth.auth()?.currentUser?.uid)!)/gender"
                    cell.pickerData = [("Not Specified", "Not Specified"), ("Male", "Male"), ("Female", "Female")]
                    userRef.observe(.value, with: { (snapshot) in
                        let user = User(snapshot: snapshot)
                        if nil != user.gender {
                            cell.settingTextField.text = user.gender
                        }
                    })
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch TableSection(rawValue: indexPath.section)! {
        case TableSection.accountActions:
            try! FIRAuth.auth()!.signOut()
            var initialViewController: UIViewController?
            initialViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            var window: UIWindow?
            window = UIWindow(frame: frame)
            window!.rootViewController = initialViewController
            window!.makeKeyAndVisible()
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
