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
    private static let seasonOrderKey = "GameStore.seasonOrder"
    private static let seasonsNeedsPushKey = "GameStore.seasonsNeedsPush"
    // The season list as it last stood in iCloud. Acts as the common ancestor
    // for a three-way merge so deletions can be told apart from additions.
    private static let seasonsBaselineKey = "GameStore.seasonsBaseline"

    // The user-controlled ordering of seasons. This is the source of truth for
    // order and lets seasons exist before any game references them; names found
    // on games but missing here are appended by `seasons`.
    @Published private var seasonOrder: [String] =
        UserDefaults.standard.stringArray(forKey: GameStore.seasonOrderKey)
        ?? UserDefaults.standard.stringArray(forKey: "GameStore.createdSeasons")
        ?? []

    var seasons: [String] {
        var result: [String] = seasonOrder
        for game in storage {
            let name = game.seasonName
            if name.isEmpty == false && result.contains(name) == false {
                result.append(name)
            }
        }
        return result
    }

    func addSeason(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard trimmed.isEmpty == false, seasons.contains(trimmed) == false else { return }
        seasonOrder.append(trimmed)
        persistSeasonOrder()
        markSeasonsNeedsPush()
        pushSeasonsToCloud()
    }

    func moveSeason(fromOffsets source: IndexSet, toOffset destination: Int) {
        var list = seasons
        list.move(fromOffsets: source, toOffset: destination)
        seasonOrder = list
        persistSeasonOrder()
        markSeasonsNeedsPush()
        pushSeasonsToCloud()
    }

    private func persistSeasonOrder() {
        UserDefaults.standard.set(seasonOrder, forKey: GameStore.seasonOrderKey)
    }

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

    func removeSeason(named seasonName: String) async throws {
        if let index = seasonOrder.firstIndex(of: seasonName) {
            seasonOrder.remove(at: index)
            persistSeasonOrder()
            markSeasonsNeedsPush()
            pushSeasonsToCloud()
        }
        let affectedGameTimes = storage
            .filter { $0.seasonName == seasonName }
            .map { $0.gameTime }
        let task = Task {
            objectWillChange.send()
            for game in storage {
                if game.seasonName == seasonName {
                    game.seasonName = ""
                }
            }
            let data = try JSONEncoder().encode(storage)
            let outfile = try GameStore.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
        for gameTime in affectedGameTimes {
            markUnsynced(gameTime)
        }
        syncWithCloud()
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

        await syncSeasons()

        // Pull games recorded or edited on other devices
        guard let cloudGames = try? await cloudStore.fetchAllGames() else { return }
        let pendingDeletes = pendingCloudDeletes()
        var synced = syncedGameTimes()
        var indexByGameTime: [TimeInterval: Int] = [:]
        for (index, game) in storage.enumerated() {
            indexByGameTime[game.gameTime] = index
        }
        var storageChanged = false
        for cloudGame in cloudGames {
            if pendingDeletes.contains(cloudGame.gameTime) {
                continue
            }
            if let index = indexByGameTime[cloudGame.gameTime] {
                // Game already on this device. Adopt the cloud copy only when the
                // local copy is clean (in the synced set). A game with unpushed
                // local edits isn't in the synced set, so we keep it and let its
                // own push overwrite the cloud record.
                if synced.contains(cloudGame.gameTime) {
                    storage[index] = cloudGame
                    storageChanged = true
                }
                continue
            }
            storage.append(cloudGame)
            synced.insert(cloudGame.gameTime)
            storageChanged = true
        }

        // Reconcile deletions made on other devices: a game we previously synced
        // that is now absent from the cloud was deleted elsewhere. Confirm each
        // one with a strongly-consistent fetch before removing it locally, so a
        // record that's merely lagging the query index isn't wrongly dropped.
        let cloudGameTimes = Set(cloudGames.map { $0.gameTime })
        let deletionCandidates = storage.filter {
            synced.contains($0.gameTime)
                && cloudGameTimes.contains($0.gameTime) == false
                && pendingDeletes.contains($0.gameTime) == false
        }
        var remotelyDeleted: Set<TimeInterval> = []
        for game in deletionCandidates {
            if let stillExists = try? await cloudStore.gameExists(gameTime: game.gameTime),
               stillExists == false {
                remotelyDeleted.insert(game.gameTime)
            }
        }
        if remotelyDeleted.isEmpty == false {
            storage.removeAll { remotelyDeleted.contains($0.gameTime) }
            for gameTime in remotelyDeleted {
                synced.remove(gameTime)
            }
            storageChanged = true
        }

        if storageChanged {
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

    private func pushSeasonsToCloud() {
        Task {
            guard await cloudStore.accountAvailable() else { return }
            if await cloudStore.saveSeasons(seasons) {
                clearSeasonsNeedsPush()
            }
        }
    }

    /// Reconciles the explicit season ordering with iCloud using a three-way
    /// merge against the last-synced baseline, so a season deleted on one device
    /// is removed everywhere instead of being resurrected by a plain union.
    /// `seasonOrder` (not the derived `seasons`) is the unit of sync; seasons
    /// that exist only because a game references them stay a local concern.
    private func syncSeasons() async {
        let cloudSeasons = (try? await cloudStore.fetchSeasons()) ?? nil
        let localSeasons = seasonOrder

        guard let cloudSeasons = cloudSeasons else {
            // No cloud record yet; seed it from whatever this device has,
            // including game-derived names so nothing is lost on first sync.
            let seed = seasons
            if seed.isEmpty == false, await cloudStore.saveSeasons(seed) {
                clearSeasonsNeedsPush()
                saveSeasonsBaseline(seed)
            }
            return
        }

        let preferLocalOrder = seasonsNeedsPush()
        let merged: [String]
        if let baseline = seasonsBaseline() {
            merged = threeWayMergeSeasons(
                baseline: baseline,
                local: localSeasons,
                cloud: cloudSeasons,
                preferLocalOrder: preferLocalOrder
            )
        }
        else {
            // No baseline yet (first sync after upgrade): fall back to a union so
            // we don't misread pre-existing seasons as deletions, then record a
            // baseline for next time.
            merged = preferLocalOrder
                ? mergeSeasons(primary: localSeasons, secondary: cloudSeasons)
                : mergeSeasons(primary: cloudSeasons, secondary: localSeasons)
        }

        if merged != seasonOrder {
            seasonOrder = merged
            persistSeasonOrder()
        }

        if merged != cloudSeasons {
            if await cloudStore.saveSeasons(merged) {
                clearSeasonsNeedsPush()
                saveSeasonsBaseline(merged)
            }
        }
        else {
            clearSeasonsNeedsPush()
            saveSeasonsBaseline(merged)
        }
    }

    /// Three-way merge of season lists. An entry present in the baseline is kept
    /// only if it still survives on both sides; missing on either side means it
    /// was deleted there. Entries absent from the baseline are additions and are
    /// always kept. Order follows the side with pending changes.
    private func threeWayMergeSeasons(baseline: [String], local: [String], cloud: [String], preferLocalOrder: Bool) -> [String] {
        let baselineSet = Set(baseline)
        let localSet = Set(local)
        let cloudSet = Set(cloud)

        func keep(_ season: String) -> Bool {
            if baselineSet.contains(season) {
                return localSet.contains(season) && cloudSet.contains(season)
            }
            return true
        }

        let primary = preferLocalOrder ? local : cloud
        let secondary = preferLocalOrder ? cloud : local
        var result: [String] = []
        var seen: Set<String> = []
        for season in primary + secondary where keep(season) && seen.insert(season).inserted {
            result.append(season)
        }
        return result
    }

    /// Returns `primary` followed by any seasons that appear only in `secondary`.
    private func mergeSeasons(primary: [String], secondary: [String]) -> [String] {
        var result = primary
        for season in secondary where result.contains(season) == false {
            result.append(season)
        }
        return result
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

    private func seasonsNeedsPush() -> Bool {
        UserDefaults.standard.bool(forKey: GameStore.seasonsNeedsPushKey)
    }

    private func markSeasonsNeedsPush() {
        UserDefaults.standard.set(true, forKey: GameStore.seasonsNeedsPushKey)
    }

    private func clearSeasonsNeedsPush() {
        UserDefaults.standard.set(false, forKey: GameStore.seasonsNeedsPushKey)
    }

    private func seasonsBaseline() -> [String]? {
        UserDefaults.standard.stringArray(forKey: GameStore.seasonsBaselineKey)
    }

    private func saveSeasonsBaseline(_ seasons: [String]) {
        UserDefaults.standard.set(seasons, forKey: GameStore.seasonsBaselineKey)
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
