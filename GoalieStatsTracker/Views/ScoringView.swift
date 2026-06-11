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
    let _geometry: GeometryProxy
    let shotsFontSize: CGFloat = 0.025
    let scoreFontSize: CGFloat = 0.04

    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
    }
    
    func scoreColor(_ score: Float) -> Color {
        if score < 0 {
            return Color.red
        }
        else if score > 0 {
            return Color.blue
        }
        else {
            return Color.black
        }
    }
    
    var body: some View {
        let goalie = _parent.selectedGoalieName
        let runningScore = _parent.shotsData.runningScore(forGoalie: goalie)
        let saves = _parent.shotsData.saves(forGoalie: goalie)
        let totalShots = _parent.shotsData.totalShots(forGoalie: goalie)
        let savePercentage = _parent.shotsData.savePercentage(forGoalie: goalie)

        VStack {
            HStack {
                Text(_parent.loadPastView ? "Score:" : "Running Score:")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * scoreFontSize, weight: .light))
                Text(String(format: "%.1f", runningScore))
                    .foregroundColor(scoreColor(runningScore))
                    .font(.system(size: _geometry.size.height * scoreFontSize, weight: .bold))
            }
            
            Spacer()
                .frame(height: _geometry.size.height * 0.01)

            HStack {
                Text("Saves:")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * shotsFontSize, weight: .light))
                    .frame(width: _geometry.size.width*0.5, alignment: .trailing)
                Text("\(saves)  (\(savePercentage)%)")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * shotsFontSize, weight: .bold))
                    .frame(width: _geometry.size.width*0.5, alignment: .leading)
            }
            
            HStack {
                Text("Shots:")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * shotsFontSize, weight: .light))
                    .frame(width: _geometry.size.width*0.5, alignment: .trailing)
                Text("\(totalShots)")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * shotsFontSize, weight: .bold))
                    .frame(width: _geometry.size.width*0.5, alignment: .leading)
            }
        }

        Spacer().frame(height: 60)
    }
}
