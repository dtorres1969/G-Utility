//
//  EditGameSessionView.swift
//  GUtility
//
//  Created by David Torres on 4/20/25.
//

import SwiftUI
import SwiftData

struct EditGameSessionView: View {
    @Bindable var session: GameSession
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var updatedScores: [ScoreEntry: String] = [:]

    var body: some View {
        Form {
            Section(header: Text("Edit Scores for \(session.date.formatted(date: .abbreviated, time: .omitted))")) {
                ForEach(session.scores) { entry in
                    HStack {
                        Text(entry.player.name)
                        Spacer()
                        TextField("Score", text: Binding(
                            get: {
                                updatedScores[entry, default: "\(entry.score)"]
                            },
                            set: {
                                updatedScores[entry] = $0
                            }
                        ))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    }
                }
            }

            Button("Save Changes") {
                saveChanges()
            }
            .disabled(!hasChanges)
        }
        .navigationTitle("Edit Session")
    }

    private var hasChanges: Bool {
        updatedScores.contains { (entry, value) in
            Int(value) != entry.score
        }
    }

    private func saveChanges() {
        for (entry, value) in updatedScores {
            if let newScore = Int(value), newScore != entry.score {
                entry.score = newScore
            }
        }
        dismiss()
    }
}

#Preview {
    let player = Player(name: "Sample")
    let entry = ScoreEntry(player: player, score: 5)
    let session = GameSession(date: .now, scores: [entry])
    return EditGameSessionView(session: session)
}
//
//  EditGameSessionView.swift
//  G-Utility
//
//  Created by David Torres on 4/19/25.
//

