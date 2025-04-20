import SwiftUI
import SwiftData

struct GameRowView: View {
    let game: Game
    @Binding var expandedGameIDs: Set<PersistentIdentifier>
    @Binding var editingGameID: PersistentIdentifier?
    let playerSummaryContent: () -> AnyView

    var body: some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { expandedGameIDs.contains(game.id) },
                set: { isExpanded in
                    if isExpanded {
                        expandedGameIDs.insert(game.id)
                    } else {
                        expandedGameIDs.remove(game.id)
                    }
                }
            )
        ) {
            playerSummaryContent()
        } label: {
            if editingGameID == game.id {
                TextField("Game Name", text: Binding(
                    get: { game.name },
                    set: { game.name = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
                .onSubmit {
                    editingGameID = nil
                }
            } else {
                Text(game.name)
                    .font(.headline)
                    .onTapGesture {
                        editingGameID = game.id
                    }
            }
        }
    }
}
//
//  GameRowView.swift
//  G-Utility
//
//  Created by David Torres on 4/19/25.
//

