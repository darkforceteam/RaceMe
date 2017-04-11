//
//  MemberListViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/10/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class MemberListViewController: UIViewController {
    
    var members = [User]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MemberCell", bundle: nil), forCellReuseIdentifier: "MemberCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MemberListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        cell.avatarImageView.setImageWith(URL(string: members[indexPath.row].photoUrl!)!)
        cell.displayNameLabel.text = members[indexPath.row].displayName
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileViewController.uid = members[indexPath.row].key!
        navigationController?.pushViewController(profileViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
