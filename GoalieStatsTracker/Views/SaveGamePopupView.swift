//
//  SaveGamePopupView.swift
//  GoalieStatsTracker
//

import Foundation
import SwiftUI

struct SaveGamePopupView: View {

    let seasons: [String]
    var title: String = "Game has been saved!"
    var subtitle: String = "Go to Seasons to view your game"
    var confirmButtonTitle: String = "Done"
    let onConfirm: (String) -> Void

    @State private var selectedSeason: String = ""
    @State private var isCreatingNewSeason: Bool = false
    @State private var newSeasonName: String = ""

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    if isCreatingNewSeason {
                        TextField("Season name", text: $newSeasonName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 8)
                    }
                    else {
                        Menu {
                            ForEach(seasons, id: \.self) { season in
                                Button(season) {
                                    selectedSeason = season
                                }
                            }
                            Button("Create New Season…") {
                                isCreatingNewSeason = true
                            }
                        } label: {
                            HStack {
                                Text(selectedSeason.isEmpty ? "Select Season" : selectedSeason)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.footnote)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()

                Divider()

                Button(
                    action: {
                        let season = isCreatingNewSeason
                            ? newSeasonName.trimmingCharacters(in: .whitespaces)
                            : selectedSeason
                        onConfirm(season)
                    },
                    label: {
                        Text(confirmButtonTitle)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                )
            }
            .frame(maxWidth: 300)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(UIColor.systemBackground))
            )
            .padding(40)
        }
    }
}

struct SaveGamePopupView_Previews: PreviewProvider {
    static var previews: some View {
        SaveGamePopupView(seasons: ["Spring 2026", "Fall 2025"], onConfirm: { _ in })
    }
}
