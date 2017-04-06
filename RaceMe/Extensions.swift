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

extension String {
    var toDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let date = formatter.date(from: self)
        formatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
        if let date = date {
            return formatter.string(from: date)
        }
        return ""
    }
}

extension UIColor {
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) {
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

let labelGray1 = UIColor(166, 175, 182)
let labelGray2 = UIColor(84, 106, 120)
let imageGray = UIColor(92, 112, 126)
let goRunning = UIColor(136, 192, 87)
let customGray = UIColor(204, 204, 204)
let customGreen = UIColor(74, 167, 127)
let customOrange = UIColor(238, 176, 84)
let stopColor = UIColor(239, 93, 53)
let pauseColor = UIColor(46, 201, 214)
let resumeColor = UIColor(135, 229, 127)
let backgroundGray = UIColor(239, 239, 244)
let strokeColor = UIColor(237, 112, 98)

// Please using those colors below:
let primaryColor = UIColor(72, 160, 220) // Blue
let successColor = UIColor(136, 192, 87) // Green
let warningColor = UIColor(238, 175, 75) // Orange
let dangerColor = UIColor(237, 113, 97) // Red
let infoColor = UIColor(151, 119, 168) // Purple
let lightColor = UIColor(243, 243, 243) // Gray
let darkColor = UIColor(84, 106, 121) // Dark Blue
