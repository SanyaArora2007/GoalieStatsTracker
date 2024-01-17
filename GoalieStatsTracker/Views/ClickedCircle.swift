//
//  ClickedCircle.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 1/15/24.
//

import SwiftUI

struct ClickedCircle: View {
    var _currentLocation: CGPoint
    var _circleColor: Color
    let _geometry: GeometryProxy

    init(currentLocation: CGPoint, circleColor: Color, geometry: GeometryProxy) {
        _currentLocation = currentLocation
        _circleColor = circleColor
        _geometry = geometry
    }

    var body: some View {

        return Circle().fill(_circleColor)
            .frame(width: _geometry.size.width*0.02, height: _geometry.size.width*0.02)
            .position(_currentLocation)
    }
}
