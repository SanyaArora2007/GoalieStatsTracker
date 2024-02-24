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
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            storage = try JSONDecoder().decode([ShotsData].self, from: data)
            return storage
        }
        let games = try await task.value
        return games
    }
    
    func save(game: ShotsData) async throws {
        let task = Task {
            try await discardOngoingGame()
            storage.insert(game, at: 0)
            let data = try JSONEncoder().encode(storage)
            let outfile = try GameStore.fileURL()
            try data.write(to: outfile)
        }
        _  = try await task.value
    }
    
    func saveOngoingGame(game: ShotsData) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(game)
            let outfile = try GameStore.ongoingGameFileURL()
            try data.write(to: outfile)
        }
        _  = try await task.value
    }				

    func discardOngoingGame()  async throws {
        let task = Task {
            do {
                try FileManager.default.removeItem(at: GameStore.ongoingGameFileURL())
            } catch {}
        }
        _  = await task.value
    }

    func remove(offsets: IndexSet) async throws {
        let task = Task {
            storage.remove(atOffsets: offsets)
            let data = try JSONEncoder().encode(storage)
            let outfile = try GameStore.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
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
