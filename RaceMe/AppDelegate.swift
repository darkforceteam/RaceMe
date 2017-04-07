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
        
        // Enable offline data saving
        FIRDatabase.database().persistenceEnabled = true
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        FIRAuth.auth()!.addStateDidChangeListener { (auth, user) in
            if user != nil {
                
                // Profile View Controller
                let profileViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
                let profileNavVC = UINavigationController()
                profileNavVC.addChildViewController(profileViewController)
                profileNavVC.navigationBar.barTintColor = primaryColor
                profileNavVC.navigationBar.isTranslucent = false
                profileNavVC.navigationBar.topItem?.title = "Me"
                if let font = UIFont(name: "OpenSans-Semibold", size: 17) {
                    profileNavVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font]
                } else {
                    profileNavVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
                }
                profileNavVC.navigationBar.barStyle = UIBarStyle.black
                profileNavVC.navigationBar.tintColor = .white
                profileNavVC.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                profileNavVC.navigationBar.shadowImage = UIImage()
                profileViewController.tabBarItem.title = "Me"
                profileViewController.tabBarItem.image = UIImage(named: "profile")

                // Tracking View Controller                
                let recordNavVC = UINavigationController(rootViewController: RecordViewController())
                recordNavVC.tabBarItem.title = "Tracking"
                recordNavVC.tabBarItem.image = UIImage(named: "map-pin")
                recordNavVC.topViewController?.navigationItem.title = "Tracking"
                if let font = UIFont(name: "OpenSans-Semibold", size: 17) {
                    recordNavVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font]
                }
                
                recordNavVC.navigationBar.barTintColor = primaryColor
                recordNavVC.navigationBar.tintColor = .white
                recordNavVC.navigationBar.barStyle = UIBarStyle.black

                // Set up the Explore View Controller
                let exploreViewController = ExploreViewController(nibName: "ExploreViewController", bundle: nil)
                let exploreNavVC = UINavigationController()
                exploreNavVC.addChildViewController(exploreViewController)
                exploreNavVC.navigationBar.barTintColor = primaryColor
                exploreNavVC.navigationBar.isTranslucent = false
                exploreNavVC.navigationBar.topItem?.title = "Explore"
                if let font = UIFont(name: "OpenSans-Semibold", size: 17) {
                    exploreNavVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font]
                } else {
                    exploreNavVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
                }
                exploreNavVC.navigationBar.barStyle = UIBarStyle.black
                exploreNavVC.navigationBar.tintColor = .white
                exploreNavVC.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                exploreNavVC.navigationBar.shadowImage = UIImage()
                exploreViewController.tabBarItem.title = "Explore"
                exploreViewController.tabBarItem.image = UIImage(named: "radar")
                
                // Tab Bar Controller
                let tabBarController = UITabBarController()
                tabBarController.tabBar.tintColor = primaryColor
                tabBarController.tabBar.barTintColor = lightColor
                tabBarController.viewControllers = [exploreNavVC, recordNavVC, profileNavVC]
                tabBarController.selectedIndex = 0
                
                // Make the Tab Bar Controller the root view controller
                self.window?.rootViewController = tabBarController
                self.window?.makeKeyAndVisible()
            } else {
                var initialViewController: UIViewController?
                initialViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
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
