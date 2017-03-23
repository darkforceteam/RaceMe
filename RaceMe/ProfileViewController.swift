//
//  ProfileViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 3/19/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import AFNetworking

class ProfileViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userStatisticsScrollView: UIScrollView!
    @IBOutlet weak var userStatisticsPageControl: UIPageControl!

    let userStats1 = ["title":"Kilometers", "current_period":"8.3", "last_period":"0"]
    let userStats2 = ["title":"Average Pace (Min/Km)", "current_period":"1:15:08", "last_period":"2:33:54"]
    let userStats3 = ["title":"Activities", "current_period":"2", "last_period":"1"]
    let userStats4 = ["title":"Time Spent", "current_period":"31:52", "last_period":"04:50"]
    
    var userStatisticsArray = [Dictionary<String,String>]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        scrollView.addSubview(view)
        view = scrollView
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollView.backgroundColor = .white

        userStatisticsArray = [userStats1,userStats2,userStats3,userStats4]
        userStatisticsScrollView.isPagingEnabled = true
        userStatisticsScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(userStatisticsArray.count), height: 120)
        userStatisticsScrollView.showsHorizontalScrollIndicator = false
        userStatisticsScrollView.delegate = self
        loadUserStatistics()

        // Do any additional setup after loading the view.
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "email,name,picture"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(let value):
                let profile = value.dictionaryValue!
                self.nameLabel.text = profile["name"] as! String?

                if let picture = profile["picture"] as? NSDictionary {
                    let avatarURL = URL(string: picture.value(forKeyPath: "data.url") as! String)
                    self.avatarImage.setImageWith(avatarURL!)
                    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.width / 2
                    self.avatarImage.layer.borderColor = UIColor.white.cgColor
                    self.avatarImage.layer.borderWidth = 3
                    self.avatarImage.clipsToBounds = true
                }
                
            case .failed(let error):
                print(error)
            }
        }
    }
    
    func loadUserStatistics() {
        for (index, userStatistics) in userStatisticsArray.enumerated() {
            if let userStatisticsView = Bundle.main.loadNibNamed("UserStatistics", owner: self, options: nil)?.first as? UserStatisticsView {
                userStatisticsView.titleLabel.text = userStatistics["title"]
                userStatisticsView.currentPeriodCount.text = userStatistics["current_period"]
                userStatisticsView.lastPeriodCount.text = userStatistics["last_period"]
                userStatisticsScrollView.addSubview(userStatisticsView)
                userStatisticsView.frame.size.width = self.view.bounds.size.width
                userStatisticsView.frame.origin.x = CGFloat(index) * UIScreen.main.bounds.width
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        userStatisticsPageControl.currentPage = Int(page)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
