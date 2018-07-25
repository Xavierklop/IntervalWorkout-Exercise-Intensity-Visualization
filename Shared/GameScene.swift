//
//  GameScene.swift
//  IntervalWorkout WatchKit Extension
//
//  Created by Hao Wu on 2017/11/21.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import SpriteKit
import HealthKit
import WatchKit

class GameScene: SKScene {
  
  let heart = SKSpriteNode(imageNamed: "heart")
  let background = SKSpriteNode(imageNamed: "background")
  
  override func sceneDidLoad() {
    backgroundColor = SKColor.black
    background.position = CGPoint(x: size.width * 0.5, y: size.height * 0.38)
    addChild(background)
    heart.position = CGPoint(x: size.width * 0.5, y: size.height * 0.38)
    addChild(heart)
    
    let grayChart = SKSpriteNode(color: UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1.0),
                                 size: CGSize(width: size.width*0.19, height: size.height*0.55))
    grayChart.position = CGPoint(x: -background.size.width*0.4, y: background.size.height*9)
    grayChart.name = "grayChart"
    
    let blueChart = SKSpriteNode(color: UIColor(red: 79/255, green: 176/255, blue: 240/255, alpha: 1.0),
                                 size: CGSize(width: size.width*0.19, height: size.height*0.55))
    blueChart.position = CGPoint(x: -background.size.width*0.2, y: background.size.height*9)
    blueChart.name = "blueChart"
    
    let greenChart = SKSpriteNode(color: UIColor(red: 146/255, green: 208/255, blue: 80/255, alpha: 1.0),
                                  size: CGSize(width: size.width*0.19, height: size.height*0.55))
    greenChart.position = CGPoint(x: 0, y: background.size.height*9)
    greenChart.name = "greenChart"
    
    let orangeChart = SKSpriteNode(color: UIColor(red: 241/255, green: 148/255, blue: 51/255, alpha: 1.0),
                                  size: CGSize(width: size.width*0.19, height: size.height*0.55))
    orangeChart.position = CGPoint(x: background.size.width*0.2, y: background.size.height*9)
    orangeChart.name = "orangeChart"
    
    let redChart = SKSpriteNode(color: UIColor(red: 233/255, green: 65/255, blue: 51/255, alpha: 1.0),
                                  size: CGSize(width: size.width*0.19, height: size.height*0.55))
    redChart.position = CGPoint(x: background.size.width*0.4, y: background.size.height*9)
    redChart.name = "redChart"
    
    background.addChild(grayChart)
    background.addChild(blueChart)
    background.addChild(greenChart)
    background.addChild(orangeChart)
    background.addChild(redChart)
    
  }
  
}
