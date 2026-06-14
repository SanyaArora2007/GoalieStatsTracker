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

    @State private var showNewSeasonPopup = false
    @State private var newSeasonName = ""

    var body: some View {
        ZStack {
            GeometryReader { proxy in
            List {
                Button {
                    newSeasonName = ""
                    showNewSeasonPopup = true
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
                .onMove { source, destination in
                    gameStore.moveSeason(fromOffsets: source, toOffset: destination)
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
            .toolbar {
                EditButton()
            }
            }

            if showNewSeasonPopup {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            Text("Create New Season")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            Text("Enter a name for the new season")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            TextField("Season name", text: $newSeasonName)
                                .textFieldStyle(.roundedBorder)
                                .foregroundColor(.teal)
                                .padding(.top, 8)
                        }
                        .padding()

                        Divider()

                        HStack(spacing: 0) {
                            Button(role: .cancel) {
                                showNewSeasonPopup = false
                            } label: {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            Divider()
                                .frame(height: 44)
                            Button {
                                let name = newSeasonName.trimmingCharacters(in: .whitespaces)
                                showNewSeasonPopup = false
                                if name.isEmpty == false {
                                    gameStore.addSeason(named: name)
                                }
                            } label: {
                                Text("Create")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                    .frame(maxWidth: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(UIColor.systemBackground))
                    )
                    .padding(40)
                }
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
