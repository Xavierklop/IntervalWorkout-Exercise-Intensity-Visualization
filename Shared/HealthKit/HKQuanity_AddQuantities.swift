//
//  HKQuanity_AddQuantities.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/7/17.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import Foundation
import HealthKit

extension HKQuantity {
  
  func addQuantities(_ quantities: [HKQuantity]?, unit: HKUnit) -> HKQuantity {
    guard let quantities = quantities else {return self}
    
    var accumulatedQuantity: Double = self.doubleValue(for: unit)
    for quantity in quantities {
      let newQuantityValue = quantity.doubleValue(for: unit)
      accumulatedQuantity += newQuantityValue
    }
    return HKQuantity(unit: unit, doubleValue: accumulatedQuantity)
  }
  
  func addSamples(_ samples: [HKQuantitySample]?, unit: HKUnit) -> HKQuantity {
    guard let samples = samples else {return self}
    
    return addQuantities(samples.map { (sample) -> HKQuantity in
      return sample.quantity
      }, unit: unit)
  }
  
}
