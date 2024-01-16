//
//  ScoringView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 1/16/24.
//

import Foundation
import SwiftUI

struct ScoringView: View {
    
    var _parent: RecordStatsView
    
    init(parent: RecordStatsView) {
        _parent = parent
    }
    
    var body: some View {
        VStack {
            if _parent.shotsData.runningScore < 0 {
                Text(String(format: "Running Score: %.1f", _parent.shotsData.runningScore))
                    .foregroundColor(Color.red)
                .font(Font.title)                }
            else if _parent.shotsData.runningScore > 0 {
                Text(String(format: "Running Score: %.1f", _parent.shotsData.runningScore))
                    .foregroundColor(Color.blue)
                .font(Font.title)                }
            else if _parent.shotsData.runningScore == 0 {
                Text(String(format: "Running Score: %.1f", _parent.shotsData.runningScore))
                    .foregroundColor(Color.black)
                    .font(Font.title)
            }
            
            Text("Saves: \(_parent.shotsData.saves)   (\(_parent.shotsData.savePercentage)%)")
                .foregroundColor(Color.black)
                .font(Font.headline)
                .frame(alignment: .trailing)
            
            Text("Total Shots: \(_parent.shotsData.totalShots)")
                .foregroundColor(Color.black)
                .font(Font.headline)
                .frame(alignment: .trailing)
        }

    }
}
