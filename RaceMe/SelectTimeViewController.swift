//
//  SelectTimeViewController.swift
//  RaceMe
//
//  Created by LVMBP on 3/25/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

protocol SelectTimeViewControllerDelegate {
    func changeTime(selectTimeVC: SelectTimeViewController, selectedTime: String)
}
class SelectTimeViewController: UIViewController {
    let timePickerData = ["All time","Today","Tomorrow","Later"]
    let timeData: [[String: String]] =
        [["name" : "All time", "code": "0"],
         ["name" : "Today", "code": "1"],
         ["name" : "Tomorrow", "code": "2"],
         ["name" : "Later", "code": "3"]]
    var lastTimePickedIP: IndexPath?
    var delegate: SelectTimeViewControllerDelegate!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "TextOnlyTableViewCell", bundle: nil), forCellReuseIdentifier: "TextOnlyCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
extension SelectTimeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return timePickerData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextOnlyCell") as! TextOnlyTableViewCell
        cell.cellValueLabel.text = timeData[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! TextOnlyTableViewCell
        
        if cell.accessoryType != .checkmark {
            cell.accessoryType = .checkmark
            if lastTimePickedIP == nil {
                lastTimePickedIP = indexPath
                delegate.changeTime(selectTimeVC: self, selectedTime: timeData[indexPath.row]["code"]!)
            } else if lastTimePickedIP != indexPath {
                tableView.cellForRow(at: lastTimePickedIP!)?.accessoryType = .none
                lastTimePickedIP = indexPath
                delegate.changeTime(selectTimeVC: self, selectedTime: timeData[indexPath.row]["code"]!)
            } else {
                
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
