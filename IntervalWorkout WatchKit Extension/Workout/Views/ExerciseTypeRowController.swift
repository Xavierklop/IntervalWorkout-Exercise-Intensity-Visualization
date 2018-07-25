//
//  ExerciseTypeRowController.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/15.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import WatchKit

class ExerciseTypeRowController: NSObject {

  @IBOutlet private weak var titleLabel: WKInterfaceLabel!
  @IBOutlet private weak var detailLabel: WKInterfaceLabel!

  var exerciseType: ExerciseType? {
    willSet(type) {
      titleLabel.setText(type!.title)
      detailLabel.setText(type!.locationName)
    }
  }
}
