//
//  ShotsData.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 10/21/23.
//

import Foundation
import SwiftUI

class ShotsData: ObservableObject, Codable, Identifiable, Hashable {
    
    var fieldWidth: CGFloat = 0
    var minYCoordinate: CGFloat = 0
    var maxYCoordinate: CGFloat = 0
    var halfYCoordinate: CGFloat = 0
    
    let image12meterMark: CGFloat = 300.0
    let menTransitionMark: CGFloat = 380.0
    let imageFarthestMark: CGFloat = 35.0
    
    let womenGoalMark: CGFloat = 650.0
    let menGoalMark: CGFloat = 750.0

    
    static let defaultGoalieName: String = "Me"

    // Schema version for the persisted payload. Version 1 stores shot
    // coordinates normalized as a fraction of the field width so they render
    // correctly across devices with different screen sizes. Version 0 (absent)
    // stored raw screen points captured on a single device.
    static let currentSchemaVersion: Int = 1
    var schemaVersion: Int = ShotsData.currentSchemaVersion

    @Published var runningScore: Float = 0
    @Published var totalShots: Int = 0
    @Published var saves: Int = 0
    @Published var savePercentage: Int = 0
    @Published var shots: [Shot] = []
    @Published var gameName: String = ""
    @Published var gameTime: TimeInterval
    @Published var womensField: Bool = true
    @Published var goalies: [String] = [ShotsData.defaultGoalieName]
    @Published var seasonName: String = ""

    func hash(into hasher: inout Hasher) {
        hasher.combine(gameTime)
    }

    static func == (lhs: ShotsData, rhs: ShotsData) -> Bool {
        return
            lhs.gameTime == rhs.gameTime
    }
    
    enum CodingKeys: CodingKey {
        case runningScore, totalShots, saves, savePercentage, shots, gameName, gameTime, womensField, goalies, seasonName, schemaVersion
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(runningScore, forKey: .runningScore)
        try container.encode(totalShots, forKey: .totalShots)
        try container.encode(saves, forKey: .saves)
        try container.encode(savePercentage, forKey: .savePercentage)
        try container.encode(shots, forKey: .shots)
        try container.encode(gameName, forKey: .gameName)
        try container.encode(gameTime, forKey: .gameTime)
        try container.encode(womensField, forKey: .womensField)
        try container.encode(goalies, forKey: .goalies)
        try container.encode(seasonName, forKey: .seasonName)
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
        do {
            womensField = try container.decode(Bool.self, forKey: .womensField)
        }
        catch {
            womensField = true
        }
        goalies = (try? container.decode([String].self, forKey: .goalies)) ?? [ShotsData.defaultGoalieName]
        seasonName = (try? container.decode(String.self, forKey: .seasonName)) ?? ""
        // A payload without a version predates normalized coordinates.
        schemaVersion = (try? container.decode(Int.self, forKey: .schemaVersion)) ?? 0
    }
    
    required init() {
        gameTime = NSDate().timeIntervalSince1970
    }
    
    func imageGoalMark() -> CGFloat {
        if womensField == true {
            return womenGoalMark
        }
        else {
            return menGoalMark
        }
    }
    
    func setFieldSize(width: CGFloat) {
        self.fieldWidth = width
        let ratio = width / 1178.0
        self.minYCoordinate = imageFarthestMark * ratio
        self.maxYCoordinate = imageGoalMark() * ratio
        if womensField == true {
            self.halfYCoordinate = image12meterMark * ratio
        }
        else {
            self.halfYCoordinate = menTransitionMark * ratio
        }
    }

    // Converts a screen-space tap point into a screen-size-agnostic coordinate
    // stored as a fraction of the field width. Everything in the field view
    // scales linearly with fieldWidth, so a single factor round-trips exactly.
    func normalize(_ point: CGPoint) -> CGPoint {
        guard fieldWidth > 0 else { return point }
        return CGPoint(x: point.x / fieldWidth, y: point.y / fieldWidth)
    }

