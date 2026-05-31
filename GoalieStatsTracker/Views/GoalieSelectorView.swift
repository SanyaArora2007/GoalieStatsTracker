//
//  GoalieSelectorView.swift
//  GoalieStatsTracker
//
//  Created by Rishi Arora on 3/9/24.
//

import SwiftUI

struct GoalieSelectorView: View {

    var disableAddingGoalie: Bool = false

    struct Goalie : Hashable {
        var name: String
        var selected: Bool
    }

    @State private var goalies : [Goalie] = [
        Goalie(name:"Me", selected:true),
    ]

    func select(name: String) {
        for index in goalies.indices {
            goalies[index].selected = goalies[index].name == name
        }
    }
    
    @State private var showAddGoalieAlert = false
    @State private var newGoalieName: String = ""

    @State private var showRenameGoalieAlert = false
    @State private var renamedGoalieName: String = ""
    @State private var goalieBeingRenamed: Goalie?

    var body: some View {
        HStack {
            Text("Goalies")
                .padding(.leading, 8)
            ScrollView(.horizontal) {
                HStack(spacing: 5) {
                    ForEach(goalies, id: \.self) { goalie in
                        Button(
                            action: {
                                if goalie.selected {
                                    goalieBeingRenamed = goalie
                                    renamedGoalieName = goalie.name
                                    showRenameGoalieAlert = true
                                } else {
                                    withAnimation {
                                        select(name: goalie.name)
                                    }
                                }
                            },
                            label: {
                                Text(goalie.name)
                                    .padding(8)
                                    .foregroundColor(.black)
                                    .font(.system(size: 14))
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: 10,
                                            style: .continuous
                                        )
                                        .fill(.teal)
                                        .opacity(goalie.selected ? 0.75 : 0.1)
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
                goalies.append(Goalie(name: newGoalieName, selected: false))
                newGoalieName = ""
            }
            Button("Cancel", role: .cancel) { newGoalieName = "" }
        }
        .alert("Change Goalie Name", isPresented: $showRenameGoalieAlert) {
            TextField("Goalie Name", text: $renamedGoalieName)
            Button("OK") {
                if let target = goalieBeingRenamed,
                   let index = goalies.firstIndex(of: target) {
                    goalies[index].name = renamedGoalieName
                }
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
    GoalieSelectorView()
}
