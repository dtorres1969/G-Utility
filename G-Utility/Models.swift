//
//  Models.swift
//  GUtility
//
//  Created by David Torres on 4/19/25.
//

import Foundation
import SwiftData

@Model
class Game {
    var name: String
    var createdAt: Date
    var players: [Player]
    var sessions: [GameSession]

init(name: String, createdAt: Date = .now, players: [Player] = [], sessions: [GameSession] = []) {
        self.name = name
        self.createdAt = createdAt
        self.players = players
        self.sessions = sessions
    }
}

@Model
class Player {
    var name: String

init(name: String) {
        self.name = name
    }
}

@Model
class GameSession {
    var name: String
    var date: Date
    var scores: [ScoreEntry]

init(name: String = "", date: Date = .now, scores: [ScoreEntry] = []) {
        self.name = name
        self.date = date
        self.scores = scores
    }
}

@Model
class ScoreEntry {
    var player: Player
    var score: Int

init(player: Player, score: Int) {
        self.player = player
        self.score = score
    }
}