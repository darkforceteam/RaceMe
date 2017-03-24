//
//  User.swift
//  RaceMe
//
//  Created by Duc Pham Viet on 3/23/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
