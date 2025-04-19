//
//  GUtilityApp.swift
//  GUtility
//
//  Created by David Torres on 4/19/25.
//

import SwiftUI
import SwiftData

@main
struct GUtilityApp: App {
    var body: some Scene {
        WindowGroup {
            GameListView()
        }
        .modelContainer(for: [Game.self, Player.self, ScoreEntry.self])
    }
}