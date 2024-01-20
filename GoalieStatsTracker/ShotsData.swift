//
//  ShotsData.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 10/21/23.
//

import Foundation
import SwiftUI

class ShotsData: ObservableObject, Codable, Identifiable, Hashable {
    
    @Published var runningScore: Float = 0
    @Published var totalShots: Int = 0
    @Published var saves: Int = 0
    @Published var savePercentage: Int = 0
    @Published var shots: [Shot] = []
    @Published var gameName: String = ""
    @Published var gameTime: TimeInterval
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(gameName)
        hasher.combine(gameTime)
    }

    static func == (lhs: ShotsData, rhs: ShotsData) -> Bool {
        return
            lhs.gameName == rhs.gameName &&
            lhs.gameTime == rhs.gameTime
    }
    
    enum CodingKeys: CodingKey {
        case runningScore, totalShots, saves, savePercentage, shots, gameName, gameTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if gameName.trimmingCharacters(in: .whitespaces).count == 0 {
            gameName = "My Game"
        }
        try container.encode(runningScore, forKey: .runningScore)
        try container.encode(totalShots, forKey: .totalShots)
        try container.encode(saves, forKey: .saves)
        try container.encode(savePercentage, forKey: .savePercentage)
        try container.encode(shots, forKey: .shots)
        try container.encode(gameName, forKey: .gameName)
        try container.encode(gameTime, forKey: .gameTime)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        runningScore = try container.decode(Float.self, forKey: .runningScore)
        totalShots = try container.decode(Int.self, forKey: .totalShots)
        saves = try container.decode(Int.self, forKey: .saves)
        savePercentage = try container.decode(Int.self, forKey: .savePercentage)
        shots = try container.decode(Array.self, forKey: .shots)
        gameName = try container.decode(String.self, forKey: .gameName)
        gameTime = try container.decode(TimeInterval.self, forKey: .gameTime)
    }
    
    required init() {
        gameTime = NSDate().timeIntervalSince1970
    }
    
    struct Shot: Codable, Hashable {
        var wasItAGoal: Bool
        var wasItEightMeter: Bool
        var gridItCameFrom: Int
        var coordinate: CGPoint
        
        
        // https://stackoverflow.com/questions/41972319/make-struct-hashable
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(coordinate.x)
            hasher.combine(coordinate.y)
        }
        
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
        
    func newShot(goal: Bool, eightMeter: Bool, location: CGPoint) -> Shot {
        let grid = whichGrid(coordinate: location)
        let shot = Shot(wasItAGoal: goal, wasItEightMeter: eightMeter, gridItCameFrom: grid, coordinate: location)
        runningScore += shot.calculateScore()
        totalShots += 1
        
        if goal == false {
            saves += 1
        }
        else if goal == false && eightMeter == true {
            saves += 1
        }
        savePercentage = Int((Float(saves) / Float(totalShots)) * 100)

        shots.append(shot)
        return shot
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
