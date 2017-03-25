//
//  ProfileSettingsViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/24/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileSettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var items = ["Item 1", "Item2", "Item3", "Item4"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        //tableView.tableFooterView?.backgroundColor = .black
        tableView.register(UINib(nibName: "TextSettingCell", bundle: nil), forCellReuseIdentifier: "TextSettingCell")
        tableView.register(UINib(nibName: "DisclosureIndicatorCell", bundle: nil), forCellReuseIdentifier: "DisclosureIndicatorCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 1
        default:
            return items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureIndicatorCell", for: indexPath) as! DisclosureIndicatorCell
            cell.titleLabel.text = "Logout"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextSettingCell", for: indexPath) as! TextSettingCell
            cell.settingLabel.text = items[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            try! FIRAuth.auth()!.signOut()
            var initialViewController: UIViewController?
            initialViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            var window: UIWindow?
            window = UIWindow(frame: frame)
            window!.rootViewController = initialViewController
            window!.makeKeyAndVisible()
        default:
            break
        }
    }
}
