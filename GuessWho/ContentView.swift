import SwiftUI

/// App-level router for the game catalogue.
///
/// Each playable game gets its own experience view instead of growing the
/// application entry point into a single, cross-game screen implementation.
struct ContentView: View {
    @EnvironmentObject private var gameState: GameState

    var body: some View {
        GuessWhoExperienceView()
            .id(gameState.selectedGame)
    }
}
