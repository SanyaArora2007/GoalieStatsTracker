//
//  RecordStatsView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct RecordStatsView: View {
    
    static let colorGoal = Color.red
    static let colorSave = Color.green
    static let colorClear = Color.blue
    static let color8Meter = Color.orange
    static let colorNeutral = Color.gray
    
    @State private var colorGoalButton : Color = colorNeutral
    @State private var colorSaveButton : Color = colorNeutral
    @State private var colorClearButton : Color = colorNeutral
    @State private var color8MeterButton : Color = colorNeutral
    
    @State var pointsOn12Meter: [CGPoint] = []
    @State var pointsOnGoal: [CGPoint] = []
    
    var draw12MeterCircle: some Gesture {
        SpatialTapGesture()
            .onEnded() { event in
                pointsOn12Meter.append(event.location)
            }
    }
    
    var drawGoalCircle: some Gesture {
        SpatialTapGesture()
            .onEnded() { event in
                pointsOnGoal.append(event.location)
            }
    }

    
    var tapGoalGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = RecordStatsView.colorGoal
                    colorSaveButton = RecordStatsView.colorNeutral
                    colorClearButton = RecordStatsView.colorNeutral
                    color8MeterButton = RecordStatsView.colorNeutral
                }
            }
    }
    
    var tapSaveGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = RecordStatsView.colorNeutral
                    colorSaveButton = RecordStatsView.colorSave
                    colorClearButton = RecordStatsView.colorNeutral
                    color8MeterButton = RecordStatsView.colorNeutral
                }
            }
    }
    
    var tapClearGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = RecordStatsView.colorNeutral
                    colorSaveButton = RecordStatsView.colorNeutral
                    colorClearButton = RecordStatsView.colorClear
                    color8MeterButton = RecordStatsView.colorNeutral
                }
            }
    }
    
    var tap8MeterGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = RecordStatsView.colorNeutral
                    colorSaveButton = RecordStatsView.colorNeutral
                    colorClearButton = RecordStatsView.colorNeutral
                    color8MeterButton = RecordStatsView.color8Meter
                }
            }
    }
    
    var body: some View {
        VStack {
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
                        .foregroundColor(colorClearButton)
                        .opacity(0.5)
                        .gesture(tapClearGesture)
                    Text("Clear")
                        .font(.headline)
                }
                Spacer()
                ZStack {
                    Rectangle()
                        .frame(width: 80, height: 40)
                        .foregroundColor(color8MeterButton)
                        .opacity(0.5)
                        .gesture(tap8MeterGesture)
                    Text("8 Meter")
                        .font(.headline)
                }
                Spacer()
            }
            
            ZStack {
                Image("12MeterDiagram")
                    .resizable()
                    .frame( width: 480, height: 330)
                
                ForEach(pointsOn12Meter, id: \.x) { point in
                    ClickedCircle(currentLocation: point)
                }
            }
            .contentShape(Rectangle())
            .gesture(draw12MeterCircle)
            
            Divider()
            
            ZStack {
                Image("laxGoal")
                    .resizable()
                    .frame(width: 300, height: 350)
                
                ForEach(pointsOnGoal, id: \.x) { point in
                    ClickedCircle(currentLocation: point)
                }
            }
            .contentShape(Rectangle())
            .gesture(drawGoalCircle)
            
        }
    }
}

struct ClickedCircle: View {
    

    @State var currentLocation: CGPoint
    
    var body: some View {

        return Circle().fill(Color.red)
            .frame(width: 20, height: 20)
            .position(currentLocation)
    }
}

struct RecordStatsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordStatsView()
    }
}
