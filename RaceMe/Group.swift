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
    var avatar: String?
    var banner: String?
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        ref = snapshot.ref
        name = (snapshot.value! as! NSDictionary)["name"] as! String
        creator = (snapshot.value! as! NSDictionary)["creator"] as! String
        description = (snapshot.value! as! NSDictionary)["description"] as? String
        avatar = (snapshot.value! as! NSDictionary)["avatar"] as? String
        banner = (snapshot.value! as! NSDictionary)["banner"] as? String
    }
}
