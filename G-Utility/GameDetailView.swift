//
//  GameDetailView.swift
//  GUtility
//
//  Created by David Torres on 4/19/25.
//

import SwiftUI
import SwiftData

struct GameDetailView: View {
    @Bindable var game: Game
    @Environment(\.modelContext) private var modelContext
    @State private var isEditingName = false

@State private var newPlayerName = ""

var body: some View {
        Form {
            Section(header: Text("Players")) {
                ForEach(game.players) { player in
                    Text(player.name)
                }

HStack {
                    TextField("Add Player", text: $newPlayerName)
                    Button("Add") {
                        addPlayer()
                    }
                    .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

Section(header: Text("Sessions")) {
                NavigationLink("View Sessions") {
                    GameSessionListView(game: game)
                }
            }
        }
        .navigationTitle(game.name) // fallback title
        .toolbar {
            ToolbarItem(placement: .principal) {
                if isEditingName {
                    TextField("Game Name", text: $game.name)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                        .onSubmit {
                            isEditingName = false
                        }
                } else {
                    Text(game.name)
                        .font(.headline)
                        .onTapGesture {
                            isEditingName = true
                        }
                }
            }
        }

}

private func addPlayer() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

let newPlayer = Player(name: trimmed)
        game.players.append(newPlayer)
        modelContext.insert(newPlayer)
        newPlayerName = ""
    }
}

#Preview {
    let game = Game(name: "Preview Game")
    return GameDetailView(game: game)
}