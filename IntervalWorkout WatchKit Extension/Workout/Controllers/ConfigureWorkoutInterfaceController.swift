//
//  ConfigureWorkoutInterfaceController.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/10.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import WatchKit
import Foundation

class ConfigureWorkoutInterfaceController: WKInterfaceController {
  
  // MARK: - ****** Models ******
  
  var workoutConfiguration: WorkoutConfiguration?
  
  
  // MARK: - ****** UI ******
  
  @IBOutlet var activePicker: WKInterfacePicker!
  @IBOutlet var restPicker: WKInterfacePicker!
  
  
  // MARK: - ****** Lifecycle ******
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    workoutConfiguration = context as? WorkoutConfiguration
    
    // Configure the Active Time Picker
    activePicker.setItems(activeTimePickerValues.map { (interval) -> WKPickerItem in
      let item = WKPickerItem()
      item.contentImage = WKImage(image: interval.elapsedTimeImage())
      return item
    })
    
    if let index = activeTimePickerValues.index(of: (workoutConfiguration?.activeTime)!) {
      activePicker.setSelectedItemIndex(index)
    } else {
      activePicker.setSelectedItemIndex(0)
    }
    
    // Configure the Rest Time Picker
    restPicker.setItems(restTimePickerValues.map { (interval) -> WKPickerItem in
      let item = WKPickerItem()
      item.contentImage = WKImage(image: interval.elapsedTimeImage())
      return item
      })
    restPicker.setSelectedItemIndex(0)

    if let index = restTimePickerValues.index(of: (workoutConfiguration?.restTime)!) {
      restPicker.setSelectedItemIndex(index)
    } else {
      restPicker.setSelectedItemIndex(0)
    }
  }
  
  // MARK: - ****** Navigation ******
  
  override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
    return workoutConfiguration
  }
  
  // MARK: - ****** Pickers ******
  
  let activeTimePickerValues: [TimeInterval] = {
    var intervals = [TimeInterval]()
    for time in stride(from: 10, through: 600, by: 5) {
      intervals.append(TimeInterval(time))
    }
    return intervals
  } ()
  
  let restTimePickerValues: [TimeInterval] = {
    var intervals = [TimeInterval]()
    for time in stride(from: 5, through: 120, by: 5) {
      intervals.append(TimeInterval(time))
    }
    return intervals
  } ()
  
  @IBAction func pickActiveTime(_ value: Int) {
    workoutConfiguration?.activeTime = activeTimePickerValues[value]
  }
  
  @IBAction func pickRestTime(_ value: Int) {
    workoutConfiguration?.restTime = restTimePickerValues[value]
  }
  
}
