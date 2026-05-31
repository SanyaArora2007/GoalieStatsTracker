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
    var onGoaliesChanged: () -> Void = {}

    @State private var showAddGoalieAlert = false
    @State private var newGoalieName: String = ""

    @State private var showRenameGoalieAlert = false
    @State private var renamedGoalieName: String = ""
    @State private var goalieBeingRenamed: String?

    @State private var showDuplicateNameAlert = false
    @State private var duplicateNameAttempted = ""

    enum RenameResult {
        case success
        case noChange
        case duplicate
    }

    func renameSelectedGoalie(to newName: String) -> RenameResult {
        guard let original = goalieBeingRenamed else { return .noChange }
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed != original else { return .noChange }
        if shotsData.goalies.contains(trimmed) {
            return .duplicate
        }
        if let index = shotsData.goalies.firstIndex(of: original) {
            shotsData.goalies[index] = trimmed
        }
        for index in shotsData.shots.indices where shotsData.shots[index].goalieName == original {
            shotsData.shots[index].goalieName = trimmed
        }
        if selectedGoalieName == original {
            selectedGoalieName = trimmed
        }
        return .success
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
                if !trimmed.isEmpty {
                    if shotsData.goalies.contains(trimmed) {
                        duplicateNameAttempted = trimmed
                        showDuplicateNameAlert = true
                    } else {
                        shotsData.goalies.append(trimmed)
                        onGoaliesChanged()
                    }
                }
                newGoalieName = ""
            }
            Button("Cancel", role: .cancel) { newGoalieName = "" }
        }
        .alert("Goalie", isPresented: $showRenameGoalieAlert) {
            TextField("Goalie Name", text: $renamedGoalieName)
            Button("OK") {
                switch renameSelectedGoalie(to: renamedGoalieName) {
                case .success:
                    onGoaliesChanged()
                case .duplicate:
                    duplicateNameAttempted = renamedGoalieName.trimmingCharacters(in: .whitespaces)
                    showDuplicateNameAlert = true
                case .noChange:
                    break
                }
                renamedGoalieName = ""
                goalieBeingRenamed = nil
            }
            Button("Cancel", role: .cancel) {
                renamedGoalieName = ""
                goalieBeingRenamed = nil
            }
        }
        .alert("Problem!", isPresented: $showDuplicateNameAlert) {
            Button("OK", role: .cancel) { duplicateNameAttempted = "" }
        } message: {
            Text("Two goalies can't have the same name (\(duplicateNameAttempted)).")
        }
    }
}

#Preview {
    GoalieSelectorView(
        shotsData: ShotsData(),
        selectedGoalieName: .constant(ShotsData.defaultGoalieName)
    )
}
