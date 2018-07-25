//
//  WorkoutListViewController.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/20.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutListViewController: UITableViewController {
  
  let workoutService = IntervalWorkoutService()
  var workouts: [IntervalWorkout]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.refreshControl = UIRefreshControl()
    self.refreshControl?.addTarget(self, action: #selector(WorkoutListViewController.refresh(_:)), for: .valueChanged)
    
    let healthService:HealthDataService = HealthDataService()

    
    healthService.authorizeHealthKitAccess {
      (accessGranted, error) in
      // note that you dispatch to the main queue: HKHealthStore doesn’t make any guarantees that it will call completion blocks on the queue that a method was called on. So you’ll need to dispatch UIKit methods to the main queue, as usual.
      DispatchQueue.main.async {
        if accessGranted {
          self.refresh(nil)
        } else {
          print("HealthKit authorization denied! \n\(error)")
        }
      }
    }
  }
  
  
  // MARK: - Actions
  
  @IBAction func refresh(_ sender: AnyObject?) {
    self.refreshControl?.beginRefreshing()
    self.workoutService.readIntervalWorkouts { (success, workouts, error) -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        self.refreshControl?.endRefreshing()
        self.workouts = workouts
        self.tableView.reloadData()
      })
    }
  }
  
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let workouts = workouts else {return 0}
    
    return workouts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! WorkoutCell
    
    cell.workout = workouts![(indexPath as NSIndexPath).row]
    
    return cell
  }
  
  
  // MARK: - UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    // Hides the empty cell row separators
    return 0.01
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    // Hides the empty cell row separators
    return UIView()
  }
  
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination as! WorkoutViewController
    vc.workoutService = workoutService
    vc.workout = workouts![(self.tableView.indexPathForSelectedRow! as NSIndexPath).row]
  }
  
}
