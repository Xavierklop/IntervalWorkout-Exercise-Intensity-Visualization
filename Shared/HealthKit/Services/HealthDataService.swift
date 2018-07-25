//
//  HealthDataService.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/7/15.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import Foundation
import HealthKit

// ****** Units and Types
let energyUnit = HKUnit.kilocalorie()
let energyFormatterUnit: EnergyFormatter.Unit = {
  return HKUnit.energyFormatterUnit(from: energyUnit)
  } ()

let distanceUnit: HKUnit = {
  let locale = Locale.current
  let isMetric: Bool = locale.usesMetricSystem
  
  if isMetric {
    return HKUnit.meter()
  } else {
    
    return HKUnit.mile()
  }
  } ()

let distanceFormatterUnit: LengthFormatter.Unit = {
  return HKUnit.lengthFormatterUnit(from: distanceUnit)
  } ()

let vo2MaxUnit = HKUnit(from: "ml/kg/min")
let hrUnit = HKUnit(from: "count/min")

// MARK: 加入dateOfBirth，biologicalSex,restingHeartRate, VO2Max
let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
let biologicalSexType = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max)!
let energyType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
let hrType:HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
let cyclingDistanceType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!
let runningDistanceType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!

class HealthDataService {
  
  private enum HealthkitSetupError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
  }
  
  internal let healthKitStore:HKHealthStore = HKHealthStore()
  
  init() {}
  
  //authorized HealthKit and read write the data to HealthKit
  func authorizeHealthKitAccess (_ completion: ((_ success:Bool, _ error:Error?) -> Void)!) {
    
    let typesToShare = Set (
      [HKObjectType.workoutType(),
       energyType,
       cyclingDistanceType,
       runningDistanceType,
       hrType,
       restingHeartRate,
       vo2MaxType
      ])
    let typeToSave = Set ([
      energyType,
      cyclingDistanceType,
      runningDistanceType,
      hrType,
      dateOfBirthType,
      restingHeartRate,
      biologicalSexType,
      vo2MaxType
    ])
    
    healthKitStore.requestAuthorization(toShare: typesToShare, read: typeToSave) {
      (success, error) in
      completion(success, error)
    }
  }
  
  
  /// This function gets HKWorkouts from the Health Store that were created by this app
  func readWorkouts(_ completion: @escaping (_ success: Bool, _ workouts:[HKWorkout], _ error: Error?) -> Void) {
    
    // Predicate indicating "this app"
    //predicate is a filter
    let sourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())
    
    // Get workouts that took some amount of time
    let workoutsPredicate = HKQuery.predicateForWorkouts(with: .greaterThan, duration: 0)
    
    // AND the two predicates together
    let predicate = NSCompoundPredicate(type: .and, subpredicates: [sourcePredicate, workoutsPredicate])
    let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    
    let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
      { (sampleQuery, results, error ) -> Void in
        
        guard let samples = results as? [HKWorkout] else {
          completion(false, [HKWorkout](), error)
          return
        }
        
        completion(error == nil, samples, error)
    }
    healthKitStore.execute(sampleQuery)
  }
  
  /// This function gets samples of a certain type from the workout passed in
  func samplesForWorkout(_ workout: HKWorkout,
    intervalStart: Date,
    intervalEnd: Date,
    type: HKQuantityType,
    completion: @escaping (_ samples: [HKSample], _ error: Error?) -> Void) {
      
      // Start with the workout
      let workoutPredicate = HKQuery.predicateForObjects(from: workout)
      
      // Just get samples within the timeframe of a certain interval
      let datePredicate = HKQuery.predicateForSamples(withStart: intervalStart, end: intervalEnd, options: HKQueryOptions())
      
      // AND the two predicates
      let predicate = NSCompoundPredicate(type: .and, subpredicates: [workoutPredicate, datePredicate])
      let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
      
      let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: [startDateSort]) { (query, samples, error) -> Void in
        completion(samples!, error)
      }
      healthKitStore.execute(query)
  }
  
  /// This function gets statistics of a certain type from the workout passed in
  func statisticsForWorkout(_ workout: HKWorkout,
    intervalStart: Date,
    intervalEnd: Date,
    type: HKQuantityType,
    options: HKStatisticsOptions,
    completion: @escaping (_ statistics: HKStatistics, _ error: Error?) -> Void) {
      
      // Start with the workout
      let workoutPredicate = HKQuery.predicateForObjects(from: workout)
      
      // Just get stats within the timeframe of a certain interval
      let datePredicate = HKQuery.predicateForSamples(withStart: intervalStart, end: intervalEnd, options: HKQueryOptions())
      
      // AND the two predicates
      let predicate = NSCompoundPredicate(type: .and, subpredicates: [workoutPredicate, datePredicate])
      
      let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: options) { (query, stats, error) -> Void in
        completion(stats!, error)
      }
      healthKitStore.execute(query)
   
  }
  
  
}






















