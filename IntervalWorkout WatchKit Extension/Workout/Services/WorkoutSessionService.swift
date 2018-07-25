//
//  WorkoutSessionService.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/11.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

//This class provides all of the functionality for managing a workout session, querying sensor data and returning that information to a delegate.

import Foundation
import HealthKit


protocol WorkoutSessionServiceDelegate: class {
  /// This method is called when an HKWorkoutSession is correctly started
  func workoutSessionService(_ service: WorkoutSessionService, didStartWorkoutAtDate startDate: Date)

  /// This method is called when an HKWorkoutSession is correctly stopped
  func workoutSessionService(_ service: WorkoutSessionService, didStopWorkoutAtDate endDate: Date)

  /// This method is called when a workout is successfully saved
  func workoutSessionServiceDidSave(_ service: WorkoutSessionService)
  
  /// This method is called when an anchored query receives new heart rate data
  func workoutSessionService(_ service: WorkoutSessionService, didUpdateHeartrate heartRate:Double)

  /// This method is called when an anchored query receives new distance data
  func workoutSessionService(_ service: WorkoutSessionService, didUpdateDistanceAndSpeed distance:Double)
  
  /// This method is called when an anchored query receives new energy data
  func workoutSessionService(_ service: WorkoutSessionService, didUpdateEnergyBurned energy:Double)
}


class WorkoutSessionService: NSObject {
  
  fileprivate let healthService = HealthDataService()
  let configuration: WorkoutConfiguration
  let session: HKWorkoutSession
  
  var startDate: Date?
  var endDate: Date?

  // ****** Units and Types
  var distanceType: HKQuantityType {
    if configuration.exerciseType.activityType == .cycling {
      return cyclingDistanceType
    } else {
      return runningDistanceType
    }
  }
  
  // ****** Stored Samples and Queries
  var energyData: [HKQuantitySample] = [HKQuantitySample]()
  var hrData: [HKQuantitySample] = [HKQuantitySample]()
  var distanceData: [HKQuantitySample] = [HKQuantitySample]()
  
  // ****** Query Management
  fileprivate var queries: [HKQuery] = [HKQuery]()
  internal var distanceAnchorValue:HKQueryAnchor?
  internal var hrAnchorValue:HKQueryAnchor?
  internal var energyAnchorValue:HKQueryAnchor?

  weak var delegate:WorkoutSessionServiceDelegate?
  
  // ****** Current Workout Values
  var energyBurned: HKQuantity
  var distance: HKQuantity
  var heartRate: HKQuantity
  
  init?(configuration: WorkoutConfiguration) {
    self.configuration = configuration
    
    let hkWorkoutConfiguration = HKWorkoutConfiguration()
    
    hkWorkoutConfiguration.activityType = configuration.exerciseType.activityType
    hkWorkoutConfiguration.locationType = configuration.exerciseType.location
    
    do {
      session = try HKWorkoutSession(configuration: hkWorkoutConfiguration)
    } catch {
      return nil
    }
    
    // Initialize Current Workout Values
    energyBurned = HKQuantity(unit: energyUnit, doubleValue: 0.0)
    distance = HKQuantity(unit: distanceUnit, doubleValue: 0.0)
    heartRate = HKQuantity(unit: hrUnit, doubleValue: 0.0)

    super.init()
    session.delegate = self
  }
  
  func startSession() {
    healthService.healthKitStore.start(session)
  }
  
  func stopSession() {
    healthService.healthKitStore.end(session)
  }
  
  func saveSession() {
    healthService.saveWorkout(self) { (success, error) in
      if success {
        self.delegate?.workoutSessionServiceDidSave(self)
      }
    }
  }
  
  
  
}

extension WorkoutSessionService: HKWorkoutSessionDelegate {
  
  func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
    // note that you dispatch to the main queue: HKHealthStore doesn’t make any guarantees that it will call completion blocks on the queue that a method was called on. So you’ll need to dispatch UIKit methods to the main queue, as usual.
    DispatchQueue.main.async {
      
      switch toState {
        
      case .running: self.sessionStarted(date)
      case .ended: self.sessionEnded(date)
      case .paused: break
      default: print("Something weird happend. Not a valid state")
      }
    }
  }
  
  func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    sessionEnded(Date())
  }
  
  fileprivate func sessionStarted(_ date: Date) {
    // Creat and Start Queries
    queries.append(distanceQuery(withStartDate: date))
    queries.append(heartRateQuery(withStartDate: date))
    queries.append(energyQuery(withStartDate: date))
    
    for query in queries {
      healthService.healthKitStore.execute(query)
    }
    
    startDate = date
    // let the delegate know
    delegate?.workoutSessionService(self, didStartWorkoutAtDate: date)
  }
  
  fileprivate func sessionEnded(_ date: Date) {
    endDate = date
    // Let delegate know
    self.delegate?.workoutSessionService(self, didStopWorkoutAtDate: date)
  }
}
























