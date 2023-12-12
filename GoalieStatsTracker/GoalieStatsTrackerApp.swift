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
        }
    }
}

//https://thenounproject.com/icon/lacrosse-helmet-1988089/
