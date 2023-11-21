//
//  GoalieStatsTrackerApp.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

@main
struct GoalieStatsTrackerApp: App {
    @StateObject private var store = GameStore()
    
    var body: some Scene {
        WindowGroup() {
            ContentView()
                .environmentObject(store)
            
            
            
            //                Task {
            //                    do {
            //                        try await store.save(storage: store.storage)
            //                    } catch {
            //                        fatalError(error.localizedDescription)
            //                    }
            //                }
            //            }
            //            .task {
            //                do {
            //                    try await store.load()
            //                } catch {
            //                    fatalError(error.localizedDescription)
            //                }
            //            }
            //            .environmentObject(store)
            //        }
        }
    }
}
