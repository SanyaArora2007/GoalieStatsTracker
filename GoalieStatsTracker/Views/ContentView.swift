//
//  ContentView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct ContentView: View {
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
                        RecordStatsView()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
