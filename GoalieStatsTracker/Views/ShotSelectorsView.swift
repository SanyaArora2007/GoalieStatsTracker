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
    
    @State private var fontGoalButton: Font
    @State private var fontSaveButton: Font
    @State private var font8MGoalButton: Font
    @State private var font8MSaveButton: Font
    
    var _parent: RecordStatsView
    let _geometry: GeometryProxy
    
    let buttonWidth: CGFloat = 0.05
    let buttonHeight: CGFloat = 0.05
    let textSize: CGFloat = 0.04
    
    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
        
        
        if _parent.loadPastView == false {
            _colorGoalButton = State(initialValue: Colors.colorNeutral)
            _colorSaveButton = State(initialValue: Colors.colorSave)
            _color8MGoalButton = State(initialValue: Colors.colorNeutral)
            _color8MSaveButton = State(initialValue: Colors.colorNeutral)
            
            _fontGoalButton = State(initialValue: .system(size: _geometry.size.width * textSize, weight: .regular))
            _fontSaveButton = State(initialValue: .system(size: _geometry.size.width * textSize, weight: .bold))
            _font8MGoalButton = State(initialValue: .system(size: _geometry.size.width * textSize, weight: .regular))
            _font8MSaveButton = State(initialValue: .system(size: _geometry.size.width * textSize, weight: .regular))
        }
        else {
            _colorGoalButton = State(initialValue: Colors.colorGoal)
            _colorSaveButton = State(initialValue: Colors.colorSave)
            _color8MGoalButton = State(initialValue: Colors.color8MGoal)
            _color8MSaveButton = State(initialValue: Colors.color8MSave)
            
            _fontGoalButton = State(initialValue: .system(size: _geometry.size.width * textSize, weight: .regular))
            _fontSaveButton = State(initialValue: .system(size: _geometry.size.width * textSize, weight: .regular))
            _font8MGoalButton = State(initialValue: .system(size: _geometry.size.width * textSize, weight: .regular))
            _font8MSaveButton = State(initialValue: .system(size: _geometry.size.width * textSize, weight: .regular))        }
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
                fontGoalButton = Font.system(size: _geometry.size.width * textSize, weight: .bold)
                fontSaveButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
                font8MGoalButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
                font8MSaveButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
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
                fontGoalButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
                fontSaveButton = Font.system(size: _geometry.size.width * textSize, weight: .bold)
                font8MGoalButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
                font8MSaveButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
            }
    }
    
    var tap8MeterGoalGesture: some Gesture {
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
                fontGoalButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
                fontSaveButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
                font8MGoalButton = Font.system(size: _geometry.size.width * textSize, weight: .bold)
                font8MSaveButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
            }
    }
    
    var tap8MeterSaveGesture: some Gesture {
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
                fontGoalButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
                fontSaveButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
                font8MGoalButton = Font.system(size: _geometry.size.width * textSize, weight: .regular)
                font8MSaveButton = Font.system(size: _geometry.size.width * textSize, weight: .bold)
            }
    }
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Circle()
                    .strokeBorder(.black, lineWidth: _geometry.size.width * 0.005)
                    .background(Circle().fill(colorGoalButton))
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .opacity(0.5)
                    .gesture(tapGoalGesture)
                Text("Goal")
                    .font(fontGoalButton)
                    .gesture(tapGoalGesture)
                    .frame(width: _geometry.size.width * 0.12, alignment: .leading)
            }
            Spacer()
            HStack {
                Circle()
                    .strokeBorder(.black, lineWidth: _geometry.size.width * 0.005)
                    .background(Circle().fill(colorSaveButton))
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .opacity(0.5)
                    .gesture(tapSaveGesture)
                Text("Save")
                    .font(fontSaveButton)
                    .gesture(tapSaveGesture)
                    .frame(width: _geometry.size.width * 0.12, alignment: .leading)
            }
            Spacer()
            HStack {
                Circle()
                    .strokeBorder(.black, lineWidth: _geometry.size.width * 0.005)
                    .background(Circle().fill(color8MGoalButton))
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .opacity(0.5)
                    .gesture(tap8MeterGoalGesture)
                Text("8M Goal")
                    .font(font8MGoalButton)
                    .gesture(tap8MeterGoalGesture)
                    .frame(width: _geometry.size.width * 0.17, alignment: .leading)
            }
            Spacer()
            HStack {
                Circle()
                    .strokeBorder(.black, lineWidth: _geometry.size.width * 0.005)
                    .background(Circle().fill(color8MSaveButton))
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .opacity(0.5)
                    .gesture(tap8MeterSaveGesture)
                Text("8M Save")
                    .font(font8MSaveButton)
                    .gesture(tap8MeterSaveGesture)
                    .frame(width: _geometry.size.width * 0.17, alignment: .leading)
            }
            Spacer()
        }

    }
}
