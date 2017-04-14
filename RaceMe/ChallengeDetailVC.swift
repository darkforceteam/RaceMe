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

    @IBOutlet weak var chalName: UILabel!
    @IBOutlet weak var chalDesc: UILabel!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var chalWO: UILabel!
    @IBOutlet weak var chalDist: UILabel!
    @IBOutlet weak var chalLongWO: UILabel!
    @IBOutlet weak var chalLongDist: UILabel!
    
    @IBOutlet weak var weekWO: UILabel!
    @IBOutlet weak var weekDist: UILabel!
    @IBOutlet weak var weekLongWO: UILabel!
    @IBOutlet weak var weekLongDist: UILabel!
    @IBOutlet weak var minWODist: UILabel!
    @IBOutlet weak var minPace: UILabel!
    
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    var challenge: Challenge?
    var ref: FIRDatabaseReference!
    var chalRef: FIRDatabaseReference!
    var userId: String?
    var currentStatus: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        
        joinBtn.backgroundColor = UIColor(136, 192, 87)
        joinBtn.layer.cornerRadius = 5
        leaveBtn.backgroundColor = UIColor.red
        leaveBtn.layer.cornerRadius = 5
        
        if challenge != nil{
            chalRef = ref.child(Constants.Challenge.table_name).child(challenge!.id!)
            fillChalDetail()
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
    func fillChalDetail(){
        if challenge?.chal_name != nil {
            chalName.text = challenge!.chal_name!
        }
        if challenge?.chal_desc != nil {
            chalDesc.text = challenge!.chal_desc!
        }
        if challenge?.for_group != nil {
            groupName.text = challenge!.for_group!
        }
        if challenge?.start_date != nil {
            startDate.text = challenge!.start_date!.toDateOnly()
        }
        if challenge?.end_date != nil {
            endDate.text = challenge!.end_date!.toDateOnly()
        }
        if challenge?.total_wo_no != nil {
            chalWO.text = "\(challenge!.total_wo_no!)"
        }
        if challenge?.total_distant != nil {
            chalDist.text = "\(challenge!.total_distant!)"
        }
        if challenge?.total_long_wo_no != nil {
            chalLongWO.text = "\(challenge!.total_long_wo_no!)"
        }
        if challenge?.total_long_wo_dist != nil {
            chalLongDist.text = "\(challenge!.total_long_wo_dist!)"
        }
        if challenge?.week_wo_no != nil {
            weekWO.text = "\(challenge!.week_wo_no!)"
        }
        if challenge?.week_distant != nil {
            weekDist.text = "\(challenge!.week_distant!)"
        }
        if challenge?.week_long_wo_no != nil {
            weekLongWO.text = "\(challenge!.week_long_wo_no!)"
        }
        if challenge?.week_long_wo_dist != nil {
            weekLongDist.text = "\(challenge!.week_long_wo_dist!)"
        }
        if challenge?.min_wo_dist != nil {
            minWODist.text = "\(challenge!.min_wo_dist!)"
        }
        if challenge?.min_wo_pace != nil {
            minPace.text = "\(challenge!.min_wo_pace!)"
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
