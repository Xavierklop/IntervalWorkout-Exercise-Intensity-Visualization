//
//  HeartRateDetailController.swift
//  IntervalWorkout WatchKit Extension
//
//  Created by Hao Wu on 2017/11/20.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit
import SpriteKit

class HeartRateDetailInterfaceController: WKInterfaceController {
  
  private let userHealthProfile = UserHealthProfile()
  
  @IBOutlet var currentHeartRateLabel: WKInterfaceLabel!
  @IBOutlet var skInterface: WKInterfaceSKScene!
  
  var scene: GameScene!
  private var seconds = 0
  private var timer: Timer?
  
  var grayLevel = 0
  var blueLevel = 0
  var greenLevel = 0
  var orangeLevel = 0
  var redLevel = 0
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    scene = GameScene(size: contentFrame.size)
    skInterface.presentScene(scene)
    skInterface.preferredFramesPerSecond = 30
    
    
  }
  
  override func didAppear() {
    updateDisplay()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      self.eachSecond()
    }
    
  }
  
  private func updateDisplay() {
    let chartHeight = self.scene.size.height*0.55
    let chartY = self.scene.background.size.height*9
    var grayCoef = 1.0
    var blueCoef = 1.0
    var greenCoef = 1.0
    var orangeCoef = 1.0
    var redCoef = 1.0
    
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
      let currentHeartRateInt = Int(currentHeartRate)
      let cHRInString = String(currentHeartRateInt)
      
      self.loadAgeAndBiologicalSex()
      if let age = self.userHealthProfile.age {
        let doubleAge = Double(age)
        let maxHeartRate = 206.9 - doubleAge*0.67
        let value = (Double(currentHeartRateInt) - restingHeartRate)/(maxHeartRate - restingHeartRate)

        // set the text, heart image
        if value < 0.6 {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(1)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.38 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
          
          self.grayLevel += 1
          //test
          print("gray level is ", self.grayLevel)
          
        }else if value < 0.7 {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 79/255, green: 176/255, blue: 240/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(3)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.38 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 79/255, green: 176/255, blue: 240/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
          
          self.blueLevel += 1
          //test
          print("blue level is ", self.blueLevel)
          
        }else if value < 0.8 {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 146/255, green: 208/255, blue: 80/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(5)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.5 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 146/255, green: 208/255, blue: 80/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
          
          self.greenLevel += 1
          // test
          print("green level is ", self.greenLevel)
          
        }else if value < 0.9 {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 241/255, green: 148/255, blue: 51/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(7)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.5 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 241/255, green: 148/255, blue: 51/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
          self.orangeLevel += 1
          
        }else {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 233/255, green: 65/255, blue: 51/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(9)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.5 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 233/255, green: 65/255, blue: 51/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
          self.redLevel += 1
          
        }
        
        let sum = Double(self.greenLevel + self.grayLevel + self.blueLevel + self.orangeLevel + self.redLevel)
        // test
        print("sum is ", sum)
        print("now gray level is ", self.grayLevel)
        print("now blue level is ", self.blueLevel)
        print("now green level is ", self.greenLevel)
        grayCoef = Double(self.grayLevel)/sum
        print("gray coef is ", grayCoef)
        blueCoef = Double(self.blueLevel)/sum
        print("blueCoef is ", blueCoef)
        greenCoef = Double(self.greenLevel)/sum
        print("greenCoef is ", greenCoef)
        orangeCoef = Double(self.orangeLevel)/sum
        redCoef = Double(self.redLevel)/sum
        
        // test
        for node in self.scene.background.children {
          if (node.name == "grayChart") {
            let grayActionMove = SKAction.move(to: CGPoint(x: -self.scene.background.size.width*0.4, y: chartY+CGFloat(grayCoef-1)/2*chartHeight), duration: TimeInterval(1))
            let grayChangeHeight = SKAction.resize(toHeight: chartHeight*CGFloat(grayCoef), duration: 1)
            let group = SKAction.group([grayActionMove, grayChangeHeight])
            node.run(group)
          }else if (node.name == "blueChart") {
            let blueActionMove = SKAction.move(to: CGPoint(x: -self.scene.background.size.width*0.2, y: chartY+CGFloat(blueCoef-1)/2*chartHeight), duration: TimeInterval(1))
            let blueChangeHeight = SKAction.resize(toHeight: chartHeight*CGFloat(blueCoef), duration: 1)
            let group = SKAction.group([blueActionMove, blueChangeHeight])
            node.run(group)
          }else if (node.name == "greenChart") {
            let greenActionMove = SKAction.move(to: CGPoint(x: 0, y: chartY+CGFloat(greenCoef-1)/2*chartHeight), duration: TimeInterval(1))
            let greenChangeHeight = SKAction.resize(toHeight: chartHeight*CGFloat(greenCoef), duration: 1)
            let group = SKAction.group([greenActionMove, greenChangeHeight])
            node.run(group)
          }else if (node.name == "orangeChart") {
            let orangeActionMove = SKAction.move(to: CGPoint(x: self.scene.background.size.width*0.2, y: chartY+CGFloat(orangeCoef-1)/2*chartHeight), duration: TimeInterval(1))
            let orangeChangeHeight = SKAction.resize(toHeight: chartHeight*CGFloat(orangeCoef), duration: 1)
            let group = SKAction.group([orangeActionMove, orangeChangeHeight])
            node.run(group)
          }else {
            let redActionMove = SKAction.move(to: CGPoint(x: self.scene.background.size.width*0.4, y: chartY+CGFloat(redCoef-1)/2*chartHeight), duration: TimeInterval(1))
            let redChangeHeight = SKAction.resize(toHeight: chartHeight*CGFloat(redCoef), duration: 1)
            let group = SKAction.group([redActionMove, redChangeHeight])
            node.run(group)
          }
        }
        

      }
    }
  }
  
  private func displayAlert(for error: Error) {
    
    let action = WKAlertAction(title: "Error", style: WKAlertActionStyle.default) {
      print("Ok")
    }
    presentAlert(withTitle: "Message", message: error.localizedDescription, preferredStyle: WKAlertControllerStyle.alert, actions:[action])
  }
  
  func eachSecond() {
    seconds += 1
    updateDisplay()
  }
  
  // MARK: MaxHeartRate part
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
  // TODO: 大问题，功能无法使用，而且用了后更加麻烦!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!可能的解决方案：或许可以用一个button在左上角返回？
//    @IBAction func swipeToActiveWorkoutInterfaceController(_ sender: Any) {
//      HeartRateDetailInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "ActiveWorkoutInterfaceController", context: seconds as AnyObject)]) // why cannot set context to nil?
//    }
  
}


















