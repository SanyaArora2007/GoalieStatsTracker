//
//  StoreGame.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 11/7/23.
//

import SwiftUI

@MainActor
class StoreGame: ObservableObject {
    @Published var storage: [ShotsData] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("GoalieStatsTracker")
    }
    
    func load() async throws {
        let task = Task<[ShotsData], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let shotsData = try JSONDecoder().decode([ShotsData].self, from: data)
            return shotsData
        }
        let shots = try await task.value
        self.storage = shots
    }
}
