//
//  ChallengeViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/7/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ChallengeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chalTypeSegment: UISegmentedControl!
    
    @IBOutlet weak var createBtn: UIButton!
    var challenges = [Challenge]()
    var ref: FIRDatabaseReference!
    var userRef: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var chalStorageRef: FIRStorageReference!
    var task: URLSessionDataTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        userRef = ref.child(Constants.USERS.table_name)
        let storage = FIRStorage.storage()
        storageRef = storage.reference()
        chalStorageRef = storageRef.child(Constants.STORAGE.CHALLENGE)
        
        task = URLSessionDataTask()
        
        self.cache = NSCache()
        
        createBtn.backgroundColor = UIColor(136, 192, 87)
        createBtn.layer.cornerRadius = 5
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChallengeViewCell", bundle: nil), forCellReuseIdentifier: "ChallengeViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        //        tableView.estimatedRowHeight = 400
        //        tableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }
    
    @IBAction func createChallenge(_ sender: UIButton) {
        let addChalVC = AddChallengeVC(nibName: "AddChallengeVC", bundle: nil)
        navigationController?.pushViewController(addChalVC, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        loadChallenges()
    }
    deinit {
        if ref != nil {
            ref.removeAllObservers()
            userRef.removeAllObservers()
        }
    }
    func loadChallenges() {
        self.ref.child(Constants.Challenge.table_name).observe(.value, with: { (snapshot) in
            if snapshot.hasChildren(){
                self.challenges.removeAll()
                for challengeData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    let challenge = Challenge(snapshot: challengeData)
                    self.challenges.append(challenge)
                    //                    if challenge.created_by != nil && challenge.created_by != ""{
                    //                        self.userRef.child("\(challenge.created_by!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    //                            if let oneChal = snapshot.value as? NSDictionary{
                    //                                challenge.creator_name = oneChal.value(forKey: Constants.USERS.display_name) as? String
                    //                            }
                    //                        })
                    //                    }
                    
//                    if challenge.chal_photo != nil && challenge.chal_photo != "" {
//                        if (self.cache.object(forKey: challenge.chal_photo as AnyObject) != nil){
//                            challenge.chalImg = self.cache.object(forKey: challenge.chal_photo as AnyObject) as? UIImage
//                            self.challenges.append(challenge)
//                            self.tableView.reloadData()
//                        } else {
//                            let request = NSMutableURLRequest(url: URL(string: (challenge.chal_photo!))!)
//                            request.httpMethod = "GET"
//                            
//                            self.session = URLSession(configuration: URLSessionConfiguration.default)
//                            self.task = self.session.dataTask(with: request as URLRequest) { (data, response, error) in
//                                if error == nil {
//                                    DispatchQueue.main.async {
//                                        let img = UIImage(data: data!, scale: UIScreen.main.scale)
//                                        let size = CGSize(width: 68, height: 68)
//                                        UIGraphicsBeginImageContext(size)
//                                        img!.draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
//                                        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//                                        UIGraphicsEndImageContext()
//                                        self.cache.setObject(resizedImage!, forKey: challenge.chal_photo as AnyObject)
//                                        challenge.chalImg = resizedImage
//                                        
//                                        self.challenges.append(challenge)
//                                        self.tableView.reloadData()
//                                    }
//                                }
//                            }
//                            self.task.resume()
//                        }
//                    } else {
//                        self.challenges.append(challenge)
//                    }
                }
                self.tableView.reloadData()
            }
        }, withCancel: { (error) in
            print(error)
        })
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

extension ChallengeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return challenges.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 138
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let updateCell = tableView.dequeueReusableCell(withIdentifier: "ChallengeViewCell", for: indexPath) as! ChallengeViewCell
        if challenges.count > 0 {
            let chal = challenges[indexPath.row]
            print(chal.chal_photo!)
            if chal.chal_photo != nil {
                updateCell.chalImage.setImageWith(URL(string: chal.chal_photo!)!)
            }
            if chal.chal_name != nil {
                updateCell.chalNameLabel.text = chal.chal_name!
            }
            
            if chal.chal_desc != nil {
                updateCell.chalDescLabel.text = chal.chal_desc
            }
            if chal.creator_name != nil {
                updateCell.creatorLabel.text = chal.creator_name!
            }
            if chal.start_date != nil {
                updateCell.fromDateLabel.text = "\(chal.start_date!.toDateOnly())"
            }
            if chal.end_date != nil {
                updateCell.toDateLabel.text = "\(chal.end_date!.toDateOnly())"
            }
        }
        return updateCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if challenges.count > 0 {
        let viewChalVC = ChallengeDetailVC(nibName: "ChallengeDetailVC", bundle: nil)
        viewChalVC.challenge = challenges[indexPath.row]
        navigationController?.pushViewController(viewChalVC, animated: true)
        }
    }
}
