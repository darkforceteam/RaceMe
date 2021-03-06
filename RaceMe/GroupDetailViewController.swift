//
//  GroupDetailViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/8/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class GroupDetailViewController: UIViewController {
    
    var group: Group!
    var members = [User]()
    let uid = FIRAuth.auth()!.currentUser!.uid
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getMembers(group_key: group.key!)
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GroupInfoCell", bundle: nil), forCellReuseIdentifier: "GroupInfoCell")
        tableView.register(UINib(nibName: "DisclosureIndicatorCell", bundle: nil), forCellReuseIdentifier: "DisclosureIndicatorCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
}

extension GroupDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfoCell", for: indexPath) as! GroupInfoCell
            cell.groupBannerImageView.setImageWith(URL(string: (group?.banner!)!)!)
            cell.groupNameLabel.text = group?.name
            cell.groupDescriptionLabel.text = group?.description
            cell.groupJoinButton.addTarget(self, action: #selector(GroupDetailViewController.changeButtonStates), for: .touchUpInside)
            group.memberCount { (count) in
                cell.groupMemberCount.text = "\(count)"
            }
            group?.joined(uid: uid) { (status) in
                if ( true == status ) {
                    cell.groupJoinButton.setTitle("Leave", for: .normal)
                    cell.groupJoinButton.backgroundColor = darkColor
                }
            }
            cell.selectionStyle = .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureIndicatorCell", for: indexPath) as! DisclosureIndicatorCell
            cell.titleLabel.text = "Members"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1 :
            let memberListViewController = MemberListViewController(nibName: "MemberListViewController", bundle: nil)
            memberListViewController.members = members
            navigationController?.pushViewController(memberListViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
    
    func changeButtonStates(sender: UIButton) {
        group?.joined(uid: uid) { (status) in
            if ( true == status ) {
                self.group?.leave(uid: self.uid)
                sender.setTitle("Join", for: .normal)
                sender.backgroundColor = successColor
            } else {
                self.group?.join(uid: self.uid)
                sender.setTitle("Leave", for: .normal)
                sender.backgroundColor = darkColor
            }
        }
    }
    
    func getMembers(group_key: String) {
        FIRDatabase.database().reference().child("GROUPS/\(group_key)/members").observeSingleEvent(of: .value, with: { (snapshot) in
            for memberData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                FIRDatabase.database().reference().child("USERS/\(memberData.key)").observeSingleEvent(of: .value, with: { (userSnapshot) in
                    let user = User(snapshot: userSnapshot)
                    self.members.append(user)
                    //print(self.members.count)
                    //self.tableView.reloadData()
                })
            }
            self.tableView.reloadData()
        })
    }
}

