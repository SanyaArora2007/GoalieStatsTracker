//
//  RecordStatsView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct RecordStatsView: View {

    @State private var showSaveAlert = false
    @State private var showDiscardAlert = false

    
    var loadPastView: Bool = false
    var disable: Bool = false
    
    @EnvironmentObject var gameStore: GameStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var runningScoreColor: Color = Color.black
    
    @State var pointsOn12Meter: [ShotsData.Shot] = []

    @State var isGoal: Bool = false
    @State var is8Meter: Bool = false
    
    @State var loadView: Bool = false
        
    @StateObject var shotsData = ShotsData()

    
    init() {
    }

    init(gameStore: EnvironmentObject<GameStore>) {
        _gameStore = gameStore
    }
    
    init(gameStore: EnvironmentObject<GameStore>, shotsData: ShotsData) {
        _gameStore = gameStore
        _shotsData = StateObject(wrappedValue: shotsData)
        _pointsOn12Meter = State(initialValue: shotsData.shots)
        loadPastView = true
        disable = true
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                VStack {
                    Spacer()
                        .frame(height: 75)
                    TextField("Playing Against?", text: $shotsData.gameName)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .foregroundStyle(Color.black)
                    Spacer()
                        .frame(height: 50)
                    
                    ShotSelectorsView(parent: self)
                      
                    FieldView(parent: self)
                    
                    Divider()
                    
                    Spacer()
                        .frame(height: 40)
                }
                
                VStack {
                    if shotsData.runningScore < 0 {
                        Text(String(format: "Running Score: %.1f", shotsData.runningScore))
                            .foregroundColor(Color.red)
                        .font(Font.title)                }
                    else if shotsData.runningScore > 0 {
                        Text(String(format: "Running Score: %.1f", shotsData.runningScore))
                            .foregroundColor(Color.blue)
                        .font(Font.title)                }
                    else if shotsData.runningScore == 0 {
                        Text(String(format: "Running Score: %.1f", shotsData.runningScore))
                            .foregroundColor(Color.black)
                            .font(Font.title)
                    }
                    
                    Text("Saves: \(shotsData.saves)   (\(shotsData.savePercentage)%)")
                        .foregroundColor(Color.black)
                        .font(Font.headline)
                        .frame(alignment: .trailing)
                    
                    Text("Total Shots: \(shotsData.totalShots)")
                        .foregroundColor(Color.black)
                        .font(Font.headline)
                        .frame(alignment: .trailing)
                }
                
                Spacer()
                    .frame(height: 60)

                if loadPastView == false {
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
            .disabled(disable)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    func save() async throws {
        do {
            try await gameStore.save(game: shotsData)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct RecordStatsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordStatsView()
    }
}
