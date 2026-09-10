import SwiftUI

/// Entry menu and match setup for the Alias feature.
struct AliasHomeScreen: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var aliasGameState: AliasGameState
    @AppStorage(AliasGameState.targetScoreKey) private var targetScore = AliasGameState.defaultTargetScore
    @AppStorage(AliasVocabulary.includeAdjectivesKey) private var includeAdjectives = true
    @State private var showsNewMatchConfirmation = false

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
        .alert(copy("alias.menu.alert.title", fallback: "Start a new match?"), isPresented: $showsNewMatchConfirmation) {
            Button(copy("home.alert.cancel", fallback: "Cancel"), role: .cancel) {}
            Button(copy("alias.menu.new_match", fallback: "New Match"), role: .destructive, action: startMatch)
        } message: {
            Text(copy("alias.menu.alert.message", fallback: "The current Alias match will be cleared."))
        }
        .onAppear {
            if !AliasGameState.targetScoreOptions.contains(targetScore) {
                targetScore = AliasGameState.defaultTargetScore
            }
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
            Text(copy("alias.menu.title", fallback: "Competitive Alias"))
                .font(StudioTypography.title)
                .foregroundStyle(StudioTheme.ink)

            Text(copy("alias.menu.message", fallback: "Take turns explaining Ukrainian words. First to the goal wins after equal turns."))
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.muted)

            goalPicker

            if aliasGameState.canResume {
                Button(copy("alias.menu.resume", fallback: "Resume Match")) {
                    gameState.showAliasGame()
                }
                .buttonStyle(ActionButtonStyle(kind: .outlined(StudioTheme.teal)))
            }

            Button(copy("alias.menu.new_match", fallback: "New Match"), action: newMatchTapped)
                .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))

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

    private var goalPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(copy("alias.menu.goal", fallback: "Goal score"))
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.ink)

            HStack(spacing: 8) {
                ForEach(AliasGameState.targetScoreOptions, id: \.self) { option in
                    Button(String(option)) {
                        targetScore = option
                    }
                    .font(StudioTypography.label)
                    .foregroundStyle(targetScore == option ? Color.white : StudioTheme.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        targetScore == option ? StudioTheme.teal : Color.white.opacity(0.72),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                    .buttonStyle(.plain)
                    .accessibilityLabel(copy("alias.menu.goal.option", fallback: "%d points", option))
                    .accessibilityAddTraits(targetScore == option ? .isSelected : [])
                }
            }
        }
    }

    private func newMatchTapped() {
        if aliasGameState.canResume {
            showsNewMatchConfirmation = true
        } else {
            startMatch()
        }
    }

    private func startMatch() {
        aliasGameState.startMatch(targetScore: targetScore, includeAdjectives: includeAdjectives)
        gameState.showAliasGame()
    }

    private func copy(_ key: String, fallback: String) -> String {
        guessWhoLocalized(key, fallback: fallback)
    }

    private func copy(_ key: String, fallback: String, _ value: Int) -> String {
        guessWhoLocalizedFormat(key, fallback: fallback, value)
    }
}
