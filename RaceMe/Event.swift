//
//  Event.swift
//  RaceMe
//
//  Created by LVMBP on 3/27/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class Event: NSObject {
    var start_time: Date
    var route_id: String
    var participants = [String]()
    var firstUser: UserObject?
    var eventId: String?
    init(route_id: String, start_time: Date){
        self.start_time = start_time
        self.route_id = route_id
    }
    func setFirstUser(){
        FIRDatabase.database().reference().child("USERS/\(participants[0])").observeSingleEvent(of: .value, with: { (snapshot) in
        self.firstUser = UserObject(snapshot: snapshot)
        
        let request = NSMutableURLRequest(url: URL(string: (self.firstUser?.photoUrl!)!)!)
        request.httpMethod = "GET"
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error == nil {
                self.firstUser?.avatarImg = UIImage(data: data!, scale: UIScreen.main.scale)
            }
        }
        dataTask.resume()
        
        })
    }
    func setFirstUser(user: UserObject){
        self.firstUser = user
    }
}
