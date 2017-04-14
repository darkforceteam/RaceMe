//
//  ChallengeDetailVC.swift
//  RaceMe
//
//  Created by LVMBP on 4/14/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ChallengeDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    var challenge: Challenge?
    var ref: FIRDatabaseReference!
    var chalRef: FIRDatabaseReference!
    var userId: String?
    var currentStatus: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RightDetailCell", bundle: nil), forCellReuseIdentifier: "RightDetailCell")
        userId = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        
        joinBtn.backgroundColor = successColor
        joinBtn.layer.cornerRadius = 3
        leaveBtn.backgroundColor = warningColor
        leaveBtn.layer.cornerRadius = 3
        
        if challenge != nil{
            chalRef = ref.child(Constants.Challenge.table_name).child(challenge!.id!)
            userJoinStatus()
        }
        // Do any additional setup after loading the view.
    }
    deinit {
        if ref != nil {
            ref.removeAllObservers()
            chalRef.removeAllObservers()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func userJoinStatus() {
        chalRef.child(Constants.Challenge.participants.participants).queryOrderedByKey().queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren() {
                for participant in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    if let oneUser = participant.value as? NSDictionary{
                        if let status = oneUser.value(forKey: Constants.Challenge.participants.status) as? Int{
                            self.currentStatus = status
                            if self.currentStatus == 1{
                                self.joinBtn.isHidden = true
                                self.leaveBtn.isHidden = false
                            } else {
                                self.leaveBtn.isHidden = true
                                self.joinBtn.isHidden = false
                            }
                        }
                    }
                }
            } else {
                self.leaveBtn.isHidden = true
                self.joinBtn.isHidden = false
            }
        })
    }

    @IBAction func leaveChal(_ sender: UIButton) {
        chalRef.child(Constants.Challenge.participants.participants).child(userId!).removeValue()
        joinBtn.isHidden = false
        leaveBtn.isHidden = true
    }
    @IBAction func joinChal(_ sender: UIButton) {
        chalRef.child(Constants.Challenge.participants.participants).child(userId!).child(Constants.Challenge.participants.status).setValue(1)
        joinBtn.isHidden = true
        leaveBtn.isHidden = false
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

extension ChallengeDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "General Info"
        case 1:
            return "Challenge Target"
        case 2:
            return "Weekly Target"
        default:
            return "Workout Target"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            return 2
        default:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailCell
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Name"
                cell.detailLabel.text = challenge!.chal_name!
            case 1:
                cell.titleLabel.text = "Group"
                cell.detailLabel.text = challenge!.for_group!
            case 2:
                cell.titleLabel.text = "Start"
                cell.detailLabel.text = challenge!.start_date!.toDateOnly()
            case 3:
                cell.titleLabel.text = "End"
                cell.detailLabel.text = challenge!.end_date!.toDateOnly()
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Total Workout"
                cell.detailLabel.text = "\(challenge!.total_wo_no!)"
            case 1:
                cell.titleLabel.text = "Total Distance"
                cell.detailLabel.text = "\(challenge!.total_distant!)"
            case 2:
                cell.titleLabel.text = "Total Long Run"
                cell.detailLabel.text = "\(challenge!.total_long_wo_no!)"
            case 3:
                cell.titleLabel.text = "Total Long Run Distance"
                cell.detailLabel.text = "\(challenge!.total_long_wo_dist!)"
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Total Workout"
                cell.detailLabel.text = "\(challenge!.week_wo_no!)"
            case 1:
                cell.titleLabel.text = "Total Distance"
                cell.detailLabel.text = "\(challenge!.week_distant!)"
            case 2:
                cell.titleLabel.text = "Total Long Run"
                cell.detailLabel.text = "\(challenge!.week_long_wo_no!)"
            case 3:
                cell.titleLabel.text = "Total Long Run Distance"
                cell.detailLabel.text = "\(challenge!.week_long_wo_dist!)"
            default:
                break
            }
        case 3:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Minimum Distance"
                cell.detailLabel.text = "\(challenge!.min_wo_dist!)"
            case 1:
                cell.titleLabel.text = "Slowest Pace"
                cell.detailLabel.text = "\(challenge!.min_wo_pace!)"
            default:
                break
            }
        default:
            break
        }
        return cell
    }
}
