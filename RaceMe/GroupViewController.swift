//
//  GroupViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let addButton = UIBarButtonItem(image: UIImage(named: "ic_add"), style: .plain, target: self, action: #selector(GroupViewController.addGroup))
        navigationItem.rightBarButtonItem = addButton
        
        // let notificationsButton = UIBarButtonItem(image: UIImage(named: "notifications"), style: .plain, target: self, action: #selector(ProfileViewController.notifications))
        // navigationItem.leftBarButtonItem = notificationsButton
    }
    
    func addGroup() {
        let profileSettingsViewController = ProfileSettingsViewController(nibName: "ProfileSettingsViewController", bundle: nil)
        navigationController?.pushViewController(profileSettingsViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
