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
            
    @StateObject var shotsData = ShotsData()

    
    init() {
    }

    init(gameStore: EnvironmentObject<GameStore>) {
        _gameStore = gameStore
    }
    
    init(gameStore: EnvironmentObject<GameStore>, shotsData: ShotsData) {
        _gameStore = gameStore
        _shotsData = StateObject(wrappedValue: shotsData)
        _pointsOn12Meter = State(initialValue: shotsData.shots)
        loadPastView = true
        disable = true
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                GameTitleView(parent: self)
                ShotSelectorsView(parent: self)
                FieldView(parent: self)
                ScoringView(parent: self)
                GameButtonsView(parent: self)
            }
            .disabled(disable)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct RecordStatsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordStatsView()
    }
}
