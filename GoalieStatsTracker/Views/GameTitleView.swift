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
            .frame(height: _geometry.size.height * 0.04)

        if _parent.loadPastView == true {
            VStack {
                HStack {
                    TextField("", text: _parent.$shotsData.gameName)
                        .multilineTextAlignment(.center)
                        .font(.system(size: _geometry.size.height * 0.03))
                        .foregroundStyle(Color.black)
                        .fixedSize()
                        .onChange(of: _parent.shotsData.gameName) { newValue in
                            Task {
                                do {
                                    try await update()
                                }
                                catch {
                                    fatalError(error.localizedDescription)
                                }
                            }
                        }
                    
                    Image(systemName: "square.and.pencil.circle.fill")
                        .resizable()
                        .foregroundColor(Color.teal)
                        .scaledToFit()
                        .frame(height: _geometry.size.height * 0.035)
                        .opacity(0.75)
                }

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
    
    func update() async throws {
        do {
            try await _parent.gameStore.update(game: _parent.shotsData)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
