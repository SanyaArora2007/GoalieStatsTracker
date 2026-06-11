//
//  GameStore.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 11/10/23.
//

import Foundation
import SwiftUI

@MainActor
class GameStore: ObservableObject {
    @Published var storage: [ShotsData] = []
    @Published var ongoingGame: ShotsData? = nil

    private let cloudStore = CloudGameStore()
    private var syncTask: Task<Void, Never>? = nil

    private static let syncedGameTimesKey = "GameStore.syncedGameTimes"
    private static let pendingCloudDeletesKey = "GameStore.pendingCloudDeletes"

    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("GoalieStatsTracker")
    }
    
    private static func ongoingGameFileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("GoalieStatsTrackerOngoingGame")
    }

    func load() async throws -> [ShotsData] {
        let task = Task<[ShotsData], Error> {
            self.loadOngoingGame()
            let fileURL = try Self.fileURL()
            if let data = try? Data(contentsOf: fileURL) {
                storage = try JSONDecoder().decode([ShotsData].self, from: data)
            }
            return storage
        }
        let games = try await task.value
        syncWithCloud()
        return games
    }

    func save(game: ShotsData) async throws {
        let task = Task {
            try await discardOngoingGame()
            if game.gameName.trimmingCharacters(in: .whitespaces).count == 0 {
                game.gameName = "My Game"
            }
            storage.insert(game, at: 0)
            let data = try JSONEncoder().encode(storage)
            let outfile = try GameStore.fileURL()
            try data.write(to: outfile)
        }
        _  = try await task.value
        pushToCloud(game)
    }

    func saveOngoingGame(game: ShotsData) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(game)
            let outfile = try GameStore.ongoingGameFileURL()
            try data.write(to: outfile)
        }
        _  = try await task.value
    }

    func update(game: ShotsData) async throws {
        let task = Task {
            if let index = storage.firstIndex(where: { $0.gameTime == game.gameTime }) {
                storage[index] = game
            }

            let data = try JSONEncoder().encode(storage)
            let outfile = try GameStore.fileURL()
            try data.write(to: outfile)
        }
        _  = try await task.value
        pushToCloud(game)
    }

    func loadOngoingGame() {
        do {
            let fileURL = try Self.ongoingGameFileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return
            }
            ongoingGame = try JSONDecoder().decode(ShotsData.self, from: data)
        }
        catch {}
    }

    func discardOngoingGame()  async throws {
        let task = Task {
            do {
                try FileManager.default.removeItem(at: GameStore.ongoingGameFileURL())
                ongoingGame = nil
            } catch {}
        }
        _  = await task.value
    }

    func remove(games gamesToRemove: [ShotsData]) async throws {
        let gameTimes = Set(gamesToRemove.map { $0.gameTime })
        storage.removeAll { gameTimes.contains($0.gameTime) }
        let data = try JSONEncoder().encode(storage)
        let outfile = try GameStore.fileURL()
        try data.write(to: outfile)

        var synced = syncedGameTimes()
        var pending = pendingCloudDeletes()
        for gameTime in gameTimes {
            synced.remove(gameTime)
            pending.insert(gameTime)
        }
        saveSyncedGameTimes(synced)
        savePendingCloudDeletes(pending)
        Task {
            await flushPendingCloudDeletes()
        }
    }

    // MARK: - iCloud sync

    /// Kicks off a background sync with iCloud unless one is already running.
    func syncWithCloud() {
        guard syncTask == nil else { return }
        syncTask = Task {
            await performCloudSync()
            syncTask = nil
        }
    }

    private func performCloudSync() async {
        guard await cloudStore.accountAvailable() else { return }

        await flushPendingCloudDeletes()

        // Pull games recorded on other devices
        guard let cloudGames = try? await cloudStore.fetchAllGames() else { return }
        let pendingDeletes = pendingCloudDeletes()
        var synced = syncedGameTimes()
        var localGameTimes = Set(storage.map { $0.gameTime })
        var pulledNewGames = false
        for cloudGame in cloudGames {
            if pendingDeletes.contains(cloudGame.gameTime) || localGameTimes.contains(cloudGame.gameTime) {
                continue
            }
            storage.append(cloudGame)
            localGameTimes.insert(cloudGame.gameTime)
            synced.insert(cloudGame.gameTime)
            pulledNewGames = true
        }
        if pulledNewGames {
            storage.sort { $0.gameTime > $1.gameTime }
            if let data = try? JSONEncoder().encode(storage), let outfile = try? Self.fileURL() {
                try? data.write(to: outfile)
            }
        }
        saveSyncedGameTimes(synced)

        // Push local games that haven't reached iCloud yet, including the
        // pre-existing history the first time this runs
        let unsyncedGames = storage.filter { !synced.contains($0.gameTime) }
        if !unsyncedGames.isEmpty {
            let uploaded = await cloudStore.saveGames(unsyncedGames)
            markSynced(uploaded)
        }
    }

    private func pushToCloud(_ game: ShotsData) {
        markUnsynced(game.gameTime)
        Task {
            guard await cloudStore.accountAvailable() else { return }
            let uploaded = await cloudStore.saveGames([game])
            markSynced(uploaded)
        }
    }

    private func flushPendingCloudDeletes() async {
        var pending = pendingCloudDeletes()
        guard !pending.isEmpty else { return }
        guard await cloudStore.accountAvailable() else { return }
        for gameTime in pending {
            do {
                try await cloudStore.deleteGame(gameTime: gameTime)
                pending.remove(gameTime)
            }
            catch {}
        }
        savePendingCloudDeletes(pending)
    }

    // MARK: - Sync bookkeeping

    private func syncedGameTimes() -> Set<TimeInterval> {
        Set(UserDefaults.standard.array(forKey: GameStore.syncedGameTimesKey) as? [TimeInterval] ?? [])
    }

    private func saveSyncedGameTimes(_ gameTimes: Set<TimeInterval>) {
        UserDefaults.standard.set(Array(gameTimes), forKey: GameStore.syncedGameTimesKey)
    }

    private func markSynced(_ gameTimes: Set<TimeInterval>) {
        if gameTimes.isEmpty {
            return
        }
        saveSyncedGameTimes(syncedGameTimes().union(gameTimes))
    }

    private func markUnsynced(_ gameTime: TimeInterval) {
        var synced = syncedGameTimes()
        synced.remove(gameTime)
        saveSyncedGameTimes(synced)
    }

    private func pendingCloudDeletes() -> Set<TimeInterval> {
        Set(UserDefaults.standard.array(forKey: GameStore.pendingCloudDeletesKey) as? [TimeInterval] ?? [])
    }

    private func savePendingCloudDeletes(_ gameTimes: Set<TimeInterval>) {
        UserDefaults.standard.set(Array(gameTimes), forKey: GameStore.pendingCloudDeletesKey)
    }
}

extension Bundle {
    func decode(_ file: String) -> [ShotsData] {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode([ShotsData].self, from: data) else {
            fatalError("Failed to decode \(file) from bundle")
        }
        return loaded
    }
}
