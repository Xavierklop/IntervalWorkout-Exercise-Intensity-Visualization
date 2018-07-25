//
//  HKBiologicalSex+StringRepresentation.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/9/25.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import HealthKit

extension HKBiologicalSex {
  
  var stringRepresentation: String {
    switch self {
    case .notSet: return "Unknown"
    case .female: return "Female"
    case .male: return "Male"
    case .other: return "Other"
    }
  }
}
