import SwiftUI

/// Entry menu for the Alias feature while gameplay is still being designed.
struct AliasHomeScreen: View {
    @EnvironmentObject private var gameState: GameState

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                header
                menuCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 72)
            .padding(.bottom, 28)
        }
    }

    private var header: some View {
        HStack {
            Text(copy("game.alias.title", fallback: "Alias"))
                .font(StudioTypography.brandTitle)
                .foregroundStyle(StudioTheme.ink)
            Spacer()
            Button(copy("home.games", fallback: "Games"), action: gameState.showGamePicker)
                .buttonStyle(ActionButtonStyle(kind: .ghost))
        }
    }

    private var menuCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(copy("alias.menu.title", fallback: "Ukrainian word deck"))
                .font(StudioTypography.title)
                .foregroundStyle(StudioTheme.ink)

            Text(copy("alias.menu.message", fallback: "Review the word deck now. Gameplay is coming later."))
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.muted)

            Button(copy("alias.menu.play", fallback: "Play")) {}
                .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
                .disabled(true)
                .opacity(0.48)
                .accessibilityHint(copy("alias.menu.coming_soon", fallback: "Coming soon"))

            Button(copy("alias.menu.review", fallback: "Review"), action: gameState.showAliasReview)
                .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.teal)))
        }
        .padding(24)
        .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(StudioTheme.line.opacity(0.8))
        }
    }

    private func copy(_ key: String, fallback: String) -> String {
        guessWhoLocalized(key, fallback: fallback)
    }
}
