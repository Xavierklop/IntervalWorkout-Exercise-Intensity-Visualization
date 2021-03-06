# IntervalWorkout-Exercise-Intensity-Visualization
A fitness app can help users to perform interval training. During exercising it can also display some health information such as heart rate, distance, calories, and speed. And it can even feedback physical activity changes in the form of exercise intensity and exercise ability. Besides, the fitness app can animate the heart rate and exercise intensity vividly.
## Prerequisites
Xcode 9+

Swift 4

iOS 10.0+
## Installing
`git clone https://github.com/Xavierklop/IntervalWorkout-Exercise-Intensity-Visualization.git`
## Overview
The following features are provided by this app:

 1. During exercising it can also display some health information such as heart rate, distance, calories, and speed.
 
 2. This fitness app can help users to perform interval training. 
 
 *Interval training is a combination of low-intensity training and high-intensity training, interspersed with rest or relief  periods.The high-intensity periods are typically at or close to anaerobic exercise, while the recovery periods involve the activity of lower intensity. Many cardiovascular exercises, such as running, cycling or swimming, are part of interval training.*
 
 3. Implement target heart rate(Exercise Intensity). In our app, we use exercise intensity to represent the target heart rate. In different heart rates, the corresponding exercise intensity is also different. We divided exercise intensity into five different levels.
 
 *The target heart rate is the desired range of heart rate at which the heart and lungs gain maximum benefit during aerobic exercise.*
 
 4. Implement VO2 max.
 
 *VO2max (also maximal oxygen consumption, maximal oxygen uptake, peak oxygen uptake or maximal aerobic capacity) is the maximum rate of oxygen consumption measured during incremental exercise (exercise of increasing intensity). VO2max reflects the cardiorespiratory fitness of an individ- ual and is widely used as a health indicator. VO2max is still a significant determinant of endurance when exercising over an extended period, which intuitively reflects the aerobic capacity.*
 
 5. Users can view the workout details and Move and Exercise rings in the iPhone’s activity app.
 
## Application
After entering the Interval Workout app, the user can first select the activity type. The Interval Workout app provides some activity types to choose from, such as walking, running, cycling, and more. When the user selects the activity type, the Interval Workout app presents two pickers. The two picker is used to determine the active time and rest period.

When the user sets the activity time and rest period, Interval Workout app will enter the workout interface. First, the Interval Workout app presents a countdown for user convenience. After the countdown, the workout will officially begin. In this workout interface, many workout related data will be timely feedback to the user. After finishing the exercise, the user can end the workout by force touch and save the workout.

Also, Interval Workout app visualizes heart rate and exercise intensity. Heart rate visualization better shows the changes in heart rate over a short period. Exercise intensity visualization helps users maximize exercise benefits.

## Technical features
- Use HealthKit store and retrieve health and fitness information.
- Use Core Location fetching user’s location.
- Use SpriteKit to visualize heart rate and exercise intensity.
## Framework
- HealthKit
- WatchKit
- Core Location
- SpriteKit
## License
This code may be used free of cost for a non-commercial purpose, provided the intended usage is notified to the owner via the below email address.
Any questions, please email wuhaocll@gmail.com
