import Combine
import SwiftUI

struct AliasGameplayScreen: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var aliasGameState: AliasGameState
    @AppStorage(guessWhoPlayerOneNameKey) private var storedPlayerOneName = ""
    @AppStorage(guessWhoPlayerTwoNameKey) private var storedPlayerTwoName = ""

    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            switch aliasGameState.phase {
            case .idle:
                emptyState
            case .loading:
                loadingState
            case .handoff(let player):
                handoffState(player)
            case .ready(let player):
                readyState(player)
            case .playing(let player):
                playingState(player)
            case .turnResult(let player):
                turnResultState(player)
            case .matchOver(let winner):
                matchOverState(winner)
            case .deckUnavailable:
                deckUnavailableState
            }
        }
        .onReceive(timer) { date in
            aliasGameState.tick(now: date)
        }
    }

    private var emptyState: some View {
        messageScreen(
            icon: "text.bubble.fill",
            title: copy("alias.game.empty.title", fallback: "No active match"),
            message: copy("alias.game.empty.message", fallback: "Return to the Alias menu to start one.")
        ) {
            menuButton
        }
    }

    private var loadingState: some View {
        messageScreen(
            icon: "text.book.closed.fill",
            title: copy("alias.game.loading.title", fallback: "Shuffling words"),
            message: copy("alias.game.loading.message", fallback: "Preparing the offline deck…")
        ) {
            ProgressView().tint(StudioTheme.teal)
        }
    }

    private func handoffState(_ player: GameState.Player) -> some View {
        messageScreen(
            icon: "hand.raised.fill",
            title: copy("alias.game.handoff.title", fallback: "Pass the phone to %@", playerName(player)),
            message: copy("alias.game.handoff.message", fallback: "Only the explainer should see the next word.")
        ) {
            Button(copy("alias.game.handoff.cta", fallback: "I am %@", playerName(player))) {
                aliasGameState.acknowledgeHandoff()
            }
            .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
        }
    }

    private func readyState(_ player: GameState.Player) -> some View {
        contentScreen {
            header(title: playerName(player), subtitle: copy("alias.game.ready.role", fallback: "You explain this turn"))
            scoreBoard
            card {
                VStack(spacing: 16) {
                    Image(systemName: "timer")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(StudioTheme.teal)
                    Text(copy("alias.game.ready.title", fallback: "60 seconds"))
                        .font(StudioTypography.titleLarge)
                        .foregroundStyle(StudioTheme.ink)
                    Text(copy("alias.game.ready.message", fallback: "Describe each word without saying it. Tap Correct or Skip, then continue immediately."))
                        .font(StudioTypography.body)
                        .foregroundStyle(StudioTheme.muted)
                        .multilineTextAlignment(.center)
                    Button(copy("alias.game.ready.cta", fallback: "Start Turn")) {
                        aliasGameState.startTurn()
                    }
                        .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
                }
            }
            menuButton
        }
    }

    private func playingState(_ player: GameState.Player) -> some View {
        contentScreen {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(playerName(player))
                        .font(StudioTypography.title)
                        .foregroundStyle(StudioTheme.ink)
                    Text(copy("alias.game.playing.role", fallback: "Explaining"))
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)
                }
                Spacer()
                Text(timeText)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(aliasGameState.secondsRemaining <= 10 ? StudioTheme.coral : StudioTheme.teal)
                    .accessibilityLabel(copy("alias.game.timer.accessibility", fallback: "%d seconds remaining", aliasGameState.secondsRemaining))
            }

            scoreBoard

            card {
                VStack(spacing: 14) {
                    Text(aliasGameState.currentWord?.text ?? "—")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(StudioTheme.ink)
                        .minimumScaleFactor(0.55)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 180)

                    Text(copy("alias.game.turn_score", fallback: "Turn score: %@", signed(aliasGameState.turnScore)))
                        .font(StudioTypography.label)
                        .foregroundStyle(aliasGameState.turnScore < 0 ? StudioTheme.coral : StudioTheme.teal)
                }
            }

            HStack(spacing: 12) {
                Button(copy("alias.game.skip", fallback: "Skip −1")) {
                    aliasGameState.skipWord()
                }
                    .buttonStyle(ActionButtonStyle(kind: .outlined(StudioTheme.coral)))
                Button(copy("alias.game.correct", fallback: "Correct +1")) {
                    aliasGameState.markCorrect()
                }
                    .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.teal)))
            }
        }
    }

    private func turnResultState(_ player: GameState.Player) -> some View {
        contentScreen {
            header(
                title: copy("alias.game.result.title", fallback: "%@’s turn is over", playerName(player)),
                subtitle: copy("alias.game.result.round", fallback: "Round %d", aliasGameState.roundNumber)
            )
            scoreBoard
            card {
                VStack(spacing: 16) {
                    resultRow(copy("alias.game.result.correct", fallback: "Correct"), value: aliasGameState.correctCount, color: StudioTheme.teal)
                    resultRow(copy("alias.game.result.skipped", fallback: "Skipped"), value: aliasGameState.skippedCount, color: StudioTheme.coral)
                    Divider()
                    HStack {
                        Text(copy("alias.game.result.turn_score", fallback: "Turn score"))
                        Spacer()
                        Text(signed(aliasGameState.turnScore))
                    }
                    .font(StudioTypography.title)
                    .foregroundStyle(StudioTheme.ink)
                }
            }
            Button(copy("alias.game.result.continue", fallback: "Continue"), action: aliasGameState.continueAfterTurn)
                .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
            menuButton
        }
    }

    private func matchOverState(_ winner: GameState.Player) -> some View {
        contentScreen {
            header(
                title: copy("alias.game.over.title", fallback: "%@ wins", playerName(winner)),
                subtitle: copy("alias.game.over.message", fallback: "Both players completed the same number of turns.")
            )
            scoreBoard
            Button(copy("alias.game.over.rematch", fallback: "Rematch")) {
                aliasGameState.startMatch(
                    targetScore: aliasGameState.configuration.targetScore,
                    includeAdjectives: aliasGameState.configuration.includeAdjectives
                )
            }
            .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
            menuButton
        }
    }

    private var deckUnavailableState: some View {
        messageScreen(
            icon: "exclamationmark.triangle.fill",
            title: copy("alias.game.deck_error.title", fallback: "Words unavailable"),
            message: copy("alias.game.deck_error.message", fallback: "The offline word deck could not be loaded.")
        ) {
            menuButton
        }
    }

    private var scoreBoard: some View {
        HStack(spacing: 10) {
            scoreTile(.one, accent: StudioTheme.teal)
            VStack(spacing: 2) {
                Text(copy("alias.game.goal", fallback: "GOAL"))
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(StudioTheme.muted)
                Text(String(aliasGameState.configuration.targetScore))
                    .font(StudioTypography.title)
                    .foregroundStyle(StudioTheme.ink)
            }
            .frame(width: 58)
            scoreTile(.two, accent: StudioTheme.coral)
        }
    }

    private func scoreTile(_ player: GameState.Player, accent: Color) -> some View {
        VStack(spacing: 5) {
            Text(playerName(player))
                .font(StudioTypography.footnote)
                .foregroundStyle(StudioTheme.muted)
                .lineLimit(1)
            Text(String(aliasGameState.score(for: player)))
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(accent)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var menuButton: some View {
        Button(copy("common.menu", fallback: "Menu")) {
            aliasGameState.returnToMenu()
            gameState.showMenu()
        }
        .buttonStyle(ActionButtonStyle(kind: .ghost))
    }

    private func header(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if aliasGameState.isOvertime {
                Text(copy("alias.game.overtime", fallback: "OVERTIME"))
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(StudioTheme.coral)
            }
            Text(title)
                .font(StudioTypography.displaySmall)
                .foregroundStyle(StudioTheme.ink)
            Text(subtitle)
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func resultRow(_ title: String, value: Int, color: Color) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(String(value)).monospacedDigit()
        }
        .font(StudioTypography.subheadline)
        .foregroundStyle(color)
    }

    private func contentScreen<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18, content: content)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 36)
        }
    }

    private func messageScreen<Content: View>(
        icon: String,
        title: String,
        message: String,
        @ViewBuilder action: () -> Content
    ) -> some View {
        VStack(spacing: 22) {
            Spacer()
            card {
                VStack(spacing: 18) {
                    Image(systemName: icon)
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(StudioTheme.coral)
                    Text(title)
                        .font(StudioTypography.displaySmall)
                        .foregroundStyle(StudioTheme.ink)
                        .multilineTextAlignment(.center)
                    Text(message)
                        .font(StudioTypography.body)
                        .foregroundStyle(StudioTheme.muted)
                        .multilineTextAlignment(.center)
                    action()
                }
            }
            Spacer()
        }
        .padding(24)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(StudioTheme.line.opacity(0.8))
            }
            .shadow(color: StudioTheme.shadowSoft, radius: 12, x: 0, y: 7)
    }

    private var timeText: String {
        String(format: "0:%02d", aliasGameState.secondsRemaining)
    }

    private func signed(_ value: Int) -> String {
        value > 0 ? "+\(value)" : String(value)
    }

    private func playerName(_ player: GameState.Player) -> String {
        let stored = (player == .one ? storedPlayerOneName : storedPlayerTwoName)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !stored.isEmpty { return stored }
        return player == .one
            ? copy("home.player.one", fallback: "Player 1")
            : copy("home.player.two", fallback: "Player 2")
    }

    private func copy(_ key: String, fallback: String) -> String {
        guessWhoLocalized(key, fallback: fallback)
    }

    private func copy(_ key: String, fallback: String, _ value: CVarArg) -> String {
        guessWhoLocalizedFormat(key, fallback: fallback, value)
    }
}
