//
//  AddGameSessionView.swift
//  GUtility
//
//  Created by David Torres on 4/19/25.
//

import SwiftUI
import SwiftData

struct AddGameSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var game: Game

    @State private var scores: [String: String] = [:] // using player.name as key

    var body: some View {
        Form {
            Section(header: Text("Enter Scores")) {
                ForEach(game.players, id: \.name) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        TextField("Score", text: Binding(
                            get: { scores[player.name, default: ""] },
                            set: { scores[player.name] = $0 }
                        ))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    }
                }
            }

            Section {
                Button("Save Session") {
                    saveSession()
                }
                .disabled(scores.values.allSatisfy { Int($0) == nil })
            }
        }
        .navigationTitle("New Session")
    }

    private func saveSession() {
        var entries: [ScoreEntry] = []

        for player in game.players {
            if let value = scores[player.name], let score = Int(value) {
                let entry = ScoreEntry(player: player, score: score)
                entries.append(entry)
                modelContext.insert(entry)
            }
        }

        let session = GameSession(date: Date(), scores: entries)
        game.sessions.append(session)
        modelContext.insert(session)
        dismiss()
    }
}
