//
//  HealthDataService_Watch.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/7/15.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import Foundation
import HealthKit

// This is an extension of the HealthDataService class and this extension adds support for saving an HKWorkoutSession
extension HealthDataService {
  
  
  /// This function saves a workout from a WorkoutSessionService and its HKWorkoutSession
  func saveWorkout(_ workoutService: WorkoutSessionService, completion: @escaping (Bool, Error?) -> Void) {
   
    guard let start = workoutService.startDate, let end = workoutService.endDate else {return}
    
    // Create some metadata to save the interval timer details.
    var metadata = workoutService.configuration.dictionaryRepresentation()
    metadata[HKMetadataKeyIndoorWorkout] = workoutService.configuration.exerciseType.location == .indoor
    
    let workout = HKWorkout(activityType: workoutService.configuration.exerciseType.activityType,
                            start: start,
                            end: end,
                            duration: end.timeIntervalSince(start),
                            totalEnergyBurned: workoutService.energyBurned,
                            totalDistance: workoutService.distance,
                            device: HKDevice.local(),
                            metadata: metadata)
    
    // Collect the sampled data
    var samples: [HKQuantitySample] = [HKQuantitySample]()
    samples += workoutService.hrData
    samples += workoutService.distanceData
    samples += workoutService.energyData
    
    // Save the workout
    healthKitStore.save(workout) { (success, error) in
      if !success || samples.count == 0 {
        completion(success, error)
        return
      }
      
      // If there are samples to save, add them to the workout
      self.healthKitStore.add(samples, to: workout) { (success, error)  in
        completion(success, error)
      }
    }
  }
  
  
  
  
}
