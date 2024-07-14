//
//  ContentView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var gameStore: GameStore

    let buttonFontSize: CGFloat = 0.03
    let buttonBorderWidth: CGFloat = 0.004
    let buttonWidth: CGFloat = 0.6
    let buttonHeight: CGFloat = 0.05
    let buttonRadiusSize: CGFloat = 0.02
    let titleSize: CGFloat = 0.05
    let mainImageSize: CGFloat = 0.65
    let verticalSpacerSize: CGFloat = 0.04

    var body: some View {
        GeometryReader { proxy in
            NavigationView {
                VStack {
                    Text("Track Your Stats")
                        .fontWeight(.semibold)
                        .foregroundStyle(.purple)
                        .font(.system(size: proxy.size.height * titleSize))

                    Spacer()
                        .frame(height: proxy.size.height * verticalSpacerSize)

                    Image("MainMenuPicture")
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width * mainImageSize)

                    Spacer()
                        .frame(height: proxy.size.height * verticalSpacerSize)

                    NavigationLink {
                        RecordStatsView(gameStore: _gameStore, isWomensField: true)
                    } label: {
                        Text(gameStore.ongoingGame == nil ? "New Women's Game" : "Resume Game")
                            .foregroundStyle(.teal)
                            .font(.system(size: proxy.size.height * buttonFontSize))
                            .overlay(
                                RoundedRectangle(cornerRadius: proxy.size.height * buttonRadiusSize)
                                    .stroke(Color.gray, lineWidth: proxy.size.height * buttonBorderWidth)
                                    .frame(width: proxy.size.width * buttonWidth, height: proxy.size.height * buttonHeight)
                            )
                    }
                    
                    Spacer()
                        .frame(height: proxy.size.height * verticalSpacerSize)
                    
                    NavigationLink {
                        RecordStatsView(gameStore: _gameStore, isWomensField: false)
                    } label: {
                        Text(gameStore.ongoingGame == nil ? "New Men's Game" : "Resume Game")
                            .foregroundStyle(.teal)
                            .font(.system(size: proxy.size.height * buttonFontSize))
                            .overlay(
                                RoundedRectangle(cornerRadius: proxy.size.height * buttonRadiusSize)
                                    .stroke(Color.gray, lineWidth: proxy.size.height * buttonBorderWidth)
                                    .frame(width: proxy.size.width * buttonWidth, height: proxy.size.height * buttonHeight)
                            )
                    }
                    
                    Spacer()
                        .frame(height: proxy.size.height * verticalSpacerSize)

                    NavigationLink {
                        LoadPastView()
                    } label: {
                        Text("Load Past Games")
                            .foregroundStyle(.teal)
                            .font(.system(size: proxy.size.height * buttonFontSize))
                            .overlay(
                                RoundedRectangle(cornerRadius: proxy.size.height * buttonRadiusSize)
                                    .stroke(Color.gray, lineWidth: proxy.size.height * buttonBorderWidth)
                                    .frame(width: proxy.size.width * buttonWidth, height: proxy.size.height * buttonHeight)
                            )
                    }
                }
            }
            .navigationViewStyle(.stack)
            .task {
                do {
                    let _ = try await gameStore.load()
                }
                catch {}
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
