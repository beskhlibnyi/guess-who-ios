import SwiftUI

@main
struct GuessWhoApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var aliasGameState = AliasGameState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .environmentObject(aliasGameState)
        }
    }
}
