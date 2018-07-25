//
//  IntervalCell.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/21.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import UIKit

class IntervalCell: UITableViewCell {
  
  // ****** Models
  var interval: IntervalWorkoutInterval? {
    
    willSet(newInterval) {
      guard let newInterval = newInterval else {
        durationLabel?.text = ""
        distanceLabel?.text = ""
        heartRateLabel?.text = ""
        caloriesLabel?.text = ""
        return
      }
      
      // Duration
      if let elapsedTime = elapsedTimeFormatter.string(from: (newInterval.duration)) {
        durationLabel?.text = elapsedTime
      } else {
        durationLabel?.text = ""
      }
      
      // Distance
      if let distance = newInterval.distance {
        distanceLabel?.text = distanceFormatter.string(fromValue: distance, unit: distanceFormatterUnit)
      } else {
        distanceLabel?.text = ""
      }
      
      // Heart Rate
      if let heartRate = newInterval.averageHeartRate {
        heartRateLabel?.text = numberFormatter.string(from: NSNumber(value: heartRate))! + " bpm"
      } else {
        heartRateLabel?.text = ""
      }
      
      // Calories
      if let calories = newInterval.calories {
        caloriesLabel?.text = calorieFormatter.string(fromValue: calories, unit: energyFormatterUnit)
      } else {
        caloriesLabel?.text = ""
      }
    }
  }

  // ****** Interface Elements
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var heartRateLabel: UILabel!
  @IBOutlet weak var caloriesLabel: UILabel!
  
}
