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
import FacebookLogin

class LoginViewController: UIViewController {
    
    var initialViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Add a custom login button to your app
        let fbLoginButton = UIButton(type: .custom)
        fbLoginButton.backgroundColor = UIColor.darkGray
        fbLoginButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        fbLoginButton.center = view.center
        fbLoginButton.setTitle("Login With Facebook", for: .normal)
        
        // Handle clicks on the button
        fbLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)

        // Add the button to the view
        view.addSubview(fbLoginButton)
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
                    self.initialViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
                    self.present(self.initialViewController!, animated: true, completion: nil)
                })
                
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
