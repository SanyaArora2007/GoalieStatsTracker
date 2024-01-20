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

    private var dateFormat: DateFormatter = DateFormatter()
    
    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
        self.dateFormat.dateStyle = .long
        self.dateFormat.timeStyle = .short
    }
    
    var body: some View {
        Spacer()
            .frame(height: _geometry.size.height * 0.05)

        if _parent.loadPastView == true {
            VStack {
                Text(_parent.shotsData.gameName)
                    .multilineTextAlignment(.center)
                    .font(.system(size: _geometry.size.height * 0.03))
                    .foregroundStyle(Color.black)

                Spacer()
                    .frame(height: _geometry.size.height * 0.01)
                
                Text(dateFormat.string(from: Date(timeIntervalSince1970:_parent.shotsData.gameTime)))
                    .multilineTextAlignment(.center)
                    .font(.system(size: _geometry.size.height * 0.02, weight: .light))
                    .foregroundStyle(Color.black)
            }
        }
        else
        {
            TextField("Playing Against?", text: _parent.$shotsData.gameName)
                .multilineTextAlignment(.center)
                .font(.system(size: _geometry.size.height * 0.03))
                .foregroundStyle(Color.black)
        }

        Spacer()
            .frame(height: _geometry.size.height * 0.05)
    }
}
