//
//  AppDelegate.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/13/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        FIRAuth.auth()!.addStateDidChangeListener { (auth, user) in
            if user != nil {
                
                // Set up the Profile View Controller
                let profileViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
                profileViewController.tabBarItem.title = "Me"
                profileViewController.tabBarItem.image = UIImage(named: "profile")
                
                // Set up the Find Friends View Controller
                let findFriendsViewController = FindFriendsViewController(nibName: "FindFriendsViewController", bundle: nil)
                findFriendsViewController.tabBarItem.title = "Friends"
                findFriendsViewController.tabBarItem.image = UIImage(named: "people-add")

                // Set up the Tracking View Controller
                let trackingViewController = RecordViewController(nibName: "RecordViewController", bundle: nil)
                trackingViewController.tabBarItem.title = "Tracking"
                trackingViewController.tabBarItem.image = UIImage(named: "play")
                
                // Set up the Explore View Controller
                let groupViewController = GroupViewController(nibName: "GroupViewController", bundle: nil)
                groupViewController.tabBarItem.title = "Group"
                groupViewController.tabBarItem.image = UIImage(named: "group")
                
                // Set up the Explore View Controller
                let exploreViewController = ExploreViewController(nibName: "ExploreViewController", bundle: nil)
                exploreViewController.tabBarItem.title = "Explore"
                exploreViewController.tabBarItem.image = UIImage(named: "radar")

                // Set up the Tab Bar Controller to have two tabs
                let tabBarController = UITabBarController()
                tabBarController.viewControllers = [profileViewController, findFriendsViewController, trackingViewController, groupViewController, exploreViewController]
                tabBarController.selectedIndex = 2
                
                // Make the Tab Bar Controller the root view controller
                self.window?.rootViewController = tabBarController
                self.window?.makeKeyAndVisible()
            } else {
                var initialViewController: UIViewController?
                initialViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
                let frame = UIScreen.main.bounds
                self.window = UIWindow(frame: frame)
                self.window!.rootViewController = initialViewController
                self.window!.makeKeyAndVisible()
            }
        }

        return SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return SDKApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

