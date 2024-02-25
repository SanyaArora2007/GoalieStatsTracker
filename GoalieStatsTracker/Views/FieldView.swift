//
//  FieldView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 1/16/24.
//

import Foundation
import SwiftUI

struct FieldView: View {
    
    var _parent: RecordStatsView
    
    let _geometry: GeometryProxy

    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
        _parent.shotsData.setFieldSize(width: _geometry.size.width)
    }
    
    var draw12MeterCircle: some Gesture {
        SpatialTapGesture()
            .onEnded() { event in
                let shot = _parent.shotsData.newShot(goal:_parent.isGoal, eightMeter:_parent.is8Meter, location:event.location)
                if shot != nil {
                    _parent.pointsOn12Meter.append(shot!)
                    Task {
                        do {
                            try await _parent.gameStore.saveOngoingGame(game: _parent.shotsData)
                        }
                        catch {
                            // don't report any errors because it will cause the app to crash in the middle of the game
                        }
                    }
                }
            }
    }
    
    var body: some View {
        
        Divider()
        
        ZStack {
            Image("12MeterDiagram")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
            ForEach(_parent.pointsOn12Meter, id: \.self) { shot in
                ClickedCircle(currentLocation: shot.coordinate, circleColor: circleColor(wasItAGoal: shot.wasItAGoal, wasItA8Meter: shot.wasItEightMeter), geometry: _geometry)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(Rectangle())
        .gesture(draw12MeterCircle)

        Divider()
    }
    
    func circleColor(wasItAGoal: Bool, wasItA8Meter: Bool) -> Color {
        if wasItAGoal == true {
            if wasItA8Meter == true {
                return Colors.color8MGoal
            }
            else {
                return Colors.colorGoal
            }
        }
        else {
            if wasItA8Meter == true {
                return Colors.color8MSave
            }
            else {
                return Colors.colorSave
            }
        }
    }
    
}
