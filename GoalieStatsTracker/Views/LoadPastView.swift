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
            List {
                ForEach(games, id: \.self) { game in
                    VStack(alignment: .leading) {
                        NavigationLink {
                            RecordStatsView(gameStore: _gameStore, shotsData: game)
                        } label: {
                            Text("\(game.gameName)\n\(Date.now.addingTimeInterval(600), style: .date)")
                        }
                    }
                }
                .onDelete { indexes in
                    Task {
                        await deleteGame(offsets: indexes)
                    }
                }
            }
            .navigationTitle("Games")

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
    
    func deleteGame(offsets: IndexSet) async {
        do {
            games.remove(atOffsets: offsets)
            try await gameStore.remove(offsets: offsets)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}



struct LoadPastView_Previews: PreviewProvider {
    static var previews: some View {
        LoadPastView()
    }
}
