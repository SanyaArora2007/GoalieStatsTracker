//
//  LoadPastView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct LoadPastView: View {
    @EnvironmentObject var gameStore: GameStore
    @State private var games: [ShotsData] = []
    
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-run-an-asynchronous-task-when-a-view-is-shown
    
    var body: some View {
        NavigationStack {
            List($games) { game in
                VStack(alignment: .leading) {
                    NavigationLink {
                        RecordStatsView(gameStore: _gameStore)
                    } label: {
                        Text("Game 1")
                    }
                }
                .navigationTitle("Games")
            }
        }
        .task {
            do {
                try await games = gameStore.load()
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}



struct LoadPastView_Previews: PreviewProvider {
    static var previews: some View {
        LoadPastView()
    }
}
