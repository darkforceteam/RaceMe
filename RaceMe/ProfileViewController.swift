//
//  ProfileViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import AFNetworking

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "email,name,picture"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(let value):
                let profile = value.dictionaryValue!
                
                //print(profile)
                
                self.nameLabel.text = profile["name"] as! String?

                if let picture = profile["picture"] as? NSDictionary {
                    let avatarURL = URL(string: picture.value(forKeyPath: "data.url") as! String)
                    self.avatarImage.setImageWith(avatarURL!)
                }
                
            case .failed(let error):
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
