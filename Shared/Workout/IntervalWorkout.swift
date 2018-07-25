//
//  IntervalWorkout.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/7/14.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import Foundation
import HealthKit

class IntervalWorkout {
  
  // MARK: - Properties
  let workout: HKWorkout
  let configuration: WorkoutConfiguration
  let intervals: [IntervalWorkoutInterval]
  
  init(withWorkout workout:HKWorkout, configuration:WorkoutConfiguration) {
    self.workout = workout
    self.configuration = configuration
    self.intervals = {
      var ints: [IntervalWorkoutInterval] = [IntervalWorkoutInterval]()
      
      let activeLength = configuration.activeTime
      let restLength = configuration.restTime
      
      var intervalStart = workout.startDate
      
      while intervalStart.compare(workout.endDate) == .orderedAscending {
        let restStart = Date(timeInterval: activeLength, since: intervalStart)
        let interval = IntervalWorkoutInterval(activeStartTime: intervalStart,
          restStartTime: restStart,
          duration: activeLength,
          endTime: Date(timeInterval: restLength, since: restStart)
        )
        ints.append(interval)
        intervalStart = Date(timeInterval: activeLength + restLength, since: intervalStart)
      }
      return ints
    } ()
  }
  
  // MARK: - Read-Only Properties
  
  var distanceType: HKQuantityType {
    if workout.workoutActivityType == .cycling {
      return cyclingDistanceType
    } else {
      return runningDistanceType
    }
  }
  
  var startDate: Date {
    return workout.startDate
  }
  
  var endDate: Date {
    return workout.endDate
  }
  
  var duration: TimeInterval {
    return workout.duration
  }
  
  var calories: Double {
    guard let energy = workout.totalEnergyBurned else {return 0.0}
    
    return energy.doubleValue(for: energyUnit)
  }
  
  var distance: Double {
    guard let dist = workout.totalDistance else {return 0.0}
    
    return dist.doubleValue(for: distanceUnit)
  }
}

class IntervalWorkoutInterval {
  let activeStartTime: Date
  let duration: TimeInterval
  let restStartTime: Date
  let endTime: Date
  
  init (activeStartTime: Date, restStartTime: Date, duration: TimeInterval, endTime: Date) {
    self.activeStartTime = activeStartTime
    self.restStartTime = restStartTime
    self.duration = duration
    self.endTime = endTime
  }
  
  var distanceStats: HKStatistics?
  var hrStats: HKStatistics?
  var caloriesStats: HKStatistics?
  
  var distance: Double? {
    guard let distanceStats = distanceStats else { return nil }
    return distanceStats.sumQuantity()?.doubleValue(for: distanceUnit)
  }
  
  var averageHeartRate: Double? {
    guard let hrStats = hrStats else { return nil }
    return hrStats.averageQuantity()?.doubleValue(for: hrUnit)
  }
  
  var calories: Double? {
    guard let caloriesStats = caloriesStats else { return nil }
    return caloriesStats.sumQuantity()?.doubleValue(for: energyUnit)
  }
}