    // Reverses `normalize`, turning a stored fraction back into a point in the
    // current field view's coordinate space.
    func denormalize(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x * fieldWidth, y: point.y * fieldWidth)
    }

    // The point at which a stored shot should be drawn. Version 1 shots are
    // normalized and must be scaled to the current field; legacy (version 0)
    // shots are still raw screen points and render as-is — which is correct on
    // the device that recorded them, where they get upgraded on first view.
    func displayCoordinate(for shot: Shot) -> CGPoint {
        if schemaVersion >= ShotsData.currentSchemaVersion {
            return denormalize(shot.coordinate)
        }
        return shot.coordinate
    }

    // Upgrades a legacy game in place by normalizing its raw shot coordinates
    // using the current fieldWidth. This is exact when the upgrade happens on a
    // device whose field width matches the one used to record the game.
    // Returns whether anything changed so callers can persist the upgrade.
    func migrateCoordinatesIfNeeded() -> Bool {
        guard schemaVersion < ShotsData.currentSchemaVersion, fieldWidth > 0 else {
            return false
        }
        shots = shots.map { shot in
            var upgraded = shot
            upgraded.coordinate = normalize(shot.coordinate)
            return upgraded
        }
        schemaVersion = ShotsData.currentSchemaVersion
        return true
    }
    
    struct Shot: Codable, Hashable {
        var wasItAGoal: Bool
        var wasItEightMeter: Bool
        var gridItCameFrom: Int
        var coordinate: CGPoint
        var goalieName: String = ShotsData.defaultGoalieName

        enum CodingKeys: CodingKey {
            case wasItAGoal, wasItEightMeter, gridItCameFrom, coordinate, goalieName
        }

        init(wasItAGoal: Bool, wasItEightMeter: Bool, gridItCameFrom: Int, coordinate: CGPoint, goalieName: String) {
            self.wasItAGoal = wasItAGoal
            self.wasItEightMeter = wasItEightMeter
            self.gridItCameFrom = gridItCameFrom
            self.coordinate = coordinate
            self.goalieName = goalieName
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            wasItAGoal = try container.decode(Bool.self, forKey: .wasItAGoal)
            wasItEightMeter = try container.decode(Bool.self, forKey: .wasItEightMeter)
            gridItCameFrom = try container.decode(Int.self, forKey: .gridItCameFrom)
            coordinate = try container.decode(CGPoint.self, forKey: .coordinate)
            goalieName = (try? container.decode(String.self, forKey: .goalieName)) ?? ShotsData.defaultGoalieName
        }

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
        
    func newShot(goal: Bool, eightMeter: Bool, location: CGPoint, goalieName: String) -> Shot? {
        if location.y > maxYCoordinate || location.y < minYCoordinate {
            return nil
        }
        let grid = whichGrid(coordinate: location)
        // Bounds and grid are decided in screen space above; the coordinate is
        // persisted normalized so it renders correctly on any screen size.
        let shot = Shot(wasItAGoal: goal, wasItEightMeter: eightMeter, gridItCameFrom: grid, coordinate: normalize(location), goalieName: goalieName)
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
    
    func shots(forGoalie goalieName: String) -> [Shot] {
        return shots.filter { $0.goalieName == goalieName }
    }

    func totalShots(forGoalie goalieName: String) -> Int {
        return shots(forGoalie: goalieName).count
    }

    func saves(forGoalie goalieName: String) -> Int {
        return shots(forGoalie: goalieName).filter { $0.wasItAGoal == false }.count
    }

    func runningScore(forGoalie goalieName: String) -> Float {
        return shots(forGoalie: goalieName).reduce(0) { $0 + $1.calculateScore() }
    }

    func savePercentage(forGoalie goalieName: String) -> Int {
        let total = totalShots(forGoalie: goalieName)
        if total == 0 {
            return 0
        }
        return Int((Float(saves(forGoalie: goalieName)) / Float(total)) * 100)
    }

    func removeLastShot(forGoalie goalieName: String) {
        guard let index = shots.lastIndex(where: { $0.goalieName == goalieName }) else {
            return
        }
        let removed = shots[index]
        if removed.wasItAGoal == false {
            saves -= 1
        }
        totalShots -= 1
        runningScore -= removed.calculateScore()

        if totalShots == 0 {
            savePercentage = 0
        }
        else {
            savePercentage = Int((Float(saves) / Float(totalShots)) * 100)
        }
        shots.remove(at: index)
    }
        
    
    func whichGrid(coordinate: CGPoint) -> Int {
        var grid = 0
        if coordinate.x <= ( fieldWidth * 0.33 ) {
            if coordinate.y <= halfYCoordinate {
                grid = 1
            }
            else {
                grid = 4
            }
        }
        else if coordinate.x > ( fieldWidth * 0.33 ) && coordinate.x < ( fieldWidth * 0.66 ) {
            if coordinate.y <= halfYCoordinate {
                grid = 2
            }
            else {
                grid = 5
            }
        }
        else {
            if coordinate.y <= halfYCoordinate {
                grid = 3
            }
            else {
                grid = 6
            }
        }
        
        return grid
    }
}
