//
//  ShotSelectorsView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 1/15/24.
//

import SwiftUI
import Foundation

struct ShotSelectorsView: View {
    
    @State private var colorGoalButton : Color
    @State private var colorSaveButton : Color
    @State private var color8MGoalButton : Color
    @State private var color8MSaveButton : Color
    
    var _parent: RecordStatsView
    let _geometry: GeometryProxy
    
    let buttonWidth: CGFloat = 0.20
    let buttonHeight: CGFloat = 0.05
    let textSize: CGFloat = 0.02
    
    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
        
        
        if _parent.loadPastView == false {
            _colorGoalButton = State(initialValue: Colors.colorNeutral)
            _colorSaveButton = State(initialValue: Colors.colorSave)
            _color8MGoalButton = State(initialValue: Colors.colorNeutral)
            _color8MSaveButton = State(initialValue: Colors.colorNeutral)
        }
        else {
            _colorGoalButton = State(initialValue: Colors.colorGoal)
            _colorSaveButton = State(initialValue: Colors.colorSave)
            _color8MGoalButton = State(initialValue: Colors.color8MGoal)
            _color8MSaveButton = State(initialValue: Colors.color8MSave)
        }
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
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .foregroundColor(colorGoalButton)
                    .opacity(0.5)
                    .gesture(tapGoalGesture)
                Text("Goal")
                    .font(.system(size: _geometry.size.height * textSize))
            }
            Spacer()
            ZStack {
                Rectangle()
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .foregroundColor(colorSaveButton)
                    .opacity(0.5)
                    .gesture(tapSaveGesture)
                Text("Save")
                    .font(.system(size: _geometry.size.height * textSize))
            }
            Spacer()
            ZStack {
                Rectangle()
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .foregroundColor(color8MGoalButton)
                    .opacity(0.5)
                    .gesture(tapClearGesture)
                Text("8M Goal")
                    .font(.system(size: _geometry.size.height * textSize))
            }
            Spacer()
            ZStack {
                Rectangle()
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .foregroundColor(color8MSaveButton)
                    .opacity(0.5)
                    .gesture(tap8MeterGesture)
                Text("8M Save")
                    .font(.system(size: _geometry.size.height * textSize))
            }
            Spacer()
        }

    }
}
