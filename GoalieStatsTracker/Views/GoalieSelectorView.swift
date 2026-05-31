//
//  GoalieSelectorView.swift
//  GoalieStatsTracker
//
//  Created by Rishi Arora on 3/9/24.
//

import SwiftUI

struct GoalieSelectorView: View {

    @ObservedObject var shotsData: ShotsData
    @Binding var selectedGoalieName: String
    var disableAddingGoalie: Bool = false

    @State private var showAddGoalieAlert = false
    @State private var newGoalieName: String = ""

    @State private var showRenameGoalieAlert = false
    @State private var renamedGoalieName: String = ""
    @State private var goalieBeingRenamed: String?

    func renameSelectedGoalie(to newName: String) {
        guard let original = goalieBeingRenamed else { return }
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed != original else { return }
        if let index = shotsData.goalies.firstIndex(of: original) {
            shotsData.goalies[index] = trimmed
        }
        for index in shotsData.shots.indices where shotsData.shots[index].goalieName == original {
            shotsData.shots[index].goalieName = trimmed
        }
        if selectedGoalieName == original {
            selectedGoalieName = trimmed
        }
    }

    var body: some View {
        HStack {
            Text("Goalies")
                .padding(.leading, 8)
            ScrollView(.horizontal) {
                HStack(spacing: 5) {
                    ForEach(shotsData.goalies, id: \.self) { goalie in
                        Button(
                            action: {
                                if selectedGoalieName == goalie {
                                    goalieBeingRenamed = goalie
                                    renamedGoalieName = goalie
                                    showRenameGoalieAlert = true
                                } else {
                                    withAnimation {
                                        selectedGoalieName = goalie
                                    }
                                }
                            },
                            label: {
                                Text(goalie)
                                    .padding(8)
                                    .foregroundColor(.black)
                                    .font(.system(size: 14))
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: 10,
                                            style: .continuous
                                        )
                                        .fill(.teal)
                                        .opacity(selectedGoalieName == goalie ? 0.75 : 0.1)
                                    )
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 5)
            }

            if !disableAddingGoalie {
                Button(
                    action: {
                        showAddGoalieAlert = true
                    },
                    label: {
                        Image(systemName: "person.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.teal)
                            .opacity(0.75)
                            .frame(width:30)
                    }
                )
                .frame(alignment: .leading)
                .padding(.trailing, 10)
            }
        }
        .alert("Add Goalie", isPresented: $showAddGoalieAlert) {
            TextField("Goalie Name", text: $newGoalieName)
            Button("OK") {
                let trimmed = newGoalieName.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty && !shotsData.goalies.contains(trimmed) {
                    shotsData.goalies.append(trimmed)
                }
                newGoalieName = ""
            }
            Button("Cancel", role: .cancel) { newGoalieName = "" }
        }
        .alert("Goalie", isPresented: $showRenameGoalieAlert) {
            TextField("Goalie Name", text: $renamedGoalieName)
            Button("OK") {
                renameSelectedGoalie(to: renamedGoalieName)
                renamedGoalieName = ""
                goalieBeingRenamed = nil
            }
            Button("Cancel", role: .cancel) {
                renamedGoalieName = ""
                goalieBeingRenamed = nil
            }
        }
    }
}

#Preview {
    GoalieSelectorView(
        shotsData: ShotsData(),
        selectedGoalieName: .constant(ShotsData.defaultGoalieName)
    )
}
