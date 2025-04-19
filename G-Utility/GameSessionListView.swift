//
//  GameSessionListView.swift
//  GUtility
//
//  Created by David Torres on 4/19/25.
//

import SwiftUI
import SwiftData

struct GameSessionListView: View {
    @Bindable var game: Game

var body: some View {
        List {
            Section(header: Text("Game Sessions")) {
                ForEach(game.sessions.sorted(by: { $0.date > $1.date })) { session in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.name.isEmpty
                             ? session.date.formatted(date: .abbreviated, time: .omitted)
                             : session.name)
                        .font(.headline)

ForEach(session.scores) { score in
                            Text("\(score.player.name): \(score.score)")
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Sessions")
    }
}