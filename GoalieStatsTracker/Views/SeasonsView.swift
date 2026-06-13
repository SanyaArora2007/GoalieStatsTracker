//
//  SeasonsView.swift
//  GoalieStatsTracker
//

import Foundation
import SwiftUI

struct SeasonsView: View {

    struct GoalieSeasonStat {
        let goalieName: String
        let savePercentage: Int
    }

    @EnvironmentObject var gameStore: GameStore

    @State private var showNewSeasonAlert = false
    @State private var newSeasonName = ""

    var body: some View {
        GeometryReader { proxy in
            List {
                Button {
                    newSeasonName = ""
                    showNewSeasonAlert = true
                } label: {
                    Label("Create New Season", systemImage: "plus.circle.fill")
                        .font(.system(size: proxy.size.height * 0.02, weight: .semibold))
                        .foregroundStyle(.teal)
                }
                ForEach(gameStore.seasons, id: \.self) { season in
                    NavigationLink {
                        LoadPastView(seasonName: season)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(season)
                                .font(.system(size: proxy.size.height * 0.02, weight: .semibold))
                            ForEach(savePercentages(forSeason: season), id: \.goalieName) { stat in
                                Spacer()
                                    .frame(height: proxy.size.height * 0.0075)
                                Text("\(stat.goalieName): \(stat.savePercentage)%")
                                    .font(.system(size: proxy.size.height * 0.0175, weight: .light))
                            }
                        }
                    }
                }
                .onDelete { indexes in
                    Task {
                        await deleteSeason(offsets: indexes)
                    }
                }
                if gameStore.storage.contains(where: { $0.seasonName.isEmpty }) {
                    NavigationLink {
                        LoadPastView(seasonName: "")
                    } label: {
                        Text("No Season")
                            .font(.system(size: proxy.size.height * 0.02, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Seasons")
            .alert("Create New Season", isPresented: $showNewSeasonAlert) {
                TextField("Season name", text: $newSeasonName)
                Button("Cancel", role: .cancel) {}
                Button("Create") {
                    gameStore.addSeason(named: newSeasonName)
                }
            } message: {
                Text("Enter a name for the new season")
            }
        }
        .task {
            do {
                let _ = try await gameStore.load()
            }
            catch {}
        }
    }

    func savePercentages(forSeason season: String) -> [GoalieSeasonStat] {
        let seasonGames = gameStore.storage.filter { $0.seasonName == season }

        var goalieNames: [String] = []
        for game in seasonGames {
            for shot in game.shots {
                if goalieNames.contains(shot.goalieName) == false {
                    goalieNames.append(shot.goalieName)
                }
            }
        }

        return goalieNames.map { goalie in
            let percentages = seasonGames
                .filter { $0.totalShots(forGoalie: goalie) > 0 }
                .map { $0.savePercentage(forGoalie: goalie) }
            let average = percentages.reduce(0, +) / percentages.count
            return GoalieSeasonStat(goalieName: goalie, savePercentage: average)
        }
    }

    func deleteSeason(offsets: IndexSet) async {
        do {
            let seasonsToDelete = offsets.map { gameStore.seasons[$0] }
            for season in seasonsToDelete {
                try await gameStore.removeSeason(named: season)
            }
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct SeasonsView_Previews: PreviewProvider {
    static var previews: some View {
        SeasonsView()
    }
}
