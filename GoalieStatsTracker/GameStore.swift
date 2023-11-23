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
    
    func load() async throws {
        let task = Task<[ShotsData], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return storage
            }
            let shotsData = try JSONDecoder().decode([ShotsData].self, from: data)
            return shotsData
        }
        let shots = try await task.value
        self.storage = shots
    }
    
    func save(game: ShotsData) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(game)
            let outfile = try GameStore.fileURL()
            try data.write(to: outfile)
            print(outfile)
        }
        _  = try await task.value
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
