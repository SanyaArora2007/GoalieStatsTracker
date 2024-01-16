//
//  ShotSelectorsView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 1/15/24.
//

import SwiftUI
import Foundation

struct ShotSelectorsView: View {
    
    @State private var colorGoalButton : Color = Colors.colorNeutral
    @State private var colorSaveButton : Color = Colors.colorSave
    @State private var color8MGoalButton : Color = Colors.colorNeutral
    @State private var color8MSaveButton : Color = Colors.colorNeutral
    
    var _parent: RecordStatsView
    let _geometry: GeometryProxy
    
    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
    }
    
    var tapGoalGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = Colors.colorGoal
                    colorSaveButton = Colors.colorNeutral
                    color8MGoalButton = Colors.colorNeutral
                    color8MSaveButton = Colors.colorNeutral
                    
                    _parent.isGoal = true
                    _parent.is8Meter = false
                }
            }
    }
    
    var tapSaveGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = Colors.colorNeutral
                    colorSaveButton = Colors.colorSave
                    color8MGoalButton = Colors.colorNeutral
                    color8MSaveButton = Colors.colorNeutral
                    
                    _parent.isGoal = false
                    _parent.is8Meter = false
                }
            }
    }
    
    var tapClearGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = Colors.colorNeutral
                    colorSaveButton = Colors.colorNeutral
                    color8MGoalButton = Colors.color8MGoal
                    color8MSaveButton = Colors.colorNeutral
                    
                    _parent.isGoal = true
                    _parent.is8Meter = true
                }
            }
    }
    
    var tap8MeterGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = Colors.colorNeutral
                    colorSaveButton = Colors.colorNeutral
                    color8MGoalButton = Colors.colorNeutral
                    color8MSaveButton = Colors.color8MSave
                    
                    _parent.isGoal = false
                    _parent.is8Meter = true
                }
            }
    }
    
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Rectangle()
                    .frame(width: 80, height: 40)
                    .foregroundColor(colorGoalButton)
                    .opacity(0.5)
                    .gesture(tapGoalGesture)
                Text("Goal")
                    .font(.headline)
            }
            Spacer()
            ZStack {
                Rectangle()
                    .frame(width: 80, height: 40)
                    .foregroundColor(colorSaveButton)
                    .opacity(0.5)
                    .gesture(tapSaveGesture)
                Text("Save")
                    .font(.headline)
            }
            Spacer()
            ZStack {
                Rectangle()
                    .frame(width: 80, height: 40)
                    .foregroundColor(color8MGoalButton)
                    .opacity(0.5)
                    .gesture(tapClearGesture)
                Text("8M Goal")
                    .font(.headline)
            }
            Spacer()
            ZStack {
                Rectangle()
                    .frame(width: 80, height: 40)
                    .foregroundColor(color8MSaveButton)
                    .opacity(0.5)
                    .gesture(tap8MeterGesture)
                Text("8M Save")
                    .font(.headline)
            }
            Spacer()
        }

    }
}
