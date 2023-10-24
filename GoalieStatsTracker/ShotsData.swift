//
//  ShotsData.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 10/21/23.
//

import Foundation

class ShotsData {
    
    var runningScore: Float = 0
    
    struct Shot {
        var wasItAGoal: Bool
        var wasItEightMeter: Bool
        var gridItCameFrom: Int
        
        func calculateScore() -> Float {
            switch (gridItCameFrom) {
            case 1:
                if wasItAGoal == true {
                    return -3
                }
                else {
                    return 0.5
                }
                
            case 2:
                if wasItAGoal == true {
                    if wasItEightMeter == true {
                        return -1
                    }
                    else {
                        return -2
                    }
                }
                else {
                    if wasItEightMeter == true {
                        return 2
                    }
                    else {
                        return 1
                    }
                }
                
            case 3:
                if wasItAGoal == true {
                    return -3
                }
                else {
                    return 0.5
                }
                
            case 4:
                if wasItAGoal == true {
                    if wasItEightMeter == true {
                        return -1
                    }
                    else {
                        return -1.5
                    }
                }
                else {
                    if wasItEightMeter == true {
                        return 2.5
                    }
                    else {
                        return 2
                    }
                }
                
            case 5:
                if wasItAGoal == true {
                    if wasItEightMeter == true {
                        return -0.5
                    }
                    else {
                        return -1
                    }
                }
                else {
                    if wasItEightMeter == true {
                        return 3.5
                    }
                    else {
                        return 3
                    }
                }
                
            case 6:
                if wasItAGoal == true {
                    if wasItEightMeter == true {
                        return -1
                    }
                    else {
                        return -1.5
                    }
                }
                else {
                    if wasItEightMeter == true {
                        return 2.5
                    }
                    else {
                        return 2
                    }
                }
                
            default:
                return 0
            }
        }
    }
    
    var shots: [Shot] = []
    
    func newShot(goal: Bool, eightMeter: Bool, location: CGPoint) {
        let grid = whichGrid(coordinate: location)
        let shot = Shot(wasItAGoal: goal, wasItEightMeter: eightMeter, gridItCameFrom: grid)
        runningScore += shot.calculateScore()
        shots.append(shot)
        
        print("New shot \(goal), \(eightMeter), \(location), \(grid), \(runningScore)")
    }
    
    func whichGrid(coordinate: CGPoint) -> Int {
        var grid = 0
        if coordinate.x <= 133 {
            if coordinate.y <= 120 {
                grid = 1
            }
            else {
                grid = 4
            }
        }
        else if coordinate.x > 133 && coordinate.x < 266 {
            if coordinate.y <= 120 {
                grid = 2
            }
            else {
                grid = 5
            }
        }
        else {
            if coordinate.y <= 120 {
                grid = 3
            }
            else {
                grid = 6
            }
        }
        
        return grid
    }
}
