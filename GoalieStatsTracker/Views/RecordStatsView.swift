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
    
    @EnvironmentObject var gameStore: GameStore
    
    @State private var runningScoreColor: Color = Color.black
    
    @State var pointsOn12Meter: [ShotsData.Shot] = []

    @State var isGoal: Bool = false
    @State var is8Meter: Bool = false
            
    @State var shotsData = ShotsData()

    init() {
    }

    init(gameStore: EnvironmentObject<GameStore>) {
        _gameStore = gameStore
        let ongoingGame = self.gameStore.ongoingGame
        if ongoingGame != nil {
            self._shotsData = State(initialValue: ongoingGame!)
            self._pointsOn12Meter = State(initialValue: ongoingGame!.shots)
        }
    }
    
    init(gameStore: EnvironmentObject<GameStore>, shotsData: ShotsData) {
        _gameStore = gameStore
        _shotsData = State(initialValue: shotsData)
        _pointsOn12Meter = State(initialValue: shotsData.shots)
        loadPastView = true
        disable = true
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    GameTitleView(parent: self, geometry: proxy)
                    ShotSelectorsView(parent: self, geometry: proxy)
                    FieldView(parent: self, geometry: proxy)
                    ScoringView(parent: self, geometry: proxy)
                    GameButtonsView(parent: self, geometry: proxy)
                }
                .disabled(disable)
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct RecordStatsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordStatsView()
    }
}
