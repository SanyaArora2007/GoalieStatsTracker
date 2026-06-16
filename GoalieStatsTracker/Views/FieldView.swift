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
                let shot = _parent.shotsData.newShot(goal:_parent.isGoal, eightMeter:_parent.is8Meter, location:event.location, goalieName: _parent.selectedGoalieName)
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
            Image(_parent.shotsData.womensField == true ? "12MeterDiagram" : "MensFieldDiagram")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
            ForEach(_parent.pointsOn12Meter.filter { $0.goalieName == _parent.selectedGoalieName }, id: \.self) { shot in
                ClickedCircle(currentLocation: _parent.shotsData.displayCoordinate(for: shot), circleColor: circleColor(wasItAGoal: shot.wasItAGoal, wasItA8Meter: shot.wasItEightMeter), geometry: _geometry)
            }
            if _parent.loadPastView == false {
                Button(
                    action: {
                        let goalie = _parent.selectedGoalieName
                        _parent.shotsData.removeLastShot(forGoalie: goalie)
                        if let idx = _parent.pointsOn12Meter.lastIndex(where: { $0.goalieName == goalie }) {
                            _parent.pointsOn12Meter.remove(at: idx)
                        }
                        Task {
                            do {
                                try await _parent.gameStore.saveOngoingGame(game: _parent.shotsData)
                            }
                            catch {
                                // don't report any errors because it will cause the app to crash in the middle of the game
                            }
                        }
                    },
                    label: {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .resizable()
                            .foregroundColor(Color.teal)
                            .scaledToFit()
                            .frame(width: _geometry.size.width * 0.08)
                            .opacity(0.75)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, _geometry.size.width * 0.04)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(Rectangle())
        .gesture(draw12MeterCircle)
        .onAppear {
            // fieldWidth was set in init, so a legacy game can now be upgraded
            // to normalized coordinates using this device's field width.
            _parent.migrateLegacyCoordinatesIfNeeded()
        }

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
