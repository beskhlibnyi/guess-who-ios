import SwiftUI

struct RulesScreen: View {
    @EnvironmentObject private var gameState: GameState
    @State private var showsNewGameConfirmation = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                card {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(copy("rules.badge", fallback: "Quick Guide").uppercased())
                                    .font(StudioTypography.compactLabel).foregroundStyle(StudioTheme.gold)
                                Text(copy("rules.title", fallback: "How to Play"))
                                    .font(StudioTypography.displaySmall).foregroundStyle(StudioTheme.ink)
                                Text(copy("rules.subtitle", fallback: "Pick in private, pass the phone, and narrow it down."))
                                    .font(StudioTypography.subheadline).foregroundStyle(StudioTheme.muted)
                            }
                            Spacer()
                            Button(copy("rules.home", fallback: "Home"), action: gameState.showMenu)
                                .buttonStyle(ActionButtonStyle(kind: .ghost))
                        }

                        VStack(spacing: 12) {
                            step("1", "hand.tap.fill", copy("rules.step1.title", fallback: "Pick in private"), copy("rules.step1.message", fallback: "Each player chooses one secret character."), StudioTheme.gold)
                            step("2", "questionmark.bubble.fill", copy("rules.step2.title", fallback: "Ask or guess"), copy("rules.step2.message", fallback: "Start every turn by choosing one."), StudioTheme.teal)
                            step("3", "checkmark.message.fill", copy("rules.step3.title", fallback: "Answer first"), copy("rules.step3.message", fallback: "After Yes or No, cross off faces that no longer fit."), StudioTheme.gold)
                            step("4", "scope", copy("rules.step4.title", fallback: "Guess to win"), copy("rules.step4.message", fallback: "Name the secret character to win."), StudioTheme.coral)
                        }

                        if gameState.hasRoundInProgress {
                            Button(copy("home.resume", fallback: "Resume Game"), action: gameState.resumeGame)
                                .buttonStyle(ActionButtonStyle(kind: .outlined(StudioTheme.teal)))
                        }
                        Button(copy("home.start", fallback: "Start New Game"), action: startTapped)
                            .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
                    }
                }
            }
            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 36)
        }
        .alert(copy("home.alert.title", fallback: "Start over?"), isPresented: $showsNewGameConfirmation) {
            Button(copy("home.alert.cancel", fallback: "Cancel"), role: .cancel) {}
            Button(copy("home.alert.confirm", fallback: "Start New Game"), role: .destructive, action: gameState.startNewGame)
        } message: {
            Text(copy("home.alert.message", fallback: "Your current game will be cleared."))
        }
    }

    private func step(_ number: String, _ icon: String, _ title: String, _ message: String, _ accent: Color) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number).font(StudioTypography.label).foregroundStyle(.white)
                .frame(width: 30, height: 30).background(accent, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: icon).font(StudioTypography.subheadline).foregroundStyle(StudioTheme.ink)
                Text(message).font(StudioTypography.footnote).foregroundStyle(StudioTheme.muted)
            }
            Spacer()
        }
        .padding(16).background(Color.white.opacity(0.52), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content().padding(28).background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(StudioTheme.line.opacity(0.7)) }
            .shadow(color: StudioTheme.shadowStrong, radius: 14, x: 0, y: 8)
    }

    private func copy(_ key: String, fallback: String) -> String { guessWhoLocalized(key, fallback: fallback) }
    private func startTapped() { if gameState.hasRoundInProgress { showsNewGameConfirmation = true } else { gameState.startNewGame() } }
}
