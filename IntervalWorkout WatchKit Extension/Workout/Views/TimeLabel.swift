//
//  TimeLabel.swift
//  IntervalWorkout
//
//  Created by Hao Wu on 2017/8/16.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import Foundation
import WatchKit

extension WKInterfaceLabel {
  func setTimeInterval(_ interval: TimeInterval) {
    self.setText(interval.elapsedTimeString())
  }
}

extension TimeInterval {
  
  func elapsedTimeString() -> String {
    let h = UInt(self / 3600)
    let m = UInt(self / 60) % 60
    let s = UInt(self.truncatingRemainder(dividingBy: 60))
    
    var formattedTime: String
    
    if (h > 0) {
      formattedTime = String(format: "%lu:%02lu:%02lu", h, m, s)
    } else if (m > 0) {
      formattedTime = String(format: "%lu:%02lu", m, s)
    } else {
      formattedTime = String(format: ":%02lu", s)
    }
    return formattedTime;
  }
  
  func longElapsedTimeString() -> String {
    let h = UInt(self / 3600)
    let m = UInt(self / 60) % 60
    let s = UInt(self.truncatingRemainder(dividingBy: 60))
    
    return String(format: "%lu:%02lu:%02lu", h, m, s)
  }
  
  func elapsedTimeImage() -> UIImage {
    let timeString = self.elapsedTimeString()
    
    let imageSize = CGSize(width: 110, height: 50)
    var image: UIImage
    
    UIGraphicsBeginImageContext(imageSize)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .right
    //TODO: 这里在migrate时做出了改变
    var fontAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
    fontAttributes[NSAttributedStringKey.font] = UIFont(name: "Avenir", size: CGFloat(40.0))
    fontAttributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
    
    let attrString = NSAttributedString(string: timeString, attributes: fontAttributes)
    attrString.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize))
    
    image = UIGraphicsGetImageFromCurrentImageContext()!
    
    UIGraphicsEndImageContext()
    
    return image
  }
}
