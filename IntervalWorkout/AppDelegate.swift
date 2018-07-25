//
//  AppDelegate.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/19.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import UIKit
import HealthKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
    // Set up appearance customizations
    UINavigationBar.appearance().barTintColor = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1.0)
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    UINavigationBar.appearance().tintColor = UIColor.black
    
    return true
  }
  
  let healthStore = HKHealthStore()
  func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
    healthStore.handleAuthorizationForExtension {
      (success, error) in
    }
  }
  
}





















