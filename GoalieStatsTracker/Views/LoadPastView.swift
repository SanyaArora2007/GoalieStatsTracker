//
//  LoadPastView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct LoadPastView: View {
    @EnvironmentObject var gameStore: GameStore

    @Environment(\.presentationMode) var presentationMode

    @State private var games: [ShotsData] = []

    @State private var popToSeasonsView: Bool = false

    private var seasonName: String? = nil

    private var dateFormat: DateFormatter = DateFormatter()

    init() {
        self.dateFormat.dateStyle = .long
        self.dateFormat.timeStyle = .none
    }

    init(seasonName: String) {
        self.init()
        self.seasonName = seasonName
    }

    private var title: String {
        guard let seasonName = seasonName else {
            return "Games"
        }
        return seasonName.isEmpty ? "No Season" : seasonName
    }
    
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-run-an-asynchronous-task-when-a-view-is-shown
    
    var body: some View {
        GeometryReader { proxy in
            List {
                ForEach(games, id: \.self) { game in
                    VStack(alignment: .leading) {
                        NavigationLink {
                            RecordStatsView(gameStore: _gameStore, shotsData: game, popToSeasonsView: $popToSeasonsView)
                        } label: {
                            HStack {
                                Image(game.womensField == true ? "WomanRunning" : "ManRunning")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: proxy.size.width * 0.1)
                                VStack {
                                    Text(game.gameName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: proxy.size.height * 0.02, weight: .semibold))
                                    Spacer()
                                        .frame(height: proxy.size.height * 0.0075)
                                    Text(dateFormat.string(from: Date(timeIntervalSince1970:game.gameTime)))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: proxy.size.height * 0.015, weight: .light))
                                    Spacer()
                                        .frame(height: proxy.size.height * 0.0075)
                                    Text(game.goalies.joined(separator: ", "))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: proxy.size.height * 0.015, weight: .light))
                                }
                            }
                        }
                        Divider()
                    }
                    .listRowSeparator(.hidden)
                }
                .onDelete { indexes in
                    Task {
                        await deleteGame(offsets: indexes)
                    }
                }
            }
            .navigationTitle(title)
            .onAppear {
                if popToSeasonsView == true {
                    popToSeasonsView = false
                    // wait for the pop animation from RecordStatsView to finish
                    // before popping again, or the second dismiss is ignored
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .task {
                do {
                    var loaded = try await gameStore.load()
                    if let seasonName = seasonName {
                        loaded = loaded.filter { $0.seasonName == seasonName }
                    }
                    games = loaded
                }
                catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteGame(offsets: IndexSet) async {
        do {
            let gamesToDelete = offsets.map { games[$0] }
            games.remove(atOffsets: offsets)
            let storageOffsets = IndexSet(
                gameStore.storage.enumerated()
                    .filter { gamesToDelete.contains($0.element) }
                    .map { $0.offset }
            )
            try await gameStore.remove(offsets: storageOffsets)
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
