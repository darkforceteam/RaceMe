//
//  UserObject.swift
//  RaceMe
//
//  Created by LVMBP on 4/3/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class UserObject: NSObject {
    var uid: String!
    var key: String?
    var email: String?
    var displayName: String?
    var gender: String?
    var birthday: String?
    var weight: String?
    var height: String?
    var photoUrl: String?
    var avatarImg: UIImage?
    var bio: String?
    var isReady = false
    init(snapshot: FIRDataSnapshot){
        key = snapshot.ref.key
        uid = key
        email = (snapshot.value! as! NSDictionary)["email"] as? String
        displayName = (snapshot.value! as! NSDictionary)["displayName"] as? String
        gender = (snapshot.value! as! NSDictionary)["gender"] as? String
        birthday = (snapshot.value! as! NSDictionary)["birthday"] as? String
        weight = (snapshot.value! as! NSDictionary)["weight"] as? String
        height = (snapshot.value! as! NSDictionary)["height"] as? String
        photoUrl = (snapshot.value! as! NSDictionary)["photoUrl"] as? String
        bio = (snapshot.value! as! NSDictionary)[Constants.USERS.bio] as? String
    }
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, name: String) {
        self.uid = uid
        self.displayName = name
    }
}
