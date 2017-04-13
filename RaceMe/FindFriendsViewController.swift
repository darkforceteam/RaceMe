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
    var friendList = [UserObject]()
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
        return self.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserButtonCell", for: indexPath) as! UserButtonCell
        //        let friend = friends[indexPath.row]
        //        cell.avatarImageView.setImageWith(URL(string: friend["picture"]))
        //        cell.displayNameLabel.text = friend["name"]
        let user = self.friendList[indexPath.row]
        cell.displayNameLabel.text = user.displayName!
        print(user.displayName!)
        print(user.uid)
        print(user.photoUrl!)
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
                    
                    let friendListData = userData["data"] as? [[String: Any]]
                    
                    //looping through all the json objects in the array teams
                    for i in 0 ..< friendListData!.count{
                        let name = (friendListData![i]["name"] as! NSString) as String
                        let userId = (friendListData![i]["id"] as! NSString).integerValue
                        let user = UserObject(uid: "\(userId)", name: name)
                        let pictureData = friendListData![i]["picture"] as! [String:Any]
                        let data = pictureData["data"] as! [String:Any]
                        let photoUrl = (data["url"] as! NSString) as String
                        user.photoUrl = photoUrl
                        self.friendList.append(user)
                    }
                    self.tableView.reloadData()
                }
            } else {
                print("Error Getting Friends \(error)");
            }
            
        })
        
        connection.start()
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
