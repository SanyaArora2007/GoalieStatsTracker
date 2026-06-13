//
//  CloudGameStore.swift
//  GoalieStatsTracker
//
//  Created by Rishi Arora on 6/10/26.
//

import CloudKit
import Foundation

/// Stores completed games in the user's private CloudKit database, one record
/// per game keyed by gameTime. The full ShotsData is kept as a JSON payload so
/// new fields sync without CloudKit schema changes.
class CloudGameStore {

    static let containerIdentifier = "iCloud.com.sanyaarora2025.lax-goalie"
    static let gameRecordType = "Game"
    static let seasonsRecordType = "SeasonList"
    // CloudKit rejects operations with more than 400 records
    static let maxRecordsPerOperation = 200

    // The ordered season list lives in a single record so its order is
    // preserved as one unit.
    private static let seasonsRecordName = "seasonList"

    private let container: CKContainer
    private let database: CKDatabase

    init() {
        container = CKContainer(identifier: CloudGameStore.containerIdentifier)
        database = container.privateCloudDatabase
    }

    func accountAvailable() async -> Bool {
        let status = try? await container.accountStatus()
        return status == .available
    }

    private static func recordID(for gameTime: TimeInterval) -> CKRecord.ID {
        CKRecord.ID(recordName: "game-\(gameTime)")
    }

    private static func record(for game: ShotsData) throws -> CKRecord {
        let record = CKRecord(recordType: gameRecordType, recordID: recordID(for: game.gameTime))
        record["gameTime"] = game.gameTime as CKRecordValue
        record["payload"] = try JSONEncoder().encode(game) as CKRecordValue
        return record
    }

    /// Uploads games to iCloud, overwriting any existing record with the same
    /// gameTime. Returns the gameTimes that were saved successfully; callers
    /// should retry the rest later.
    func saveGames(_ games: [ShotsData]) async -> Set<TimeInterval> {
        var saved: Set<TimeInterval> = []
        var index = 0
        while index < games.count {
            let chunk = Array(games[index..<min(index + CloudGameStore.maxRecordsPerOperation, games.count)])
            index += CloudGameStore.maxRecordsPerOperation

            var gameTimesByRecordName: [String: TimeInterval] = [:]
            var records: [CKRecord] = []
            for game in chunk {
                guard let record = try? CloudGameStore.record(for: game) else {
                    continue
                }
                gameTimesByRecordName[record.recordID.recordName] = game.gameTime
                records.append(record)
            }

            guard let (saveResults, _) = try? await database.modifyRecords(
                saving: records,
                deleting: [],
                savePolicy: .allKeys,
                atomically: false
            ) else {
                continue
            }
            for (recordID, result) in saveResults {
                if case .success = result, let gameTime = gameTimesByRecordName[recordID.recordName] {
                    saved.insert(gameTime)
                }
            }
        }
        return saved
    }

    func fetchAllGames() async throws -> [ShotsData] {
        let query = CKQuery(recordType: CloudGameStore.gameRecordType, predicate: NSPredicate(format: "gameTime > 0"))
        query.sortDescriptors = [NSSortDescriptor(key: "gameTime", ascending: false)]

        var response: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
        do {
            response = try await database.records(matching: query)
        }
        catch let error as CKError where error.code == .unknownItem || error.code == .invalidArguments {
            // No game has ever been saved, so the record type doesn't exist yet
            return []
        }

        var games: [ShotsData] = []
        while true {
            for (_, result) in response.matchResults {
                guard let record = try? result.get(),
                      let payload = record["payload"] as? Data,
                      let game = try? JSONDecoder().decode(ShotsData.self, from: payload) else {
                    continue
                }
                games.append(game)
            }
            guard let cursor = response.queryCursor else {
                break
            }
            response = try await database.records(continuingMatchFrom: cursor)
        }
        return games
    }

    func deleteGame(gameTime: TimeInterval) async throws {
        do {
            try await database.deleteRecord(withID: CloudGameStore.recordID(for: gameTime))
        }
        catch let error as CKError where error.code == .unknownItem {
            // Already deleted or never synced
        }
    }

    // MARK: - Seasons

    private static func seasonsRecordID() -> CKRecord.ID {
        CKRecord.ID(recordName: seasonsRecordName)
    }

    /// Uploads the ordered season list, overwriting the existing record.
    /// Returns whether the save succeeded.
    func saveSeasons(_ seasons: [String]) async -> Bool {
        guard let payload = try? JSONEncoder().encode(seasons) else {
            return false
        }
        let record = CKRecord(recordType: CloudGameStore.seasonsRecordType, recordID: CloudGameStore.seasonsRecordID())
        record["payload"] = payload as CKRecordValue
        do {
            _ = try await database.modifyRecords(
                saving: [record],
                deleting: [],
                savePolicy: .allKeys,
                atomically: false
            )
            return true
        }
        catch {
            return false
        }
    }

    /// Fetches the ordered season list, or nil if no record exists yet.
    func fetchSeasons() async throws -> [String]? {
        do {
            let record = try await database.record(for: CloudGameStore.seasonsRecordID())
            guard let payload = record["payload"] as? Data,
                  let seasons = try? JSONDecoder().decode([String].self, from: payload) else {
                return nil
            }
            return seasons
        }
        catch let error as CKError where error.code == .unknownItem {
            // No season list has been saved yet
            return nil
        }
    }
}
