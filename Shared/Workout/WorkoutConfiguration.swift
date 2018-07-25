//
//  WorkoutConfiguration.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/7/13.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import Foundation

class WorkoutConfiguration {
  
  let exerciseType: ExerciseType
  var activeTime: TimeInterval
  var restTime: TimeInterval
  
  private let exerciseTypeKey = "com.xavier.config.exerciseType"
  private let activeTimeKey = "com.xavier.config.activeTime"
  private let restTimeKey = "com.xavier.config.restTime"
  
  init(exerciseType: ExerciseType = .other, activeTime: TimeInterval = 120, restTime: TimeInterval = 30) {
    self.exerciseType = exerciseType
    self.activeTime = activeTime
    self.restTime = restTime
  }
  
  init(withDictionary rawDictionary:[String : Any]) {
    if let type = rawDictionary[exerciseTypeKey] as? Int {
      self.exerciseType = ExerciseType(rawValue: type)!
    } else {
      self.exerciseType = ExerciseType.other
    }
    
    if let active = rawDictionary[activeTimeKey] as? TimeInterval {
      self.activeTime = active
    } else {
      self.activeTime = 120
    }
    
    if let rest = rawDictionary[restTimeKey] as? TimeInterval {
      self.restTime = rest
    } else {
      self.restTime = 30
    }
  }
  
  func intervalDuration() -> TimeInterval {
    return activeTime + restTime
  }
  
  func dictionaryRepresentation() -> [String : Any] {
    return [
      exerciseTypeKey : exerciseType.rawValue,
      activeTimeKey : activeTime,
      restTimeKey : restTime,
    ]
  }
}
