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
    
    init(parent: RecordStatsView) {
        _parent = parent
    }
    
    var body: some View {
        TextField("Playing Against?", text: _parent.$shotsData.gameName)
            .multilineTextAlignment(.center)
            .font(.title)
            .foregroundStyle(Color.black)
    }
}
