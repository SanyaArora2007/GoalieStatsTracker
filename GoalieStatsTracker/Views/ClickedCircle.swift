//
//  ClickedCircle.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 1/15/24.
//

import SwiftUI

struct ClickedCircle: View {
    
    @State var currentLocation: CGPoint
    @State var circleColor: Color

    var body: some View {

        return Circle().fill(circleColor)
            .frame(width: 10, height: 10)
            .position(currentLocation)
    }
}
