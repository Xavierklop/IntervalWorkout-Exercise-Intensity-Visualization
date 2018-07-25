//
//  UserHealthProfile.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/24.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import HealthKit

class UserHealthProfile {
  
  var age: Int?
  var biologicalSex: HKBiologicalSex?
  var restingHeartRate: Double?
  var exerciseIntensity: String?
  var speed: Double?
  
  var vo2Max: Double? {
    guard let age = self.age, let restingHeartRate = self.restingHeartRate  else {
      return nil
    }
      let doubleAge: Double = Double(age)
      let maxHeartRate = 206.9 - doubleAge*0.67
      let rHeartRate = restingHeartRate
    
      return (15.3 * maxHeartRate / rHeartRate)
  }
}
