import SwiftUI

/// Owns the home menu and player setup flow for the Guess Who feature.
struct GuessWhoHomeScreen: View {
    @EnvironmentObject private var gameState: GameState
    @AppStorage(guessWhoLanguageOverrideKey) private var languageOverride = ""
    @AppStorage(guessWhoPlayerOneNameKey) private var playerOneName = ""
    @AppStorage(guessWhoPlayerTwoNameKey) private var playerTwoName = ""
    @State private var isSettingsPresented = false
    @State private var showsNewGameConfirmation = false

    var body: some View {
        menu
        .overlay {
            LauncherSettingsDrawer(
                languageOverride: $languageOverride,
                playerOneName: $playerOneName,
                playerTwoName: $playerTwoName,
                isPresented: $isSettingsPresented
            )
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .alert(copy("home.alert.title", fallback: "Start over?"), isPresented: $showsNewGameConfirmation) {
            Button(copy("home.alert.cancel", fallback: "Cancel"), role: .cancel) {}
            Button(copy("home.alert.confirm", fallback: "Start New Game"), role: .destructive, action: gameState.startNewGame)
        } message: { Text(copy("home.alert.message", fallback: "Your current game will be cleared.")) }
    }

    private var menu: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Text(copy("home.title", fallback: "ХТО")).font(StudioTypography.brandTitle).foregroundStyle(StudioTheme.ink)
                    Spacer()
                    Button(copy("home.games", fallback: "Games"), action: gameState.showGamePicker)
                        .buttonStyle(ActionButtonStyle(kind: .ghost))
                }
                card {
                    VStack(alignment: .leading, spacing: 22) {
                        Text(copy("home.overview", fallback: "Two players. One iPhone.")).font(StudioTypography.title).foregroundStyle(StudioTheme.ink)
                        Text(copy("home.summary", fallback: "Pick a secret. Ask yes-or-no questions. Make your guess.")).font(StudioTypography.body).foregroundStyle(StudioTheme.muted)
                        Button(copy("home.start", fallback: "Start New Game"), action: startTapped).buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
                        if gameState.hasRoundInProgress { Button(copy("home.resume", fallback: "Resume Game"), action: gameState.resumeGame).buttonStyle(ActionButtonStyle(kind: .outlined(StudioTheme.teal))) }
                        Button(copy("home.rules", fallback: "How to Play"), action: gameState.showRules).buttonStyle(ActionButtonStyle(kind: .ghost))
                    }
                }
            }.padding(.horizontal, 20).padding(.top, 72).padding(.bottom, 28)
        }
    }

    private func startTapped() {
        if gameState.hasRoundInProgress {
            showsNewGameConfirmation = true
        } else {
            gameState.startNewGame()
        }
    }

    private func copy(_ key: String, fallback: String) -> String { guessWhoLocalized(key, fallback: fallback) }
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View { content().padding(24).background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous)).overlay { RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(StudioTheme.line.opacity(0.8)) } }
}
