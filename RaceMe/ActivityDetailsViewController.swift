//
//  ActivityDetailsViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/5/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class ActivityDetailsViewController: UIViewController {
    
    var workout: Workout!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(workout.distanceKm)
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
