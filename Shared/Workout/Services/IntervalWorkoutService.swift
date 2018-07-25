//
//  IntervalWorkoutService.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/7/15.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import Foundation
import HealthKit

class IntervalWorkoutService {
  
  private let healthService = HealthDataService()
  
  /// This method gets a list of workouts from HealthKit and reformats them as IntervalWorkouts.
  /// It uses the metadata written by the watch to determine how long the intervals were when it was created
  func readIntervalWorkouts(_ completion: @escaping (_ success: Bool, _ workouts:[IntervalWorkout], _ error: Error?) -> Void) {
    
    healthService.readWorkouts { (success, workouts, error) -> Void in
      
      var intervalWorkouts:[IntervalWorkout] = [IntervalWorkout]()
      
      // Loop through results
      for workout in workouts {
        // There's no Metadata, so it must not be an IntervalWorkout that we created - Just make it with one interval
        guard let metadata = workout.metadata, metadata.count > 0 else {
          let basicConfiguration = WorkoutConfiguration(exerciseType: ExerciseType.other, activeTime: workout.duration, restTime: 0)
          let basicIntervalWorkout = IntervalWorkout(withWorkout: workout, configuration: basicConfiguration)
          intervalWorkouts.append(basicIntervalWorkout)
          continue
        }
        
        // Determine The Configuration
        let configuration = WorkoutConfiguration(withDictionary: metadata)
        
        // Create a workout
        let intervalWorkout = IntervalWorkout(withWorkout: workout, configuration: configuration)
        intervalWorkouts.append(intervalWorkout)
      }
      
      // Return the results to the caller
      completion(success, intervalWorkouts, error)
    }
    
  }
  
  func readWorkoutDetail(_ workout:IntervalWorkout, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
    
    // Start a dispatch group to get all the data
    let loadAllDataDispatchGroup = DispatchGroup()
    
    for interval in workout.intervals {

      // Get Distance Data
      loadAllDataDispatchGroup.enter()
      statisticsForInterval(interval, workout: workout, type: workout.distanceType, options: .cumulativeSum, completion: { (stats, error) -> Void in
        interval.distanceStats = stats
        loadAllDataDispatchGroup.leave()
      })
      
      // Get HR Data
      loadAllDataDispatchGroup.enter()
      statisticsForInterval(interval, workout: workout, type: hrType, options: .discreteAverage, completion: { (stats, error) -> Void in
        interval.hrStats = stats
        loadAllDataDispatchGroup.leave()
      })
      
      // Energy Data
      loadAllDataDispatchGroup.enter()
      statisticsForInterval(interval, workout: workout, type: energyType, options: .cumulativeSum, completion: { (stats, error) -> Void in
        interval.caloriesStats = stats
        loadAllDataDispatchGroup.leave()
      })
    }
    
    // Now that all the work is done, call the completion handler loadAllDataDispatchGroup.notify(
    loadAllDataDispatchGroup.notify(queue: DispatchQueue.global(qos: .default)) { () -> Void in
      completion(true, nil)
    }
  }
  
  private func statisticsForInterval(_ interval: IntervalWorkoutInterval, workout: IntervalWorkout, type: HKQuantityType, options:HKStatisticsOptions,
    completion: @escaping (_ stats: HKStatistics?, _ error: Error?) -> Void) {
      
      healthService.statisticsForWorkout(workout.workout,
        intervalStart: interval.activeStartTime,
        intervalEnd: interval.restStartTime,
        type: type,
        options: options) { (statistics, error) -> Void in
        
          completion(statistics, error)
      }
  }
}
