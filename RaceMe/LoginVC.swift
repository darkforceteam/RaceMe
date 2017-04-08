//
//  LoginVC.swift
//  RaceMe
//
//  Created by Duc Pham Viet on 4/6/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import Neon

class LoginVC: UIViewController {
    
    fileprivate let cellId = "cell"
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.backgroundColor = primaryColor
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    fileprivate let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.numberOfPages = 2
        pc.currentPageIndicatorTintColor = primaryColor
        pc.backgroundColor = .purple
        return pc
    }()
    
    fileprivate lazy var fbLoginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(55, 90, 154)
        button.setTitle("Login with Facebook", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(onFbLogin), for: .touchUpInside)
        return button
    }()
    
    fileprivate let slides = [Slide(title: "Explore", description: "Explore people, routes, challenges around you", image: #imageLiteral(resourceName: "walkthrough-image-1")), Slide(title: "Run Tracking", description: "Tracking & share your personal best with friends", image: #imageLiteral(resourceName: "walkthrough-image-2"))]
}

extension LoginVC {
    
    override func viewDidLoad() {
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: cellId)
        view.addSubview(pageControl)
        view.addSubview(fbLoginButton)
    }
    
    override func viewWillLayoutSubviews() {
        collectionView.anchorToEdge(.top, padding: 0, width: view.frame.width, height: view.frame.height - 90)
        pageControl.align(.underCentered, relativeTo: collectionView, padding: 0, width: 0, height: 30)
        fbLoginButton.anchorToEdge(.bottom, padding: 20, width: view.frame.width - 40, height: 40)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension LoginVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CustomCell
        cell.slide = slides[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 90)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        pageControl.currentPage = Int(targetContentOffset.pointee.x / view.frame.width)
    }
}

extension LoginVC {
    
    @objc func onFbLogin() {
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
                })
                
            }
        }
    }
}
