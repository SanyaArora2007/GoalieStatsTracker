//
//  ShotsData.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 10/21/23.
//

import Foundation

class ShotsData {
    struct Shot {
        var goal: Bool
        var eightMeter: Bool
        var grid: Int
    }
    
    var shots: [Shot] = []
    
    func newShot(goal: Bool, eightMeter: Bool, location: CGPoint) {
        let grid = whichGrid(coordinate: location)
        let shot = Shot(goal: goal, eightMeter: eightMeter, grid: grid)
        shots.append(shot)
        
        print("New shot \(goal), \(eightMeter), \(location), \(grid)")
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
