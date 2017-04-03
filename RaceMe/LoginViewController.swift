//
//  LoginViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController {
    
    var initialViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onFbLogin(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email, .userFriends ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error) :
                print(error)
            case .cancelled :
                print("User cancelled login.")
            case .success( _, _, let accessToken) :
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    }
                    
                    let request = GraphRequest(graphPath: "me", parameters: ["fields": "email,name,picture,gender"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
                    request.start { (response, result) in
                        switch result {
                        case .success(let value):
                            let profile = value.dictionaryValue!
                            var ref: FIRDatabaseReference!
                            ref = FIRDatabase.database().reference()
                            let userID = FIRAuth.auth()?.currentUser?.uid
                            ref.child("USERS").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                                let value = snapshot.value as? NSDictionary
                                if nil == value?["displayName"] {
                                    ref.child("USERS/\(userID!)/displayName").setValue(profile["name"])
                                }
                                if nil == value?["email"] {
                                    ref.child("USERS/\(userID!)/email").setValue(profile["email"])
                                }
                                if nil == value?["gender"] {
                                    ref.child("USERS/\(userID!)/gender").setValue(profile["gender"])
                                }
                                if nil == value?["photoUrl"] {
                                    if let picture = profile["picture"] as? NSDictionary {
                                        ref.child("USERS/\(userID!)/photoUrl").setValue(picture.value(forKeyPath: "data.url"))
                                    }
                                    
                                }
                            }) { (error) in
                                print(error.localizedDescription)
                            }
                        case .failed(let error):
                            print(error)
                        }
                    }
                    
                    self.initialViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
                    self.present(self.initialViewController!, animated: true, completion: nil)
                })
                
            }
        }
    }
}
