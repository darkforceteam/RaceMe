//
//  RateCommentVC.swift
//  RaceMe
//
//  Created by LVMBP on 4/14/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class RateCommentVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var q1Label: UILabel!
    @IBOutlet weak var q2Label: UILabel!
    @IBOutlet weak var q3Label: UILabel!

    @IBOutlet weak var q4Label: UILabel!
    @IBOutlet weak var q5Label: UILabel!
    @IBOutlet weak var overallImg: UIImageView!
    @IBOutlet weak var a1Img: UIImageView!
    @IBOutlet weak var a2Img: UIImageView!
    @IBOutlet weak var a3Img: UIImageView!
    @IBOutlet weak var a4Img: UIImageView!
    @IBOutlet weak var a5Img: UIImageView!

    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!

    @IBAction func tap1(_ sender: UIButton) {
        picker1.isHidden = false
    }
    
    @IBAction func tap2(_ sender: UIButton) {
        picker2.isHidden = false
    }
    
    @IBAction func tap3(_ sender: UIButton) {
        picker3.isHidden = false
    }
    
    @IBAction func tap4(_ sender: UIButton) {
        picker4.isHidden = false
    }
    
    @IBAction func tap5(_ sender: UIButton) {
        picker5.isHidden = false
    }
    
    let noStarImg = UIImage(named: "star-0")
    let oneStarImg = UIImage(named: "star-1")
    let twoStarImg = UIImage(named: "star-2")
    let threeStarImg = UIImage(named: "star-3")
    let fourStarImg = UIImage(named: "star-4")
    let fiveStarImg = UIImage(named: "star-5")
    
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var picker3: UIPickerView!
    @IBOutlet weak var picker4: UIPickerView!
    @IBOutlet weak var picker5: UIPickerView!
    
    var optionCommon = ["VERY BAD","BAD","NORMAL","GOOD","EXCELLENT"]//FIXED FOR NOW. TODO: change to DB load
    
    @IBOutlet weak var runQuestionView: UIView!
    var ref: FIRDatabaseReference?
    var userId: String?
    var route: Route?
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        loadData()
        picker1.isHidden = true
        picker2.isHidden = true
        picker3.isHidden = true
        picker4.isHidden = true
        picker5.isHidden = true
        picker1.delegate = self
        picker2.delegate = self
        picker3.delegate = self
        picker4.delegate = self
        picker5.delegate = self
        // Do any additional setup after loading the view.
    }

    var oneScore = 0
    var twoScore = 0
    var threeScore = 0
    var fourScore = 0
    var fiveScore = 0
    var overallScore = 0.0
    var voted1 = false
    var voted2 = false
    var voted3 = false
    var voted4 = false
    var voted5 = false
    var oneVoteCount = 0
    var twoVoteCount = 0
    var threeVoteCount = 0
    var fourVoteCount = 0
    var fiveVoteCount = 0
    func loadData(){
        oneScore = 0
        twoScore = 0
        threeScore = 0
        fourScore = 0
        fiveScore = 0
        overallScore = 0
        oneVoteCount = 0
        twoVoteCount = 0
        threeVoteCount = 0
        fourVoteCount = 0
        fiveVoteCount = 0
        let path = "\(Constants.PublicRoute.TABLE_NAME)/\(route!.routeId!)/\(Constants.PublicRoute.RATING)"
        print(path)
        let rateRef = ref?.child(path)
        _ = rateRef?.observe(.value, with: { (snapshot) in
            print(snapshot)
            for rateData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                if let questData = rateData.value as? NSDictionary{
                    print("///////////")
                    print(questData)
                    if rateData.key == "1" {
                        if questData.count > 0 {
                            for (key, value) in questData{
                                self.oneVoteCount += 1
                                self.oneScore += value as! Int
                                if key as! String == self.userId {
                                    self.voted1 = true
                                }
                            }
                        }
                    }
                    if rateData.key == "2" {
                        if questData.count > 0 {
                            for (key, value) in questData{
                                self.twoVoteCount += 1
                                self.twoScore += value as! Int
                                if key as! String == self.userId {
                                    self.voted2 = true
                                }
                            }
                        }
                    }
                    if rateData.key == "3" {
                        if questData.count > 0 {
                            for (key, value) in questData{
                                self.threeVoteCount += 1
                                self.threeScore += value as! Int
                                if key as! String == self.userId {
                                    self.voted3 = true
                                }
                            }
                        }
                    }
                    if rateData.key == "4" {
                        if questData.count > 0 {
                            for (key, value) in questData{
                                self.fourVoteCount += 1
                                self.fourScore += value as! Int
                                if key as! String == self.userId {
                                    self.voted4 = true
                                }
                            }
                        }
                    }
                    if rateData.key == "5" {
                        if questData.count > 0 {
                            for (key, value) in questData{
                                self.fiveVoteCount += 1
                                self.fiveScore += value as! Int
                                if key as! String == self.userId {
                                    self.voted5 = true
                                }
                            }
                        }
                    }
                }
            }
            self.updateUI()
        })
    }
    func updateUI(){
        let oneAverage = oneScore/oneVoteCount
        let twoAverage = twoScore/twoVoteCount
        let threeAverage = threeScore/threeVoteCount
        let fourAverage = fourScore/fourVoteCount
        let fiveAverage = fiveScore/fiveVoteCount
        overallScore = (Double(oneAverage + twoAverage + threeAverage + fourAverage + fiveAverage) ).divided(by: 5.0)
        print("\(overallScore)")
    }
    deinit {
        if ref != nil {
            ref?.removeAllObservers()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker1 {
            return optionCommon.count
        } else if pickerView == picker2 {
            return optionCommon.count
        } else if pickerView == picker3 {
            return optionCommon.count
        } else if pickerView == picker4 {
            return optionCommon.count
        } else {
            return optionCommon.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        if pickerView == picker1 {
            return optionCommon[row]
        } else if pickerView == picker2 {
            return optionCommon[row]
        } else if pickerView == picker3 {
            return optionCommon[row]
        } else if pickerView == picker4 {
            return optionCommon[row]
        } else {
            return optionCommon[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == picker1 {
            picker1.isHidden = true
        } else if pickerView == picker2 {
            picker2.isHidden = true
        } else if pickerView == picker3 {
            picker3.isHidden = true
        } else if pickerView == picker4 {
            picker4.isHidden = true
        } else {
            picker5.isHidden = true
        }
    }
}
