//
//  User.swift
//  RaceMe
//
//  Created by Thanh Luu on 3/27/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct User {
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    var email: String?
    var displayName: String?
    var gender: String?
    var birthday: String?
    var weight: String?
    var height: String?
    var photoUrl: String?
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        ref = snapshot.ref
        email = (snapshot.value! as! NSDictionary)["email"] as? String
        displayName = (snapshot.value! as! NSDictionary)["displayName"] as? String
        gender = (snapshot.value! as! NSDictionary)["gender"] as? String
        birthday = (snapshot.value! as! NSDictionary)["birthday"] as? String
        weight = (snapshot.value! as! NSDictionary)["weight"] as? String
        height = (snapshot.value! as! NSDictionary)["height"] as? String
        photoUrl = (snapshot.value! as! NSDictionary)["photoUrl"] as? String
    }

    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
    func joinGroup(group_id: String) {
        ref?.child("groups/\(group_id)").setValue(NSDate().timeIntervalSince1970 * 1000)
        FIRDatabase.database().reference().child("\(group_id)/members/\(uid!)").setValue(NSDate().timeIntervalSince1970 * 1000)
    }
    
    func leaveGroup(group_id: String) {
        ref?.child("groups/\(group_id)").removeValue()
        FIRDatabase.database().reference().child("\(group_id)/members/\(uid!)").removeValue()
    }
}
