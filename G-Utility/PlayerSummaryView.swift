import SwiftUI
import SwiftData

struct PlayerSummaryView: View {
    let game: Game
    @Binding var newPlayerName: String
    @Binding var expandedSessionIDs: Set<PersistentIdentifier>

    let onAddPlayer: (String) -> Void
    let onAddSession: () -> Void
    let onDeleteSession: (GameSession) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Add Player
            Text("Players").font(.headline)

            HStack {
                TextField("Add Player", text: $newPlayerName)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        onAddPlayer(trimmed)
                    }
                }
                .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Show Players
            ForEach(game.players) { player in
                let totalScore = totalScore(for: player)
                HStack {
                    Text(player.name)
                    Spacer()
                    Text("\(totalScore)")
                }
                .padding(6)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .font(.subheadline)
            }

            // Add Session Button (placed outside scrollable List)
            HStack {
                Spacer()
                Button(action: {
                    onAddSession()
                }) {
                    Label("Add Session", systemImage: "plus.circle")
                }
                .font(.subheadline)
                Spacer()
            }
            .padding(.vertical, 8)

            // List of Sessions
            if !game.sessions.isEmpty {
                Text("Past Sessions:")
                    .font(.subheadline)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(game.sessions.sorted(by: { $0.date > $1.date })) { session in
                            VStack(alignment: .leading, spacing: 4) {
                                sessionRow(session: session)
                                    .background(Color(.systemBackground))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            onDeleteSession(session)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }

                                if expandedSessionIDs.contains(session.id) {
                                    ForEach(session.scores) { score in
                                        HStack {
                                            Text("- \(score.player.name)")
                                            Spacer()
                                            Text("\(score.score)")
                                        }
                                        .font(.caption)
                                    }

                                    NavigationLink("Edit Scores", destination: EditGameSessionView(session: session))
                                        .font(.caption)
                                        .padding(.top, 4)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.bottom, 8)
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .padding()
    }

    private func sessionRow(session: GameSession) -> some View {
        HStack {
            Text(session.name)
                .font(.subheadline)
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(expandedSessionIDs.contains(session.id) ? .degrees(0) : .degrees(-90))
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleSession(session)
        }
    }

    private func totalScore(for player: Player) -> Int {
        game.sessions
            .flatMap { $0.scores }
            .filter { $0.player.name == player.name }
            .map { $0.score }
            .reduce(0, +)
    }

    private func toggleSession(_ session: GameSession) {
        if expandedSessionIDs.contains(session.id) {
            expandedSessionIDs.remove(session.id)
        } else {
            expandedSessionIDs.insert(session.id)
        }
    }
}

