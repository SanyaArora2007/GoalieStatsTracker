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
    
    private var dateFormat: DateFormatter = DateFormatter()
    
    init() {
        self.dateFormat.dateStyle = .long
        self.dateFormat.timeStyle = .short
    }
    
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-run-an-asynchronous-task-when-a-view-is-shown
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                List {
                    ForEach(games, id: \.self) { game in
                        VStack(alignment: .leading) {
                            NavigationLink {
                                RecordStatsView(gameStore: _gameStore, shotsData: game)
                            } label: {
                                VStack {
                                    Text(game.gameName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: proxy.size.height * 0.02, weight: .semibold))
                                    Spacer()
                                        .frame(height: proxy.size.height * 0.0075)
                                    Text(dateFormat.string(from: Date(timeIntervalSince1970:game.gameTime)))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: proxy.size.height * 0.015, weight: .light))
                                }
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
