//
//  GroupDetailViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/8/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class GroupDetailViewController: UIViewController {
    
    var group: Group!

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
