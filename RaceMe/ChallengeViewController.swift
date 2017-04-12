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
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        userRef = ref.child(Constants.USERS.table_name)
        let storage = FIRStorage.storage()
        storageRef = storage.reference()
        chalStorageRef = storageRef.child(Constants.STORAGE.CHALLENGE)
        createBtn.backgroundColor = UIColor(136, 192, 87)
        createBtn.layer.cornerRadius = 5
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChallengeViewCell", bundle: nil), forCellReuseIdentifier: "ChallengeViewCell")
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
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
        self.challenges.removeAll()
        self.ref.child(Constants.Challenge.table_name).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren(){
                for challengeData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    let challenge = Challenge(snapshot: challengeData)
                    if challenge.created_by != nil && challenge.created_by != ""{
                        self.userRef.child("\(challenge.created_by!)").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let oneChal = snapshot.value as? NSDictionary{
                                challenge.creator_name = oneChal.value(forKey: Constants.USERS.display_name) as? String
                            }
                        })
                    }
                    if challenge.chal_photo != nil {
                        let request = NSMutableURLRequest(url: URL(string: (challenge.chal_photo!))!)
                        request.httpMethod = "GET"
                        
                        let session = URLSession(configuration: URLSessionConfiguration.default)
                        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                            if error == nil {
                                DispatchQueue.main.async {
                                    challenge.chalImg = UIImage(data: data!, scale: UIScreen.main.scale)
                                    self.challenges.append(challenge)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        dataTask.resume()
                    } else {
                        self.challenges.append(challenge)
                    }
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
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeViewCell", for: indexPath) as! ChallengeViewCell
        let chal = challenges[indexPath.row]
        if chal.chalImg != nil {
            cell.chalImage.image = chal.chalImg
        }
        if chal.creator_name != nil {
            cell.creatorLabel.text = chal.creator_name!
        }
        if chal.start_date != nil {
            cell.fromDateLabel.text = "\(chal.start_date!)"
        }
        if chal.end_date != nil {
            cell.toDateLabel.text = "\(chal.end_date!)"
        }
        if chal.total_wo_no != nil {
            cell.totWOLabel.text = "\(chal.total_wo_no!)"
        }
        if chal.total_distant != nil {
            cell.totDistLabel.text = "\(chal.total_distant!)"
        }
        if chal.week_wo_no != nil {
            cell.weeklyWOLabel.text = "\(chal.week_wo_no!)"
        }
        if chal.week_distant != nil {
            cell.weeklyDistLabel.text = "\(chal.week_distant!)"
        }
        if chal.min_wo_dist != nil {
            cell.miWODistLabel.text = "\(chal.min_wo_dist!)"
        }
        if chal.total_long_wo_no != nil {
            cell.longRunNoLabel.text = "\(chal.total_long_wo_no!)"
        }
        if chal.total_long_wo_dist != nil {
            cell.longRunNoLabel.text = "\(chal.total_long_wo_dist!)"
        }   
        return cell
    }

}
