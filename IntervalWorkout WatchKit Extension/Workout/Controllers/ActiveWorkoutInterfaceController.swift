//
//  ActiveWorkoutInterfaceController.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/12.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class ActiveWorkoutInterfaceController: WKInterfaceController {
  
  private let userHealthProfile = UserHealthProfile()
  
  private enum ProfileDataError: Error {
    
    case missingVo2Max
    
    var localizedDescription: String {
      switch self {
      case .missingVo2Max:
        return "Unable to calculate vo2Max with available profile data."
      }
    }
  }
  
  // ******* HealthKit Current Speed
  var distances: [Double] = []
  var durations: [TimeInterval] = []
  
  // MARK: - ****** State Management ******
  var startTime: Date?
  var timer: Timer?
  
  func elapsedTime() -> TimeInterval {
    guard let startTime = startTime else {
      return TimeInterval(0)
    }
    return Date().timeIntervalSince(startTime)
  }
  
  // ****** Models ******
  var workoutConfiguration: WorkoutConfiguration?

  var workoutSession: WorkoutSessionService?

  // ****** UI Elements ******
  @IBOutlet var elapsedTimer: WKInterfaceTimer!
  @IBOutlet var intervalTimeRemainingTimer: WKInterfaceTimer!
  
 
  @IBOutlet var exerciseAbilityLabel: WKInterfaceLabel!
  @IBOutlet var exerciseIntensityLabel: WKInterfaceLabel!
  @IBOutlet var timerGroup: WKInterfaceGroup!
  @IBOutlet var intervalPhaseBadge: WKInterfaceLabel!
  @IBOutlet var intervalPhaseContainer: WKInterfaceGroup!
  @IBOutlet var countdownGroup: WKInterfaceGroup!
  @IBOutlet var countdownTimerLabel: WKInterfaceTimer!
  @IBOutlet var detailGroup: WKInterfaceGroup!
  @IBOutlet var dataGroup: WKInterfaceGroup!
  @IBOutlet var energyDistanceDataGroup: WKInterfaceGroup!
  @IBOutlet var distanceDateLabel: WKInterfaceLabel!
  @IBOutlet var energyDateLabel: WKInterfaceLabel!
  @IBOutlet var heartRateDateLabel: WKInterfaceLabel!
  @IBOutlet var speedDataLabel: WKInterfaceLabel!
    
    
  
  // MARK: - ****** Lifecycle ******
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    workoutConfiguration = context as? WorkoutConfiguration
    self.setTitle(workoutConfiguration?.exerciseType.title)

    // Start Countdown Timer
    let coundownDuration: TimeInterval = 3
    countdownGroup.setHidden(false)
    detailGroup.setHidden(true)
    // TODO: 此处修改
