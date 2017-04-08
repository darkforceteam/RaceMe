//
//  Group.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/7/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Group {
    var ref: FIRDatabaseReference?
    var key: String?
    var name: String!
    var creator: String!
    var description: String?
    var banner: String?
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        ref = snapshot.ref
        name = (snapshot.value! as! NSDictionary)["name"] as! String
        creator = (snapshot.value! as! NSDictionary)["creator"] as! String
        description = (snapshot.value! as! NSDictionary)["description"] as? String
        banner = (snapshot.value! as! NSDictionary)["banner"] as? String
    }
    
    init(name: String, description: String, banner: String) {
        self.name = name
        self.description = description
        self.banner = banner
        self.creator = FIRAuth.auth()!.currentUser?.uid
    }
    
    func toAnyObject() -> Any {
        return [
            Constants.Group.NAME: name,
            Constants.Group.DESCRIPTION: description,
            Constants.Group.CREATOR: creator,
            Constants.Group.BANNER: banner,
        ]
    }
    
    func joined(uid: String, completion: @escaping (_ success: Bool) -> ()) {
        var joined = Bool()
        ref?.child("members").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(uid) {
                joined = true
            } else {
                joined = false
            }
            completion(joined)
        })
    }
    
    func join(uid: String) {
        ref?.child("members/\(uid)").setValue(NSDate().timeIntervalSince1970 * 1000)
        FIRDatabase.database().reference().child("USERS/\(uid)/groups/\(key!)").setValue(NSDate().timeIntervalSince1970 * 1000)
    }
    
    func leave(uid: String) {
        ref?.child("members/\(uid)").removeValue()
        FIRDatabase.database().reference().child("USERS/\(uid)/groups/\(key!)").removeValue()
    }
}
