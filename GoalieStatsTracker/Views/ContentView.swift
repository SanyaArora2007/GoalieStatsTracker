//
//  ContentView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameStore: GameStore
    
    @Environment(\.scenePhase) private var scenePhase
    
    @SceneStorage("TrackGoalieStats") private var saveGame: String?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Track Your Stats")
                    .fontWeight(.semibold)
                    .foregroundStyle(.purple)
                    .font(.largeTitle)
                
                Spacer()
                    .frame(height: 80.0)
                
                Image("MainMenuPicture")
                    .resizable()
                    .frame(width: 350, height: 350)
                
                Spacer()
                    .frame(height: 80.0)
                
                HStack {
                    NavigationLink {
                        RecordStatsView(gameStore: _gameStore)
                    } label: {
                        Text("Record")
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.teal)
                            .font(.title)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 4)
                                    .frame(width: 150, height: 60)
                                )
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        LoadPastView()
                    } label: {
                        Text("Load Past")
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.teal)
                            .font(.title)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 4)
                                    .frame(width: 150, height: 60)
                                )
                    }
                }
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .background {
                Task {
                    do {
                        try await gameStore.save()
                    }
                    catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GameStore())
    }
}
