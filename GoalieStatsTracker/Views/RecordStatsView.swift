//
//  RecordStatsView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct RecordStatsView: View {
    
    var loadPastView: Bool = false
    var disable: Bool = false
    var popToSeasonsView: Binding<Bool>? = nil
    
    @EnvironmentObject var gameStore: GameStore

    @Environment(\.presentationMode) var presentationMode

    @State private var runningScoreColor: Color = Color.black

    @State var showSavePopup: Bool = false

    @State private var showAddSeasonPopup: Bool = false

    @State private var showChangeSeasonPopup: Bool = false

    // shotsData is a class held in @State, so mutating its seasonName alone
    // does not re-render this view; this gets toggled to force the refresh
    @State private var seasonAssignmentRefresh: Bool = false
    
    @State var pointsOn12Meter: [ShotsData.Shot] = []

    @State var isGoal: Bool = false
    @State var is8Meter: Bool = false
            
    @State var shotsData = ShotsData()

    @State var selectedGoalieName: String = ShotsData.defaultGoalieName

    init() {
    }

    init(gameStore: EnvironmentObject<GameStore>, isWomensField: Bool) {
        _gameStore = gameStore
        let ongoingGame = self.gameStore.ongoingGame
        self.shotsData.womensField = isWomensField
        if ongoingGame != nil {
            self._shotsData = State(initialValue: ongoingGame!)
            self._pointsOn12Meter = State(initialValue: ongoingGame!.shots)
            self._selectedGoalieName = State(initialValue: ongoingGame!.goalies.first ?? ShotsData.defaultGoalieName)
        }
    }
    
    init(gameStore: EnvironmentObject<GameStore>, shotsData: ShotsData, popToSeasonsView: Binding<Bool>? = nil) {
        _gameStore = gameStore
        _shotsData = State(initialValue: shotsData)
        _pointsOn12Meter = State(initialValue: shotsData.shots)
        _selectedGoalieName = State(initialValue: shotsData.goalies.first ?? ShotsData.defaultGoalieName)
        loadPastView = true
        disable = true
        self.popToSeasonsView = popToSeasonsView
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ScrollView(.vertical) {
                    VStack {
                        GameTitleView(parent: self, geometry: proxy)
                        GoalieSelectorView(
                            shotsData: shotsData,
                            selectedGoalieName: $selectedGoalieName,
                            disableAddingGoalie: loadPastView,
                            onGoaliesChanged: persistGoalieChange
                        )
                        VStack {
                            ShotSelectorsView(parent: self, geometry: proxy)
                            FieldView(parent: self, geometry: proxy)
                            ScoringView(parent: self, geometry: proxy)
                            GameButtonsView(parent: self, geometry: proxy)
                        }
                        .disabled(disable)

                        if loadPastView == true && shotsData.seasonName.isEmpty {
                            Spacer()
                                .frame(height: proxy.size.height * 0.02)
                            Button {
                                showAddSeasonPopup = true
                            } label: {
                                Text("Add Game to Season")
                                    .foregroundStyle(.teal)
                                    .font(.system(size: proxy.size.height * 0.0225))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: proxy.size.width * 0.02)
                                            .stroke(Color.gray, lineWidth: proxy.size.height * 0.004)
                                            .frame(width: proxy.size.width * 0.45, height: proxy.size.height * 0.045)
                                    )
                            }
                            Spacer()
                                .frame(height: proxy.size.height * 0.02)
                        } else if loadPastView == true && shotsData.seasonName.isEmpty == false && gameStore.seasons.isEmpty == false {
                            Spacer()
                                .frame(height: proxy.size.height * 0.02)
                            Button {
                                showChangeSeasonPopup = true
                            } label: {
                                Text("Change Season")
                                    .foregroundStyle(.teal)
                                    .font(.system(size: proxy.size.height * 0.0225))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: proxy.size.width * 0.02)
                                            .stroke(Color.gray, lineWidth: proxy.size.height * 0.004)
                                            .frame(width: proxy.size.width * 0.45, height: proxy.size.height * 0.045)
                                    )
                            }
                            Spacer()
                                .frame(height: proxy.size.height * 0.02)
                        }
                    }
                    .navigationBarBackButtonHidden(loadPastView == false)
                }
            }

            if showSavePopup {
                SaveGamePopupView(seasons: gameStore.seasons) { seasonName in
                    showSavePopup = false
                    shotsData.seasonName = seasonName
                    let game = shotsData
                    Task {
                        do {
                            try await gameStore.save(game: game)
                        }
                        catch {
                            fatalError(error.localizedDescription)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }

            if showAddSeasonPopup {
                SaveGamePopupView(
                    seasons: gameStore.seasons,
                    title: "Add Game to Season",
                    subtitle: "Pick a season for this game",
                    confirmButtonTitle: "Done"
                ) { seasonName in
                    showAddSeasonPopup = false
                    if seasonName.isEmpty == false {
                        addGameToSeason(seasonName)
                    }
                }
            }

            if showChangeSeasonPopup {
                SaveGamePopupView(
                    seasons: gameStore.seasons,
                    title: "Change Season",
                    subtitle: "Pick a season for this game",
                    confirmButtonTitle: "Done"
                ) { seasonName in
                    showChangeSeasonPopup = false
                    if seasonName.isEmpty == false {
                        addGameToSeason(seasonName)
                    }
                }
            }
        }
    }

    func addGameToSeason(_ seasonName: String) {
        shotsData.seasonName = seasonName
        seasonAssignmentRefresh.toggle()
        let game = shotsData
        Task {
            do {
                try await gameStore.update(game: game)
            }
            catch {
                // don't surface errors when assigning a season
            }
            popToSeasonsView?.wrappedValue = true
            presentationMode.wrappedValue.dismiss()
        }
    }

    func persistGoalieChange() {
        pointsOn12Meter = shotsData.shots
        let game = shotsData
        let isPastGame = loadPastView
        Task {
            do {
                if isPastGame {
                    try await gameStore.update(game: game)
                } else {
                    try await gameStore.saveOngoingGame(game: game)
                }
            }
            catch {
                // don't surface errors mid-game
            }
        }
    }
}

struct RecordStatsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordStatsView()
    }
}
