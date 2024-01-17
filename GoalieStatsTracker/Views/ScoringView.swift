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
    
    func scoreColor() -> Color {
        if _parent.shotsData.runningScore < 0 {
            return Color.red
        }
        else if _parent.shotsData.runningScore > 0 {
            return Color.blue
        }
        else {
            return Color.black
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Running Score:")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * scoreFontSize, weight: .light))
                Text(String(format: "%.1f", _parent.shotsData.runningScore))
                    .foregroundColor(scoreColor())
                    .font(.system(size: _geometry.size.height * scoreFontSize, weight: .bold))
            }
            
            Spacer()
                .frame(height: _geometry.size.height * 0.01)

            HStack {
                Text("Saves:")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * shotsFontSize, weight: .light))
                    .frame(width: _geometry.size.width*0.5, alignment: .trailing)
                Text("\(_parent.shotsData.saves)  (\(_parent.shotsData.savePercentage)%)")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * shotsFontSize, weight: .bold))
                    .frame(width: _geometry.size.width*0.5, alignment: .leading)
            }
            
            HStack {
                Text("Shots:")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * shotsFontSize, weight: .light))
                    .frame(width: _geometry.size.width*0.5, alignment: .trailing)
                Text("\(_parent.shotsData.totalShots)")
                    .foregroundColor(Color.black)
                    .font(.system(size: _geometry.size.height * shotsFontSize, weight: .bold))
                    .frame(width: _geometry.size.width*0.5, alignment: .leading)
            }
        }

        Spacer().frame(height: 60)
    }
}
