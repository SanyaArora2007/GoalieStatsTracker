//
//  RecordStatsView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct RecordStatsView: View {
    
    @State private var color1 : Color = Color.gray
    @State private var color2 : Color = Color.gray
    @State private var color3 : Color = Color.gray
    @State private var color4 : Color = Color.gray


    
    var tapGoalGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    color1 = Color.red
                }
            }
    }
    
    var tapSaveGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    color2 = Color.red
                }
            }
    }
    
    var tapClearGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    color3 = Color.red
                }
            }
    }
    
    var tap8MeterGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    color4 = Color.red
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
                        .foregroundColor(color1)
                        .opacity(0.5)
                        .gesture(tapGoalGesture)
                    Text("Goal")
                        .font(.headline)
                }
                Spacer()
                ZStack {
                    Rectangle()
                        .frame(width: 80, height: 40)
                        .foregroundColor(color2)
                        .opacity(0.5)
                        .gesture(tapSaveGesture)
                    Text("Save")
                        .font(.headline)
                }
                Spacer()
                ZStack {
                    Rectangle()
                        .frame(width: 80, height: 40)
                        .foregroundColor(color3)
                        .opacity(0.5)
                        .gesture(tapClearGesture)
                    Text("Clear")
                        .font(.headline)
                }
                Spacer()
                ZStack {
                    Rectangle()
                        .frame(width: 80, height: 40)
                        .foregroundColor(color4)
                        .opacity(0.5)
                        .gesture(tap8MeterGesture)
                    Text("8 Meter")
                        .font(.headline)
                }
                Spacer()
            }
            
            Image("12MeterDiagram")
                .resizable()
                .frame( width: 480, height: 330)

            Divider()
            
            Image("laxGoal")
                .resizable()
                .frame(width: 300, height: 350)
        }
    }
}

struct RecordStatsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordStatsView()
    }
}
