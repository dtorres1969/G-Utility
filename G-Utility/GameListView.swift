import SwiftUI
import SwiftData

struct GameListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var games: [Game]

    @State private var expandedGameIDs: Set<PersistentIdentifier> = []
    @State private var expandedSessionIDs: Set<PersistentIdentifier> = []
    @State private var newPlayerNames: [PersistentIdentifier: String] = [:]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(games) { game in
                    Section {
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
                            PlayerSummaryView(
                                game: game,
                                newPlayerName: Binding(
                                    get: { newPlayerNames[game.id, default: ""] },
                                    set: { newPlayerNames[game.id] = $0 }
                                ),
                                expandedSessionIDs: $expandedSessionIDs,
                                onAddPlayer: { name in
                                    let newPlayer = Player(name: name)
                                    game.players.append(newPlayer)
                                    modelContext.insert(newPlayer)
                                    newPlayerNames[game.id] = ""
                                },
                                onAddSession: {
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
                                    if let gameIndex = games.firstIndex(where: { $0.id == game.id }),
                                       let sessionIndex = games[gameIndex].sessions.firstIndex(where: { $0.id == session.id }) {
                                        games[gameIndex].sessions.remove(at: sessionIndex)
                                        modelContext.delete(session)
                                        expandedSessionIDs.remove(session.id)
                                    }
                                }
                            )
                        } label: {
                            Text(game.name)
                                .font(.headline)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                if let index = games.firstIndex(where: { $0.id == game.id }) {
                                    modelContext.delete(games[index])
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addGame) {
                        Label("Add Game", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a game")
        }
    }

    private func addGame() {
        withAnimation {
            let newGame = Game(name: "New Game")
            modelContext.insert(newGame)
        }
    }

    private func deleteGames(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(games[index])
            }
        }
    }
}

#Preview {
    GameListView()
        .modelContainer(for: Game.self, inMemory: true)
}

