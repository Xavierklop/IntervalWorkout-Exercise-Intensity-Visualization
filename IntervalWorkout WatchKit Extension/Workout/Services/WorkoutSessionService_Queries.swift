//
//  WorkoutSessionService_Queries.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/11.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

// This is a class extension of WorkoutSessionService.

import Foundation
import HealthKit

extension WorkoutSessionService {
  
  // predicate is a filter, used for get the suitable data
  private func genericSamplePredicate (withStartDate start: Date) -> NSPredicate {
    let datePredicate = HKQuery.predicateForSamples(withStart: start, end: nil, options: .strictStartDate)
    let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
    return NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])
  }
  
  internal func distanceQuery(withStartDate start: Date) -> HKQuery {
    // Query all distance samples from the beginning of the workout session on the current device
    let predicate = genericSamplePredicate(withStartDate: start)
    
    let query = HKAnchoredObjectQuery(type: distanceType,
      predicate: predicate,
      anchor: distanceAnchorValue,
      limit: Int(HKObjectQueryNoLimit)) {
        (query, samples, deleteObjects, anchor, error) in
        
        self.distanceAnchorValue = anchor
        self.newDistanceSamples(samples)
    }
    
    query.updateHandler = {(query, samples, deleteObjects, newAnchor, error) in
      self.distanceAnchorValue = newAnchor
      self.newDistanceSamples(samples)
    }
    return query
  }
  
  internal func newDistanceSamples(_ samples: [HKSample]?) {
    // Abort if the data isn't right
    guard let samples = samples as? [HKQuantitySample], samples.count > 0 else {
      return
    }
    // note that you dispatch to the main queue: HKHealthStore doesn’t make any guarantees that it will call completion blocks on the queue that a method was called on. So you’ll need to dispatch UIKit methods to the main queue, as usual.
    DispatchQueue.main.async {
      self.distance = self.distance.addSamples(samples, unit: distanceUnit)
      self.distanceData += samples
      
      self.delegate?.workoutSessionService(self, didUpdateDistanceAndSpeed:self.distance.doubleValue(for: distanceUnit))
    }
  }
  
  internal func energyQuery(withStartDate start: Date) -> HKQuery {
    // Query all Energy samples from the beginning of the workout session on the current device
    let predicate = genericSamplePredicate(withStartDate: start)
    
    let query = HKAnchoredObjectQuery(type: (energyType),
      predicate: predicate,
      anchor: energyAnchorValue,
      limit: Int(HKObjectQueryNoLimit)) {
        (query, sampleObjects, deletedObjects, newAnchor, error) in
        
        self.energyAnchorValue = newAnchor
        self.newEnergySamples(sampleObjects)
    }
    
    query.updateHandler = {(query, samples, deleteObjects, newAnchor, error) in
      self.energyAnchorValue = newAnchor
      self.newEnergySamples(samples)
    }
    
    return query
  }
  
  internal func newEnergySamples(_ samples: [HKSample]?) {
    // Abort if the data isn't right
    guard let samples = samples as? [HKQuantitySample], samples.count > 0 else {
      return
    }
    
    DispatchQueue.main.async {
      self.energyBurned = self.energyBurned.addSamples(samples, unit: energyUnit)
      self.energyData += samples
      
      self.delegate?.workoutSessionService(self, didUpdateEnergyBurned: self.energyBurned.doubleValue(for: energyUnit))
    }
  }
  
  internal func heartRateQuery (withStartDate start: Date) -> HKQuery {
    
    // 1. Using twoof the HKQueryhelper methods,you create a predicate to get all data since the workout session began on the current device.
    let  predicate = genericSamplePredicate(withStartDate: start)
    //存在疑问？
    let query:HKAnchoredObjectQuery = HKAnchoredObjectQuery(
      type: hrType,
      predicate: predicate,
      // hrAnchorValue is Query Management
      anchor: hrAnchorValue,
      limit: Int(HKObjectQueryNoLimit)) {
        (query, sampleObjects, deletedObjects, newAnchor, error) in
        
        self.hrAnchorValue = newAnchor
        self.newHRSamples(sampleObjects)
    }

    
    query.updateHandler = {
      (query, samples, deleteObject, newAnchor, error) in
      self.hrAnchorValue = newAnchor
      self.newHRSamples(samples)
    }
    return query
  }
  
  //第一步；First, implement newHRSamples(_:) to record the samples returned by the query
  private func newHRSamples(_ samples: [HKSample]?) {
    // Abort if the data isn't right
    guard let samples = samples as? [HKQuantitySample], samples.count > 0 else {return}
    
    // DispatchQueue.main.async： return to main 
    // it updates the workout session’s heart rate with the latest value, adds all the samples to an internal array and finally, informs the delegate that there’s new heart rate data.
    DispatchQueue.main.async {
      // hrData(an internal array) is stored/queue Quantity Sample
      self.hrData += samples
      if let hr = samples.last?.quantity {
        // heartRate is Current Workout Value
        self.heartRate = hr
        self.delegate?.workoutSessionService(self, didUpdateHeartrate: hr.doubleValue(for: hrUnit))
      }
    }
  }
  
  
}
























