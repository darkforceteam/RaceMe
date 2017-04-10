//
//  ChallengeViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/7/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
class ChallengeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chalTypeSegment: UISegmentedControl!

    @IBOutlet weak var createBtn: UIButton!
    var challenges = [Challenge]()
    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChallengeViewCell", bundle: nil), forCellReuseIdentifier: "ChallengeViewCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        loadChallenges()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadChallenges() {
        self.ref.child(Constants.Challenge.table_name).observe(.value, with: { (snapshot) in
            let challenge = Challenge(snapshot: snapshot)
            self.challenges.append(challenge)
            self.tableView.reloadData()
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
        return cell
    }

}
