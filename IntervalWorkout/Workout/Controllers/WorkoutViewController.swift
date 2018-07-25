//
//  WorkoutViewController.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/21.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import UIKit

class WorkoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // ****** Models
  var workoutService: IntervalWorkoutService?
  var workout: IntervalWorkout?
  
  // ****** Interface Elements
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var table: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    guard let workout = workout else { return }
    
    refresh(nil)
    
    titleLabel?.text = workout.configuration.exerciseType.title
    title = titleLabel?.text
    durationLabel?.text = workout.configuration.exerciseType.quote
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    sizeTableHeaderToFit()
  }

  
  // MARK: - Data Access
  
  private func refresh(_ sender: AnyObject?) {
    workoutService?.readWorkoutDetail(workout!, completion: { (success, error) -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        self.table.reloadData()
      })
    })
  }
  
  
  // MARK: - Table View sizing
  
  func sizeTableHeaderToFit() {
    
    if let header = table.tableHeaderView {
      header.setNeedsLayout()
      header.layoutIfNeeded()
      let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
      
      var frame = header.frame
      frame.size.height = height
      header.frame = frame
      
      table.tableHeaderView = header
    }
  }
  

  // MARK: - Table view data source
  
  let kHeaderSection = 0
  let kIntervalSection = 1
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case kHeaderSection:
      return TableCells.cellCount.rawValue
    case kIntervalSection:
      return (workout?.intervals.count)!
    default: return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if (indexPath as NSIndexPath).section == kHeaderSection {
      let cellID = TableCells(rawValue: (indexPath as NSIndexPath).row)
      let cell = tableView.dequeueReusableCell(withIdentifier: cellID!.reuseIdentifier, for: indexPath)
      cell.imageView?.image = cellID?.image
      
      switch cellID! {
      case .completedCell:
        cell.detailTextLabel?.text = dateOnlyFormatter.string(from: workout!.endDate)
        break;
        
      case .caloriesCell:
        cell.detailTextLabel?.text = calorieFormatter.string(fromValue: workout!.calories, unit: energyFormatterUnit)
        break;
        
      case .durationCell:
        if let elapsedTime = elapsedTimeFormatter.string(from: workout!.duration) {
          cell.detailTextLabel?.text = elapsedTime
        }
        break;
        
      case .distanceCell:
        cell.detailTextLabel?.text = distanceFormatter.string(fromValue: workout!.distance, unit: distanceFormatterUnit)
        break;
        
      default:
        break;
      }
      
      return cell
      
    } else {
      
      // Intervals
      let identifier = ((indexPath as NSIndexPath).row % 2) == 0 ? "WorkoutIntervalCell_Even" : "WorkoutIntervalCell_Odd"
      let intervalCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! IntervalCell
      intervalCell.interval = workout?.intervals[(indexPath as NSIndexPath).row]
      
      return intervalCell
    }
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (indexPath as NSIndexPath).section == kIntervalSection {
      return 30
    } else {
      return tableView.rowHeight
    }
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    // Hides the empty cell row separators
    return 0.01
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    // Hides the empty cell row separators
    return UIView()
  }
}

private enum TableCells: Int {
  case completedCell = 0
  case durationCell
  case distanceCell
  case caloriesCell
  case intervalHeaderCell
  
  case cellCount
  
  var reuseIdentifier: String {
    switch self {
    case .completedCell: return "CompletedCell"
    case .caloriesCell: return "WorkoutCaloriesCell"
    case .durationCell: return "WorkoutTimeCell"
    case .distanceCell: return "WorkoutDistanceCell"
    case .intervalHeaderCell: return "IntervalHeaderCell"
      
    case .cellCount:    return ""
    }
  }
  
  var image: UIImage? {
    switch self {
    case .completedCell: return UIImage(named: "icons-thumbs_up")
    case .caloriesCell: return UIImage(named: "icons-calories")
    case .durationCell: return UIImage(named: "icons-duration")
    case .distanceCell: return UIImage(named: "icons-distance")
    case .intervalHeaderCell: return nil
      
    default:
      return nil
    }
  }
}
