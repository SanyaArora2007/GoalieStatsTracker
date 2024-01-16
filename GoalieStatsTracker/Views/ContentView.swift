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
    let buttonWidth: CGFloat = 0.35
    let buttonHeight: CGFloat = 0.075
    let buttonRadiusSize: CGFloat = 0.02
    let titleSize: CGFloat = 0.05
    let mainImageSize: CGFloat = 0.70
    let verticalSpacerSize: CGFloat = 0.05

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

                    HStack(alignment: .center) {
                        Spacer()

                        NavigationLink {
                            RecordStatsView(gameStore: _gameStore)
                        } label: {
                            Text("New Game")
                                .foregroundStyle(.teal)
                                .font(.system(size: proxy.size.height * buttonFontSize))
                                .overlay(
                                    RoundedRectangle(cornerRadius: proxy.size.height * buttonRadiusSize)
                                        .stroke(Color.gray, lineWidth: proxy.size.height * buttonBorderWidth)
                                        .frame(width: proxy.size.width * buttonWidth, height: proxy.size.height * buttonHeight)
                                )
                        }

                        Spacer()

                        NavigationLink {
                            LoadPastView()
                        } label: {
                            Text("Load Past")
                                .foregroundStyle(.teal)
                                .font(.system(size: proxy.size.height * buttonFontSize))
                                .overlay(
                                    RoundedRectangle(cornerRadius: proxy.size.height * buttonRadiusSize)
                                        .stroke(Color.gray, lineWidth: proxy.size.height * buttonBorderWidth)
                                        .frame(width: proxy.size.width * buttonWidth, height: proxy.size.height * buttonHeight)
                                )
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    Spacer()
                        .frame(width: 40)

                }
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
