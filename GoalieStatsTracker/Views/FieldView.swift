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
    let _imageHeight: CGFloat

    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
        _imageHeight = _geometry.size.height * 0.45
        _parent.shotsData.setImageSize(imageWidth: _geometry.size.width, imageHeight: _imageHeight)
        print(_imageHeight)
    }
    
    var draw12MeterCircle: some Gesture {
        SpatialTapGesture()
            .onEnded() { event in
                if event.location.y > 0 && event.location.y < _imageHeight * 0.78 {
                    let shot = _parent.shotsData.newShot(goal:_parent.isGoal, eightMeter:_parent.is8Meter, location:event.location)
                    _parent.pointsOn12Meter.append(shot)
                    print("location \(event.location)")
                }
            }
    }
    
    var body: some View {
        
        Divider()
        
        ZStack {
            Image("12MeterDiagram")
                .resizable()
                .scaledToFit()
                .frame(height: _imageHeight)
            ForEach(_parent.pointsOn12Meter, id: \.self) { shot in
                ClickedCircle(currentLocation: shot.coordinate, circleColor: circleColor(wasItAGoal: shot.wasItAGoal, wasItA8Meter: shot.wasItEightMeter), geometry: _geometry)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(Rectangle())
        .gesture(draw12MeterCircle)

        Divider()

        Spacer().frame(height: _geometry.size.height * 0.05)
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
