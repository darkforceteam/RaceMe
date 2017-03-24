//
//  Extensions.swift
//  RaceMe
//
//  Created by Duc Pham Viet on 3/23/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

extension Int {
    var toHours: String {
        let value = self / 3600
        let string = (value <= 9) ? "0\(value)" : "\(value)"
        return string
    }
    var toMinutes: String {
        let value = (self % 3600) / 60
        let string = (value <= 9) ? "0\(value)" : "\(value)"
        return string
    }
    var toSeconds: String {
        let value = (self % 3600) % 60
        let string = (value <= 9) ? "0\(value)" : "\(value)"
        return string
    }
}

extension Double {
    var stringWithPaceFormat: String {
        if self.isInfinite {
            return "0:00"
        }
        let toMintes = Int(self / 60)
        let toSeconds = Int(self.truncatingRemainder(dividingBy: 60))
        let secondsString = (toSeconds <= 9) ? "0\(toSeconds)" : "\(toSeconds)"
        return "\(toMintes):\(secondsString)"
    }
}

extension NSDate {
    var toString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 7)
        return dateFormatter.string(from: self as Date)
    }
}

extension UIColor {
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) {
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

let customGray = UIColor(170, 184, 194)
let customGreen = UIColor(74, 167, 127)
let customOrange = UIColor(253, 149, 111)
