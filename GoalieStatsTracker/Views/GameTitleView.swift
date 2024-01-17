//
//  GameTitleView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 1/16/24.
//

import Foundation
import SwiftUI

struct GameTitleView: View {

    var _parent: RecordStatsView
    let _geometry:GeometryProxy

    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
    }
    
    var body: some View {
        Spacer()
            .frame(height: _geometry.size.height * 0.05)

        TextField("Playing Against?", text: _parent.$shotsData.gameName)
            .multilineTextAlignment(.center)
            .font(.system(size: _geometry.size.height * 0.03))
            .foregroundStyle(Color.black)

        Spacer()
            .frame(height: _geometry.size.height * 0.05)
    }
}
