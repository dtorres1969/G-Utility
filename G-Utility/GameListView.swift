//
//  GameListView.swift
//  GUtility
//
//  Created by David Torres on 4/19/25.
//

import SwiftUI
import SwiftData

struct GameListView: View {
    @State private var expandedSessionIDs: Set<PersistentIdentifier> = []
    @Environment(\.modelContext) private var modelContext
    @Query private var games: [Game]

    @State private var expandedGameIDs: Set<PersistentIdentifier> = []

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
                            playerSummarySection(for: game)
                        } label: {
                            Text(game.name)
                                .font(.headline)
                        }
                    }
                }
                .onDelete(perform: deleteGames)
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

    private func playerSummarySection(for game: Game) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Player totals
            ForEach(game.players) { player in
                let totalScore = totalScore(for: player, in: game)

                HStack {
                    Text(player.name)
                    Spacer()
                    Text("\(totalScore)")
                }
                .font(.subheadline)
            }

            // Add session button
            NavigationLink(destination: AddGameSessionView(game: game)) {
                Label("Add Session", systemImage: "plus.circle")
            }
            .font(.subheadline)
            .padding(.top, 8)

            // Past sessions
            if !game.sessions.isEmpty {
                Text("Past Sessions:")
                    .font(.subheadline)
                    .padding(.top, 8)

                ForEach(game.sessions.sorted(by: { $0.date > $1.date })) { session in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedSessionIDs.contains(session.id) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedSessionIDs.insert(session.id)
                                } else {
                                    expandedSessionIDs.remove(session.id)
                                }
                            }
                        )
                    ) {
                        ForEach(session.scores) { score in
                            HStack {
                                Text("- \(score.player.name)")
                                Spacer()
                                Text("\(score.score)")
                            }
                            .font(.caption)
                        }
                    } label: {
                        NavigationLink(destination: EditGameSessionView(session: session)) {
                            Text(session.date.formatted(date: .long, time: .omitted))
                                .font(.subheadline)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding(.top, 4)
        .onAppear {
            // Auto-expand latest session could be placed here
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

    private func totalScore(for player: Player, in game: Game) -> Int {
        game.sessions
            .flatMap { $0.scores }
            .filter { $0.player.name == player.name }
            .map { $0.score }
            .reduce(0, +)
    }
}

#Preview {
    GameListView()
        .modelContainer(for: Game.self, inMemory: true)
}

