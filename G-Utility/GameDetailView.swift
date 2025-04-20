import SwiftUI
import SwiftData

struct GameDetailView: View {
    @Bindable var game: Game
    @Environment(\.modelContext) private var modelContext

    @State private var newPlayerName: String = ""
    @State private var expandedSessionIDs: Set<PersistentIdentifier> = []

    var body: some View {
        PlayerSummaryView(
            game: game,
            newPlayerName: $newPlayerName,
            expandedSessionIDs: $expandedSessionIDs,
            onAddPlayer: { name in
                let newPlayer = Player(name: name)
                game.players.append(newPlayer)
                modelContext.insert(newPlayer)
                newPlayerName = ""
            },
            onAddSession: {
                guard !game.players.isEmpty else { return }

                let newScores = game.players.map { player in
                    let score = ScoreEntry(player: player, score: 0)
                    modelContext.insert(score)
                    return score
                }

                let newSession = GameSession(
                    name: "Session - \(Date().formatted(date: .abbreviated, time: .shortened))",
                    scores: newScores
                )

                game.sessions.append(newSession)
                modelContext.insert(newSession)
                expandedSessionIDs.insert(newSession.id)
            },
            onDeleteSession: { session in
                if let index = game.sessions.firstIndex(where: { $0.id == session.id }) {
                    game.sessions.remove(at: index)
                    modelContext.delete(session)
                    expandedSessionIDs.remove(session.id)
                }
            }
        )
        .navigationTitle(game.name)
    }
}

