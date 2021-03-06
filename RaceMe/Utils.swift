//
//  Utils.swift
//  RaceMe
//
//  Created by LVMBP on 4/9/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit

class Utils: NSObject {
    static func binarySearch<T:Comparable>(inputArr:Array<T>, searchItem: T)->Int{
        var lowerIndex = 0;
        var upperIndex = inputArr.count - 1
        
        while (true) {
            let currentIndex = (lowerIndex + upperIndex)/2
            if(inputArr[currentIndex] == searchItem) {
                return currentIndex
            } else if (lowerIndex > upperIndex) {
                return -1
            } else {
                if (inputArr[currentIndex] > searchItem) {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
    static func distanceInKm(distanceInMeter: Double) -> Double{
        return distanceInMeter/1000
    }
    static func distanceInMiles(distanceInMeter: Double) -> Double{
        return distanceInMeter/1609.34
    }
}
