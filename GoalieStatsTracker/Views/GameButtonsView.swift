//
//  GameButtonsView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 1/16/24.
//

import Foundation
import SwiftUI

struct GameButtonsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showDiscardAlert = false
        
    var _parent: RecordStatsView
    let _geometry: GeometryProxy
    
    let buttonFontSize: CGFloat = 0.03
    let buttonWidth: CGFloat = 0.3
    let buttonHeight: CGFloat = 0.06
    let buttonRadius: CGFloat = 0.02
    let buttonBorderWidth: CGFloat = 0.004
    let buttonSpacerWidth: CGFloat = 0.3

    init(parent: RecordStatsView, geometry: GeometryProxy) {
        _parent = parent
        _geometry = geometry
    }
    
    var body: some View {
        if _parent.loadPastView == false {
            HStack(alignment: .center) {
                Button(
                    action: {
                        _parent.showSavePopup = true
                    },
                    label: {
                        ZStack {
                            Text("Save")
                                .foregroundStyle(.teal)
                                .font(.system(size: _geometry.size.height * buttonFontSize))
                                .overlay(
                                    RoundedRectangle(cornerRadius: _geometry.size.width * buttonRadius)
                                        .stroke(Color.gray, lineWidth: _geometry.size.height * buttonBorderWidth)
                                        .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                                )
                        }
                    }
                )
                
                Spacer()
                    .frame(width: _geometry.size.width * buttonSpacerWidth)
                
                Button(
                    action: {
                        showDiscardAlert = true
                        Task {
                            await discard()
                        }
                    },
                    label: {
                        Text("Discard")
                            .foregroundStyle(.teal)
                            .font(.system(size: _geometry.size.height * buttonFontSize))
                            .overlay(
                                RoundedRectangle(cornerRadius: _geometry.size.width * buttonRadius)
                                    .stroke(Color.gray, lineWidth: _geometry.size.height * buttonBorderWidth)
                                    .frame(width: _geometry.size.width * buttonWidth, height: _geometry.size.height * buttonHeight)
                            )
                            .alert(isPresented: $showDiscardAlert) {
                                Alert(
                                    title: Text("Disacrd Game"),
                                    message: Text("Are you sure you want to discard this game?"),
                                    primaryButton: Alert.Button.default(
                                        Text("Yes"), action: { presentationMode.wrappedValue.dismiss() }
                                    ),
                                    secondaryButton: .cancel()
                                )
                            }
                    }
                )
            }
        }

    }
    
    func discard() async {
        do {
            try await _parent.gameStore.discardOngoingGame()
        }
        catch {
            // no need to report any errors when discarding a game
        }
    }
}
