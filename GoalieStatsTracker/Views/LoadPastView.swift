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
    @State var showAlert = true
    
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-run-an-asynchronous-task-when-a-view-is-shown
    
    var body: some View {
        NavigationStack {
            List($games) { $game in
                VStack(alignment: .leading) {
                    NavigationLink {
                        RecordStatsView(gameStore: _gameStore, shotsData: game)
                    } label: {
                        Text("\(game.gameName)\n\(Date.now.addingTimeInterval(600), style: .date)")
                            .swipeActions {
                                Button("Delete") {
                                    showAlert = true
                                }
                                .tint(Color.red)
                                alert(isPresented: $showAlert) {
                                    Alert(title: Text("Game deleted"))
                                }
                            }
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
