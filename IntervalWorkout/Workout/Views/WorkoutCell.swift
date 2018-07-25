//
//  WorkoutCell.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/22.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutCell: UITableViewCell {
  
  var workout: IntervalWorkout? {
    willSet(newWorkout) {
      self.activityTypeLabel?.text = newWorkout?.configuration.exerciseType.title.uppercased()
      
      if let elapsedTime = elapsedTimeFormatter.string(from: (newWorkout?.duration)!) {
        self.durationLabel.text = elapsedTime
      }
      
      if let startDate = newWorkout?.startDate {
        self.descriptionLabel?.text = "\(dateOnlyFormatter.string(from: startDate)) at \(timeOnlyFormatter.string(from: startDate))"
      }
    }
  }
  
  @IBOutlet weak var activityTypeLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.activityTypeLabel?.text = nil
    self.descriptionLabel?.text = nil
    self.durationLabel?.text = nil
  }
}
