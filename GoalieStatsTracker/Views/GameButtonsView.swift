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
    
    @State private var showSaveAlert = false
    @State private var showDiscardAlert = false
        
    var _parent: RecordStatsView
    
    init(parent: RecordStatsView) {
        _parent = parent
    }
    
    var body: some View {
        if _parent.loadPastView == false {
            HStack {
                
                Spacer()
                    .frame(width: 80)
                
                Button(
                    action: {
                        showSaveAlert = true
                        Task {
                            do {
                                try await save()
                            }
                            catch {
                                fatalError(error.localizedDescription)
                            }
                        }
                    },
                    label: {
                        ZStack {
                            Text("Save")
                                .foregroundStyle(.teal)
                                .font(.title)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 4)
                                        .frame(width: 150, height: 55)
                                )
                                .alert(isPresented: $showSaveAlert) {
                                    Alert(title: Text("Game had been saved!"), message: Text("Go to Load Past to view your stats"), dismissButton: Alert.Button.default(
                                        Text("Main Menu"), action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    )
                                    )
                                }
                        }
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(
                    action: {
                        showDiscardAlert = true
                    },
                    label: {
                        Text("Discard")
                            .foregroundStyle(.teal)
                            .font(.title)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 4)
                                    .frame(width: 150, height: 55)
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
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Spacer()
                    .frame(width: 60)
                
            }
        }

    }
    
    func save() async throws {
        do {
            try await _parent.gameStore.save(game: _parent.shotsData)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
