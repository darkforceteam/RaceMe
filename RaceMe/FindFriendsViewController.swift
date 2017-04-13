//
//  FindFriendsViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FacebookCore

class FindFriendsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var friends = [String:Any]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadFriends()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserButtonCell", bundle: nil), forCellReuseIdentifier: "UserButtonCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FindFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserButtonCell", for: indexPath) as! UserButtonCell
//        let friend = friends[indexPath.row]
//        cell.avatarImageView.setImageWith(URL(string: friend["picture"]))
//        cell.displayNameLabel.text = friend["name"]
        return cell
    }

    func loadFriends() {
        let params = ["fields": "id, first_name, last_name, name, email, picture"]
        
        let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
        let connection = FBSDKGraphRequestConnection()
        connection.add(graphRequest, completionHandler: { (connection, result, error) in
            if error == nil {
                if let userData = result as? [String:Any] {
                    self.friends = userData
                    print(userData)
                }
            } else {
                print("Error Getting Friends \(error)");
            }
            
        })
        
        connection.start()
    }
}
