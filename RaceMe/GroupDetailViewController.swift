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
    
    let uid = FIRAuth.auth()!.currentUser!.uid

    @IBOutlet weak var groupBannerImageview: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupDescriptionLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        groupBannerImageview.setImageWith(URL(string: group.banner!)!)
        groupNameLabel.text = group.name
        groupDescriptionLabel.text = group.description
        joinButton.layer.cornerRadius = 3
        
        group.joined(uid: uid) { (status) in
            if ( true == status ) {
                self.joinButton.setTitle("Leave", for: .normal)
                self.joinButton.backgroundColor = darkColor
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onJoinButton(_ sender: UIButton) {
        group.joined(uid: uid) { (status) in
            if ( true == status ) {
                self.group.leave(uid: self.uid)
                self.joinButton.setTitle("Join", for: .normal)
                self.joinButton.backgroundColor = successColor
            } else {
                self.group.join(uid: self.uid)
                self.joinButton.setTitle("Leave", for: .normal)
                self.joinButton.backgroundColor = darkColor
            }
        }
    }
}