//    countdownGroup.setBackgroundImageNamed("progress_ring")
//    countdownGroup.startAnimatingWithImages(in: NSRange(location: 0, length: 91), duration: -coundownDuration, repeatCount: 1)
    countdownTimerLabel.setDate(Date(timeIntervalSinceNow: coundownDuration+1))
    countdownTimerLabel.start()
    Timer.scheduledTimer(timeInterval: coundownDuration+0.2, target: self, selector: #selector(ActiveWorkoutInterfaceController.start(_:)), userInfo: nil, repeats: false)
 
  }
  

  // MARK: - ****** Save Data ******
  
  func presentSaveDataAlertController() {
    // Save Action
    let saveAction = WKAlertAction(title: "Save", style: .default, handler: {
    self.detailGroup.setHidden(true)

      // Save Data Here
      self.workoutSession?.saveSession()
    })
    
    // Cancel Action
    let cancelAction = WKAlertAction(title: "Cancel", style: .destructive, handler: {
      self.dismiss()
    })
    
    presentAlert(withTitle: "Well done!", message: "Do you want to save this workout?", preferredStyle: WKAlertControllerStyle.actionSheet, actions: [saveAction, cancelAction])

  }
  
  
  // MARK: - ****** Timer Management ******

  let tickDuration = 0.5
  var currentPhaseState: (phase: ExerciseIntervalPhase,
    endTime: TimeInterval,
    duration:TimeInterval,
    running: Bool) = (.Active, 0.0, 0.0, false)
  
  //   Start the timer and the workout session after a short countdown
  @IBAction func start(_ sender: AnyObject?) {
    guard let workoutConfiguration = workoutConfiguration else {
      return
    }
    
    timer = Timer(timeInterval: tickDuration, target: self, selector: #selector(ActiveWorkoutInterfaceController.timerTick(_:)), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    
    // Start the timer
    startTime = Date()
    
    currentPhaseState = (.Active, workoutConfiguration.activeTime, workoutConfiguration.activeTime, true)
    
    // Update Labels
    elapsedTimer.setDate(Date(timeIntervalSinceNow: TimeInterval(-1)))
    elapsedTimer.start()
   
    
    updateIntervalPhaseLabels()
    
    countdownGroup.setHidden(true)
    detailGroup.setHidden(false)
    
    workoutSession = WorkoutSessionService(configuration: workoutConfiguration)
    if workoutSession != nil {
      workoutSession!.delegate = self
      workoutSession!.startSession()
    }
  }
  
    @IBAction func swipeToNextPage(_ sender: Any) {
      // Use HealthKit to create the Heart Rate Sample Type
      guard let heartRateSampleType = HKSampleType.quantityType(forIdentifier: .heartRate) else {
        print("Heart rate Sample Type is no longer available in HealthKit")
        return
      }
      
      ProfileDataStore.getMostRecentSample(for: heartRateSampleType) { (sample, error) in
        guard let sample = sample else {
          if let error = error {
            self.displayAlert(for: error)
          }
          return
        }
      let currentlyHeartRate = sample.quantity.doubleValue(for: hrUnit)
        ActiveWorkoutInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "HeartRateDetailInterfaceController", context: currentlyHeartRate as AnyObject)]) // 如何在调用下一个页面调用？
      }
    }
  
  @IBAction func stop(_ sender: AnyObject?) {
    timer?.invalidate()
    
    currentPhaseState = (.Active, 0.0, 0.0, false)
    updateIntervalPhaseLabels()
    
    elapsedTimer.stop()
    intervalTimeRemainingTimer.stop()
    workoutSession!.stopSession()
  }
  
  @objc func timerTick(_ timer: Timer) {
    if (elapsedTime() >= currentPhaseState.endTime) {
      transitionToNextPhase()
    }
  }
  
  func transitionToNextPhase() {
    let previousPhase = currentPhaseState
    switch previousPhase.phase {
    case .Active:
      currentPhaseState = (.Rest, previousPhase.endTime + workoutConfiguration!.restTime, workoutConfiguration!.restTime, previousPhase.running)
      WKInterfaceDevice.current().play(workoutConfiguration!.restTime > 0 ? .stop : .start)
      
    case .Rest:
      currentPhaseState = (.Active, previousPhase.endTime + workoutConfiguration!.activeTime, workoutConfiguration!.activeTime, previousPhase.running)
      WKInterfaceDevice.current().play(.start)
    }
    updateIntervalPhaseLabels()
    
  }
  
  let activeColor = UIColor(red: 44/255, green: 150/255, blue: 251/255, alpha: 1.0)
  let restColor = UIColor(red: 85/255, green: 176/255, blue: 170/255, alpha: 1.0)
  
  func updateIntervalPhaseLabels() {
    intervalPhaseBadge.setText(currentPhaseState.phase.rawValue)
    
    switch currentPhaseState.phase {
    case .Active:
      timerGroup.setBackgroundColor(activeColor)
    case .Rest:
      timerGroup.setBackgroundColor(restColor)
    }
    
    intervalTimeRemainingTimer.stop()
    let durationInterval = TimeInterval(currentPhaseState.duration as Double + 1.0)
    intervalTimeRemainingTimer.setDate(Date(timeIntervalSinceNow:durationInterval))
    intervalTimeRemainingTimer.start()
    
  }
  
  private func displayAlert(for error: Error) {
    
    let action = WKAlertAction(title: "Error", style: WKAlertActionStyle.default) {
      print("Ok")
    }
    presentAlert(withTitle: "Message", message: error.localizedDescription, preferredStyle: WKAlertControllerStyle.alert, actions:[action])
  }
  
  private func loadAgeAndBiologicalSex() {
    
    do {
      let userAgeSexAndBloodType = try ProfileDataStore.getAgeSex()
      userHealthProfile.age = userAgeSexAndBloodType.age
      userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
    } catch let error {
      self.displayAlert(for: error)
    }
  }
  
  private func loadRestingHeartRate() {
    
    //1. Use HealthKit to create the Resting Heart Rate Sample Type
    guard let restingHeartRateSampleType = HKSampleType.quantityType(forIdentifier: .restingHeartRate) else {
      print("Resting Heart Rate Sample Type is no longer available in HealthKit")
      return
    }
    
    ProfileDataStore.getMostRecentSample(for: restingHeartRateSampleType) { (sample, error) in
      
      guard let sample = sample else {
        if let error = error {
          self.displayAlert(for: error)
        }
        return
      }
      let restingHeartRate = sample.quantity.doubleValue(for: hrUnit)
      self.userHealthProfile.restingHeartRate = restingHeartRate
    }
  }
  

  private func loadAndDisplayMostRecentExerciseIntensity() {
    
    // Use HealthKit to create the Heart Rate Sample Type
    guard let heartRateSampleType = HKSampleType.quantityType(forIdentifier: .heartRate) else {
      print("Heart rate Sample Type is no longer available in HealthKit")
      return
    }
    
    ProfileDataStore.getMostRecentSample(for: heartRateSampleType) { (sample, error) in
      guard let sample = sample else {
        if let error = error {
          self.displayAlert(for: error)
        }
        return
      }
      self.loadRestingHeartRate()
      guard let restingHeartRate = self.userHealthProfile.restingHeartRate else {
        if let error = error {
          self.displayAlert(for: error)
        }
        return
      }
      let currentHeartRate = sample.quantity.doubleValue(for: hrUnit)
      self.loadAgeAndBiologicalSex()
      guard let age = self.userHealthProfile.age else {
        if let error = error {
          self.displayAlert(for: error)
        }
        return
      }
      
      let doubleAge: Double = Double(age)
      // HRmax = 220 − age
      let maxHeartRate = 206.9 - doubleAge*0.67
      let exerciseIntensityIndex = (currentHeartRate - restingHeartRate)/(maxHeartRate - restingHeartRate)

      let exerciseIntensity: String
      if exerciseIntensityIndex < 0.6 {
        exerciseIntensity = "Warm up"
      } else if exerciseIntensityIndex < 0.7{
        exerciseIntensity = "Light"
      } else if exerciseIntensityIndex < 0.8{
        exerciseIntensity = "Moderate"
      } else if exerciseIntensityIndex < 0.9{
        exerciseIntensity = "Hard"
      } else {
        exerciseIntensity = "Maximum"
      }
      self.userHealthProfile.exerciseIntensity = exerciseIntensity
      self.updateExerciseIntensityAndAbilityLabels()
    }
  }
  
  private func updateExerciseIntensityAndAbilityLabels() {
    
    if let exerciseIntensity = userHealthProfile.exerciseIntensity{
      exerciseIntensityLabel.setText(exerciseIntensity)
    }
    
  }
  
  
  private func updateExerciseAbilityLabe() {
    if let vo2Max = self.userHealthProfile.vo2Max, let sex = self.userHealthProfile.biologicalSex, let age = self.userHealthProfile.age {
      // man
      if sex.rawValue == 2 {
        if age <= 24 {
          if vo2Max < 32 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 38 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 44 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 51 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 57 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 63 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 29 {
          if vo2Max < 31 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 36 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 43 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 49 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 54 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 60 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 34 {
          if vo2Max < 29 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 35 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 41 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 46 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 52 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 57 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 39 {
          if vo2Max < 28 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 33 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 39 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 44 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 49 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 55 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 44 {
          if vo2Max < 26 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 32 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 36 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 42 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 47 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 52 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 49 {
          if vo2Max < 25 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 30 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 35 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 40 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 44 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 49 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 54 {
          if vo2Max < 24 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 28 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 33 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 37 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 42 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 47 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 59 {
          if vo2Max < 22 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 27 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 31 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 35 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 40 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 44 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else {
          if vo2Max < 21 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 25 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 29 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 33 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 37 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 41 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
      }
      // woman
      else {
        if age <= 24 {
          if vo2Max < 27 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 32 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 37 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 42 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 47 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 52 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 29 {
          if vo2Max < 26 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 31 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 36 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 41 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 45 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 50 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 34 {
          if vo2Max < 25 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 30 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 34 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 38 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 43 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 47 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 39 {
          if vo2Max < 24 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 28 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 32 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 36 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 41 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 45 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 44 {
          if vo2Max < 22 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 26 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 30 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 34 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 38 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 42 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 49 {
          if vo2Max < 21 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 24 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 28 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 32 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 36 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 39 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 54 {
          if vo2Max < 19 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 23 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 26 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 30 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 33 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 37 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else if age <= 59 {
          if vo2Max < 18 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 21 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 24 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 28 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 31 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 34 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
        else {
          if vo2Max < 16 {exerciseAbilityLabel.setText("very poor")}
          else if vo2Max < 19 {exerciseAbilityLabel.setText("poor")}
          else if vo2Max < 22 {exerciseAbilityLabel.setText("fair")}
          else if vo2Max < 25 {exerciseAbilityLabel.setText("average")}
          else if vo2Max < 28 {exerciseAbilityLabel.setText("good")}
          else if vo2Max < 31 {exerciseAbilityLabel.setText("very good")}
          else  {exerciseAbilityLabel.setText("excellent")}
        }
      }
    }
  }
  
  // TODO: save vo2Max,but date problem!!!!!!!!!!!!
//  private func saveVo2MaxoHealthKit() {
//
//    guard let vo2Max = userHealthProfile.vo2Max else {
//      displayAlert(for: ProfileDataError.missingVo2Max)
//      return
//    }
//
//    ProfileDataStore.saveVo2MaxSample(vo2Max: vo2Max,
//                                             date: Date())
//  }
  

}

extension ActiveWorkoutInterfaceController: WorkoutSessionServiceDelegate {
  
  func workoutSessionService(_ service: WorkoutSessionService, didStartWorkoutAtDate startDate: Date) {
  }
  
  func workoutSessionService(_ service: WorkoutSessionService, didStopWorkoutAtDate endDate: Date) {
    presentSaveDataAlertController()
  }
  
  func workoutSessionServiceDidSave(_ service: WorkoutSessionService) {
    self.dismiss()
  }
  
  func workoutSessionService(_ service: WorkoutSessionService, didUpdateHeartrate heartRate:Double) {
    dataGroup.setHidden(false)
    heartRateDateLabel?.setText(numberFormatter.string(from: NSNumber(value: heartRate))! + " bpm")
    // MARK: load and display exercise intensity and ability, save vo2Max to HealthKit
    loadAndDisplayMostRecentExerciseIntensity()
    updateExerciseAbilityLabe()
    // TODO: save vo2Max
//    saveVo2MaxoHealthKit()
  }
  
  func workoutSessionService(_ service: WorkoutSessionService, didUpdateDistanceAndSpeed distance:Double) {
    energyDistanceDataGroup.setHidden(false)
    distanceDateLabel?.setText(numberFormatter.string(from: NSNumber(value: distance))! + " m")
    // TODO: current speed should be in this class(not here) but now in WorkoutSessionServiceQueries
    let duration = elapsedTime()
    let distance = distance
    self.distances.append(distance)
    self.durations.append(duration)
    print("distances.count is", distances.count)
    for index in distances {
      print("distance is", index)
    }
    print("durations.count is", durations.count)
    for index in durations {
      print("duration is ", index)
    }
    
    if distances.count > 2 && durations.count > 2 {
      let lastDistance = self.distances[(self.distances.count - 1)]
      let penultimateDistance = self.distances[(self.distances.count - 2)]
      let lastDate = self.durations[(self.durations.count - 1)]
      let penultimateDate = self.durations[(self.durations.count - 2)]
    
      let distance = lastDistance - penultimateDistance
      let duration = lastDate - penultimateDate
      let healthKitCurrentSpeed = distance/duration
      let speed2Decimal = String(format: "%.02f", healthKitCurrentSpeed)
      speedDataLabel.setText(speed2Decimal + " m/s")
    }
  }
  
  func workoutSessionService(_ service: WorkoutSessionService, didUpdateEnergyBurned energy:Double) {
    energyDistanceDataGroup.setHidden(false)
    energyDateLabel?.setText(numberFormatter.string(from: NSNumber(value: energy))! + " cal")
  }
}
