//
//  ProfileDataStore.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/9/25.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import HealthKit

class ProfileDataStore {
  
  class func getAgeSex() throws -> (age: Int,
    biologicalSex: HKBiologicalSex) {
      
      let healthKitStore = HKHealthStore()
      
      do {
        
        //1. This method throws an error if these data are not available.
        let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
        let biologicalSex =       try healthKitStore.biologicalSex()
        
        //2. Use Calendar to calculate age.
        let today = Date()
        let calendar = Calendar.current
        let todayDateComponents = calendar.dateComponents([.year],
                                                          from: today)
        let thisYear = todayDateComponents.year!
        let age = thisYear - birthdayComponents.year!
        
        //3. Unwrap the wrappers to get the underlying enum values.
        let unwrappedBiologicalSex = biologicalSex.biologicalSex
        
        return (age, unwrappedBiologicalSex)
      }
  }
  
  class func getMostRecentSample(for sampleType: HKSampleType,
                                 completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
    
    //1. Use HKQuery to load the most recent samples.
    let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                          end: Date(),
                                                          options: .strictEndDate)
    
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                          ascending: false)
    
    let limit = 1
    
    let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                    predicate: mostRecentPredicate,
                                    limit: limit,
                                    sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                      
                                      //2. Always dispatch to the main thread when complete.
                                      DispatchQueue.main.async {
                                        
                                        guard let samples = samples,
                                          let mostRecentSample = samples.first as? HKQuantitySample else {
                                            
                                            completion(nil, error)
                                            return
                                        }
                                        
                                        completion(mostRecentSample, nil)
                                      }
    }
    
    HKHealthStore().execute(sampleQuery)
  }
  
  // TODO: can not save vo2Max to HealthKit, because of the end date
//  class func saveVo2MaxSample(vo2Max: Double, date: Date) {
//
//    //1.  Make sure the vo2Max type exists
//    guard let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max) else {
//      fatalError("Vo2Max Type is no longer available in HealthKit")
//    }
//
//    //2.  Use the Count HKUnit to create a vo2Max quantity
//    let vo2MaxQuantity = HKQuantity(unit: HKUnit.count(),
//                                      doubleValue: vo2Max)
//
//    let vo2MaxSample = HKQuantitySample(type: vo2MaxType,
//                                               quantity: vo2MaxQuantity,
//                                               start: date,
//                                               end: date)
//
//    //3.  Save the same to HealthKit
//    HKHealthStore().save(vo2MaxSample) { (success, error) in
//
//      if let error = error {
//        print("Error Saving vo2Max Sample: \(error.localizedDescription)")
//      } else {
//        print("Successfully saved vo2Max Sample")
//      }
//    }
//  }
  
}
