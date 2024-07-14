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
    @State private var colorSaveButton : Color = Colors.colorNeutral
    @State private var color8MGoalButton : Color = Colors.colorNeutral
    @State private var color8MSaveButton : Color = Colors.colorNeutral
    
    @State private var fontGoalButton: Font.Weight = Font.Weight.regular
    @State private var fontSaveButton: Font.Weight = Font.Weight.regular
    @State private var font8MGoalButton: Font.Weight = Font.Weight.regular
    @State private var font8MSaveButton: Font.Weight = Font.Weight.regular
    
    var _parent: RecordStatsView
    let _geometry: GeometryProxy
    
    let buttonWidth: CGFloat = 0.05
    let buttonHeight: CGFloat = 0.05
    let textSize: CGFloat = 0.04
    let strokeWidth: CGFloat = 0.005
    
    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
        
        
        if _parent.loadPastView == true {
            _colorGoalButton = State(initialValue: Colors.colorGoal)
            _colorSaveButton = State(initialValue: Colors.colorSave)
            _color8MGoalButton = State(initialValue: Colors.color8MGoal)
            _color8MSaveButton = State(initialValue: Colors.color8MSave)
        }
        else {
            _colorSaveButton = State(initialValue: Colors.colorSave)
            
            _fontSaveButton = State(initialValue: Font.Weight.bold)
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
                fontGoalButton = Font.Weight.bold
                fontSaveButton = Font.Weight.regular
                font8MGoalButton = Font.Weight.regular
                font8MSaveButton = Font.Weight.regular
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
                fontGoalButton = Font.Weight.regular
                fontSaveButton = Font.Weight.bold
                font8MGoalButton = Font.Weight.regular
                font8MSaveButton = Font.Weight.regular
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
                fontGoalButton = Font.Weight.regular
                fontSaveButton = Font.Weight.regular
                font8MGoalButton = Font.Weight.bold
                font8MSaveButton = Font.Weight.regular
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
                fontGoalButton = Font.Weight.regular
                fontSaveButton = Font.Weight.regular
                font8MGoalButton = Font.Weight.regular
                font8MSaveButton = Font.Weight.bold
            }
    }
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Circle()
                    .strokeBorder(.black, lineWidth: _geometry.size.width * strokeWidth)
                    .background(Circle().fill(colorGoalButton))
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .opacity(0.5)
                    .gesture(tapGoalGesture)
                Text("Goal")
                    .font(.system(size: _geometry.size.width * textSize))
                    .fontWeight(fontGoalButton)
                    .gesture(tapGoalGesture)
                    .frame(width: _geometry.size.width * 0.12, alignment: .leading)
            }
            Spacer()
            HStack {
                Circle()
                    .strokeBorder(.black, lineWidth: _geometry.size.width * strokeWidth)
                    .background(Circle().fill(colorSaveButton))
                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                    .opacity(0.5)
                    .gesture(tapSaveGesture)
                Text("Save")
                    .font(.system(size: _geometry.size.width * textSize))
                    .fontWeight(fontSaveButton)
                    .gesture(tapSaveGesture)
                    .frame(width: _geometry.size.width * 0.12, alignment: .leading)
            }
            
            if _parent.womensField == true {
                Spacer()
                HStack {
                    Circle()
                        .strokeBorder(.black, lineWidth: _geometry.size.width * strokeWidth)
                        .background(Circle().fill(color8MGoalButton))
                        .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                        .opacity(0.5)
                        .gesture(tap8MeterGoalGesture)
                    Text("8M Goal")
                        .font(.system(size: _geometry.size.width * textSize))
                        .fontWeight(font8MGoalButton)
                        .gesture(tap8MeterGoalGesture)
                        .frame(width: _geometry.size.width * 0.17, alignment: .leading)
                }
                Spacer()
                HStack {
                    Circle()
                        .strokeBorder(.black, lineWidth: _geometry.size.width * strokeWidth)
                        .background(Circle().fill(color8MSaveButton))
                        .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                        .opacity(0.5)
                        .gesture(tap8MeterSaveGesture)
                    Text("8M Save")
                        .font(.system(size: _geometry.size.width * textSize))
                        .fontWeight(font8MSaveButton)
                        .gesture(tap8MeterSaveGesture)
                        .frame(width: _geometry.size.width * 0.17, alignment: .leading)
                }
            }
            Spacer()
        }
    }
}
