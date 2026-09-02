import SwiftUI

/// Coordinates app-level preferences and routes state-owned screens to focused views.
struct ContentView: View {
    @EnvironmentObject private var gameState: GameState
    @AppStorage(guessWhoLanguageOverrideKey) private var languageOverride = ""
    @AppStorage(guessWhoPlayerOneNameKey) private var playerOneName = ""
    @AppStorage(guessWhoPlayerTwoNameKey) private var playerTwoName = ""
    @StateObject private var portraitRepository = PortraitImageRepository()
    @State private var showsNewGameConfirmation = false
    @State private var showsPlayerSetup = false

    private var language: GuessWhoLanguage { .resolved(override: languageOverride) }

    private var portraitPreloadKey: String {
        gameState.characters
            .map(\.portraitAssetName)
            .sorted()
            .joined(separator: "|")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                screen
            }
            .id(language.rawValue)
            .toolbar(.hidden, for: .navigationBar)
        }
        .task(id: portraitPreloadKey) {
            portraitRepository.preloadIfNeeded(for: gameState.characters)
        }
        .alert(copy("home.alert.title", "Start over?"), isPresented: $showsNewGameConfirmation) {
            Button(copy("home.alert.cancel", "Cancel"), role: .cancel) {}
            Button(copy("home.alert.confirm", "Start New Game"), role: .destructive) {
                showsPlayerSetup = true
            }
        } message: {
            Text(copy("home.alert.message", "Your current game will be cleared."))
        }
    }

    @ViewBuilder private var screen: some View {
        if showsPlayerSetup {
            PlayerSetupView(
                language: language,
                playerOneName: $playerOneName,
                playerTwoName: $playerTwoName,
                onBack: { showsPlayerSetup = false },
                onStart: startGame
            )
        } else {
            switch gameState.appScreen {
            case .menu:
                HomeView(
                    language: language,
                    hasRoundInProgress: gameState.hasRoundInProgress,
                    currentPlayer: gameState.currentPlayer,
                    lockedSecrets: lockedSecrets,
                    playerName: resolvedPlayerName,
                    onStart: requestNewGame,
                    onResume: gameState.resumeGame,
                    onRules: gameState.showRules,
                    onLanguageChange: { languageOverride = $0.rawValue }
                )
            case .rules:
                RulesView(
                    language: language,
                    hasRoundInProgress: gameState.hasRoundInProgress,
                    playerName: resolvedPlayerName,
                    onHome: gameState.showMenu,
                    onResume: gameState.resumeGame,
                    onStart: requestNewGame
                )
            case .game:
                GameFlowView(language: language, playerName: resolvedPlayerName)
                    .environmentObject(gameState)
                    .environmentObject(portraitRepository)
            }
        }
    }

    private var lockedSecrets: Int {
        [gameState.secretCharacter(for: .one), gameState.secretCharacter(for: .two)]
            .compactMap { $0 }
            .count
    }

    private func requestNewGame() {
        if gameState.hasRoundInProgress {
            showsNewGameConfirmation = true
        } else {
            showsPlayerSetup = true
        }
    }

    private func startGame() {
        showsPlayerSetup = false
        gameState.startNewGame()
    }

    private func resolvedPlayerName(_ player: GameState.Player) -> String {
        let value = (player == .one ? playerOneName : playerTwoName)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty
            ? copy(player == .one ? "home.player.one" : "home.player.two", player == .one ? "Player 1" : "Player 2")
            : value
    }

    private func copy(_ key: String, _ fallback: String) -> String {
        guessWhoLocalized(key, fallback: fallback, language: language)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState())
}
