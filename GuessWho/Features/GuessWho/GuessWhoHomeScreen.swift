import SwiftUI

/// Owns the home menu and player setup flow for the Guess Who feature.
struct GuessWhoHomeScreen: View {
    @EnvironmentObject private var gameState: GameState
    @AppStorage(guessWhoLanguageOverrideKey) private var languageOverride = ""
    @AppStorage(guessWhoPlayerOneNameKey) private var playerOneName = ""
    @AppStorage(guessWhoPlayerTwoNameKey) private var playerTwoName = ""
    @State private var showsSetup = false
    @State private var showsNewGameConfirmation = false

    var body: some View {
        Group {
            if showsSetup { setup } else { menu }
        }
        .alert(copy("home.alert.title", fallback: "Start over?"), isPresented: $showsNewGameConfirmation) {
            Button(copy("home.alert.cancel", fallback: "Cancel"), role: .cancel) {}
            Button(copy("home.alert.confirm", fallback: "Start New Game"), role: .destructive) { showsSetup = true }
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
                        HomeLanguagePicker(selectedLanguage: GuessWhoLanguage.resolved(override: languageOverride), label: copy("home.language.label", fallback: "Language"), englishTitle: copy("home.language.english", fallback: "English"), ukrainianTitle: copy("home.language.ukrainian", fallback: "Ukrainian"), onSelect: { languageOverride = $0.rawValue })
                    }
                }
            }.padding(.horizontal, 20).padding(.top, 72).padding(.bottom, 28)
        }
    }

    private var setup: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack { Button(copy("home.players.back", fallback: "Back"), action: { showsSetup = false }); Spacer() }
                card {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(copy("home.players.title", fallback: "Name your players")).font(StudioTypography.title).foregroundStyle(StudioTheme.ink)
                        Text(copy("home.players.message", fallback: "Add names for each side, or leave them blank to keep the default labels.")).font(StudioTypography.footnote).foregroundStyle(StudioTheme.muted)
                        TextField("Player 1", text: $playerOneName).textFieldStyle(.roundedBorder)
                        TextField("Player 2", text: $playerTwoName).textFieldStyle(.roundedBorder)
                        Button(copy("home.players.start", fallback: "Start Game"), action: startGame).buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
                    }
                }
            }.padding(.horizontal, 20).padding(.top, 72).padding(.bottom, 28)
        }
    }

    private func startTapped() {
        if gameState.hasRoundInProgress { showsNewGameConfirmation = true } else { showsSetup = true }
    }

    private func startGame() {
        playerOneName = playerOneName.trimmingCharacters(in: .whitespacesAndNewlines)
        playerTwoName = playerTwoName.trimmingCharacters(in: .whitespacesAndNewlines)
        gameState.startNewGame()
        showsSetup = false
    }
    private func copy(_ key: String, fallback: String) -> String { guessWhoLocalized(key, fallback: fallback) }
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View { content().padding(24).background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous)).overlay { RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(StudioTheme.line.opacity(0.8)) } }
}
