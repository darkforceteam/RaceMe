//
//  LoginViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            print(accessToken)
        } else {
            // Add a custom login button to your app
            let myLoginButton = UIButton(type: .custom)
            myLoginButton.backgroundColor = UIColor.darkGray
            myLoginButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
            myLoginButton.center = view.center;
            myLoginButton.setTitle("My Login Button", for: .normal)
            
            // Handle clicks on the button
            myLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
            
            // Add the button to the view
            view.addSubview(myLoginButton)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Once the button is clicked, show the login dialog
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email, .userFriends ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in! \(grantedPermissions) \(declinedPermissions) \(accessToken) ")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
