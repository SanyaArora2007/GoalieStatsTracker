//
//  RecordStatsView.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 9/28/23.
//

import SwiftUI

struct RecordStatsView: View {

    @State private var showAlert = false
    
    var loadPastView: Bool = false
    var disable: Bool = false
    
    @EnvironmentObject var gameStore: GameStore
    @Environment(\.presentationMode) var presentationMode
    
    static let colorGoal = Color.red
    static let colorSave = Color.green
    static let color8MGoal = Color.purple
    static let color8MSave = Color.mint
    static let colorNeutral = Color.gray
    
    @State private var colorGoalButton : Color = colorNeutral
    @State private var colorSaveButton : Color = colorNeutral
    @State private var color8MGoalButton : Color = colorNeutral
    @State private var color8MSaveButton : Color = colorNeutral
    
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
    
    var draw12MeterCircle: some Gesture {
        SpatialTapGesture()
            .onEnded() { event in
                let shot = shotsData.newShot(goal:isGoal, eightMeter:is8Meter, location:event.location)
                pointsOn12Meter.append(shot)
            }
    }
    
    var tapGoalGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = RecordStatsView.colorGoal
                    colorSaveButton = RecordStatsView.colorNeutral
                    color8MGoalButton = RecordStatsView.colorNeutral
                    color8MSaveButton = RecordStatsView.colorNeutral
                    
                    isGoal = true
                    is8Meter = false
                }
            }
    }
    
    var tapSaveGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = RecordStatsView.colorNeutral
                    colorSaveButton = RecordStatsView.colorSave
                    color8MGoalButton = RecordStatsView.colorNeutral
                    color8MSaveButton = RecordStatsView.colorNeutral
                    
                    isGoal = false
                    is8Meter = false
                }
            }
    }
    
    var tapClearGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = RecordStatsView.colorNeutral
                    colorSaveButton = RecordStatsView.colorNeutral
                    color8MGoalButton = RecordStatsView.color8MGoal
                    color8MSaveButton = RecordStatsView.colorNeutral
                    
                    isGoal = true
                    is8Meter = true
                }
            }
    }
    
    var tap8MeterGesture: some Gesture {
        TapGesture()
            .onEnded() {
                withAnimation {
                    colorGoalButton = RecordStatsView.colorNeutral
                    colorSaveButton = RecordStatsView.colorNeutral
                    color8MGoalButton = RecordStatsView.colorNeutral
                    color8MSaveButton = RecordStatsView.color8MSave
                    
                    isGoal = false
                    is8Meter = true
                }
            }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                VStack {
                    TextField("Playing Against?", text: $shotsData.gameName)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .foregroundStyle(Color.black)
                    Spacer()
                        .frame(height: 50)
                    HStack {
                        Spacer()
                        ZStack {
                            Rectangle()
                                .frame(width: 80, height: 40)
                                .foregroundColor(colorGoalButton)
                                .opacity(0.5)
                                .gesture(tapGoalGesture)
                            Text("Goal")
                                .font(.headline)
                        }
                        Spacer()
                        ZStack {
                            Rectangle()
                                .frame(width: 80, height: 40)
                                .foregroundColor(colorSaveButton)
                                .opacity(0.5)
                                .gesture(tapSaveGesture)
                            Text("Save")
                                .font(.headline)
                        }
                        Spacer()
                        ZStack {
                            Rectangle()
                                .frame(width: 80, height: 40)
                                .foregroundColor(color8MGoalButton)
                                .opacity(0.5)
                                .gesture(tapClearGesture)
                            Text("8M Goal")
                                .font(.headline)
                        }
                        Spacer()
                        ZStack {
                            Rectangle()
                                .frame(width: 80, height: 40)
                                .foregroundColor(color8MSaveButton)
                                .opacity(0.5)
                                .gesture(tap8MeterGesture)
                            Text("8M Save")
                                .font(.headline)
                        }
                        Spacer()
                    }
                    
                    ZStack {
                        Image("12MeterDiagram")
                            .resizable()
                            .frame(width: 400, height: 240)
                        
                        ForEach(pointsOn12Meter, id: \.self) { shot in
                            ClickedCircle(currentLocation: shot.coordinate, circleColor: circleColor(wasItAGoal: shot.wasItAGoal, wasItA8Meter: shot.wasItEightMeter))
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .contentShape(Rectangle())
                    .gesture(draw12MeterCircle)
                    
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
                
                Button(
                    action: {
                        showAlert = true
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
                        if loadPastView == false {
                            ZStack {
                                Rectangle()
                                    .frame(width: 130, height: 40)
                                    .foregroundColor(Color.gray)
                                    .opacity(0.5)
                                Text("Save Game")
                                    .font(.title2)
                                    .foregroundStyle(Color.teal)
                                    .alert(isPresented: $showAlert) {
                                        Alert(title: Text("Game had been saved!"), message: Text("Go to Load Past to view your stats"), dismissButton: Alert.Button.default(
                                                Text("Main Menu"), action: {
                                                    presentationMode.wrappedValue.dismiss()
                                                }
                                            )
                                        )
                                    }
                            }
                        }
                    }
                )
            }
            .disabled(disable)
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
    
    func circleColor(wasItAGoal: Bool, wasItA8Meter: Bool) -> Color {
        if wasItAGoal == true {
            if wasItA8Meter == true {
                return RecordStatsView.color8MGoal
            }
            else {
                return RecordStatsView.colorGoal
            }
        }
        else {
            if wasItA8Meter == true {
                return RecordStatsView.color8MSave
            }
            else {
                return RecordStatsView.colorSave
            }
        }
    }
}

struct ClickedCircle: View {
    
    @State var currentLocation: CGPoint
    @State var circleColor: Color

    var body: some View {

        return Circle().fill(circleColor)
            .frame(width: 10, height: 10)
            .position(currentLocation)
    }
}

struct RecordStatsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordStatsView()
    }
}
