import SwiftUI

/// The catalogue is kept independent from a game's home and gameplay screens.
struct GamePickerScreen: View {
    @EnvironmentObject private var gameState: GameState
    @AppStorage(guessWhoLanguageOverrideKey) private var languageOverride = ""
    @AppStorage(guessWhoPlayerOneNameKey) private var playerOneName = ""
    @AppStorage(guessWhoPlayerTwoNameKey) private var playerTwoName = ""
    @State private var isSettingsPresented = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                card {
                    VStack(spacing: 12) {
                        ForEach(GameState.Game.allCases) { game in
                            gameButton(game)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 72)
            .padding(.bottom, 28)
        }
        .overlay {
            LauncherSettingsDrawer(
                languageOverride: $languageOverride,
                playerOneName: $playerOneName,
                playerTwoName: $playerTwoName,
                isPresented: $isSettingsPresented
            )
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    private func gameButton(_ game: GameState.Game) -> some View {
        Button {
            gameState.selectGame(game)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon(for: game))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(accent(for: game))
                    .frame(width: 42, height: 42)
                    .background(accent(for: game).opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title(for: game))
                        .font(StudioTypography.title)
                        .foregroundStyle(StudioTheme.ink)
                    if !subtitle(for: game).isEmpty {
                        Text(subtitle(for: game))
                            .font(StudioTypography.body)
                            .foregroundStyle(StudioTheme.inkSoft)
                    }
                    if !status(for: game).isEmpty {
                        Text(status(for: game))
                            .font(StudioTypography.footnote)
                            .foregroundStyle(StudioTheme.muted)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!game.isAvailable)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(game.isAvailable ? 0.76 : 0.42), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(StudioTheme.line.opacity(0.7))
        }
        .opacity(game.isAvailable ? 1 : 0.78)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(22)
            .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(StudioTheme.line.opacity(0.8)) }
            .shadow(color: StudioTheme.shadowStrong, radius: 14, x: 0, y: 8)
    }

    private func copy(_ key: String, fallback: String) -> String { guessWhoLocalized(key, fallback: fallback) }
    private func title(for game: GameState.Game) -> String {
        switch game {
        case .guessWho:
            return copy("game.guesswho.title", fallback: "Guess Who")
        case .alias:
            return copy("game.alias.title", fallback: "Alias")
        }
    }

    private func subtitle(for game: GameState.Game) -> String {
        switch game {
        case .guessWho:
            return ""
        case .alias:
            return ""
        }
    }

    private func status(for game: GameState.Game) -> String {
        switch game {
        case .guessWho:
            return ""
        case .alias:
            return ""
        }
    }

    private func icon(for game: GameState.Game) -> String {
        switch game {
        case .guessWho:
            return "person.2.fill"
        case .alias:
            return "text.bubble.fill"
        }
    }

    private func accent(for game: GameState.Game) -> Color {
        switch game {
        case .guessWho:
            return StudioTheme.teal
        case .alias:
            return StudioTheme.gold
        }
    }
}
