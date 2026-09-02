import SwiftUI

/// The catalogue is kept independent from a game's home and gameplay screens.
struct GamePickerScreen: View {
    @EnvironmentObject private var gameState: GameState
    @AppStorage(guessWhoLanguageOverrideKey) private var languageOverride = ""

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                card {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(copy("launcher.title", fallback: "Choose a game"))
                                .font(StudioTypography.displaySmall)
                                .foregroundStyle(StudioTheme.ink)

                            Text(copy("launcher.subtitle", fallback: "Start with the live game now and leave room for the next one."))
                                .font(StudioTypography.body)
                                .foregroundStyle(StudioTheme.muted)
                        }

                        HomeLanguagePicker(
                            selectedLanguage: GuessWhoLanguage.resolved(override: languageOverride),
                            label: copy("home.language.label", fallback: "Language"),
                            englishTitle: copy("home.language.english", fallback: "English"),
                            ukrainianTitle: copy("home.language.ukrainian", fallback: "Ukrainian"),
                            onSelect: { languageOverride = $0.rawValue }
                        )
                    }
                }

                ForEach(GameState.Game.allCases) { game in
                    gameCard(game)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 72)
            .padding(.bottom, 28)
        }
    }

    private func gameCard(_ game: GameState.Game) -> some View {
        card {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: icon(for: game))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(accent(for: game))
                        .frame(width: 46, height: 46)
                        .background(accent(for: game).opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title(for: game))
                            .font(StudioTypography.title)
                            .foregroundStyle(StudioTheme.ink)
                        Text(description(for: game))
                            .font(StudioTypography.footnote)
                            .foregroundStyle(StudioTheme.muted)
                    }
                    Spacer(minLength: 0)
                }

                HStack {
                    Text(status(for: game))
                        .font(StudioTypography.compactLabel)
                        .foregroundStyle(accent(for: game))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(accent(for: game).opacity(0.12), in: Capsule())
                    Spacer()
                    if game.isAvailable {
                        Button(copy("launcher.open", fallback: "Open")) {
                            gameState.selectGame(game)
                        }
                        .buttonStyle(ActionButtonStyle(kind: .filled(accent(for: game))))
                    }
                }
            }
        }
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(22)
            .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(StudioTheme.line.opacity(0.8)) }
            .shadow(color: StudioTheme.shadowStrong, radius: 14, x: 0, y: 8)
    }

    private func copy(_ key: String, fallback: String) -> String { guessWhoLocalized(key, fallback: fallback) }
    private func title(for game: GameState.Game) -> String { copy(game == .guessWho ? "game.guess_who.title" : "game.next.title", fallback: game == .guessWho ? "Guess Who" : "Next game") }
    private func description(for game: GameState.Game) -> String { copy(game == .guessWho ? "game.guess_who.description" : "game.next.description", fallback: game == .guessWho ? "Two players, one phone, one secret face." : "A new game will live here soon.") }
    private func status(for game: GameState.Game) -> String { copy(game.isAvailable ? "launcher.available" : "launcher.coming_soon", fallback: game.isAvailable ? "Ready to play" : "Coming soon") }
    private func icon(for game: GameState.Game) -> String { game == .guessWho ? "person.2.fill" : "sparkles" }
    private func accent(for game: GameState.Game) -> Color { game == .guessWho ? StudioTheme.teal : StudioTheme.gold }
}
