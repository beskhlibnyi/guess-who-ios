import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var gameState: GameState
    @AppStorage(guessWhoLanguageOverrideKey) private var homeLanguageOverride = ""
    @State private var showsNewGameConfirmation = false

    private let columns = [
        GridItem(.adaptive(minimum: 156), spacing: 16, alignment: .top)
    ]

    private var homeAlertTitle: String {
        localizedHomeCopy("home.alert.title", fallback: "Start a new game?")
    }

    private var homeAlertCancel: String {
        localizedHomeCopy("home.alert.cancel", fallback: "Cancel")
    }

    private var homeAlertConfirm: String {
        localizedHomeCopy("home.alert.confirm", fallback: "Start New Game")
    }

    private var homeAlertMessage: String {
        localizedHomeCopy(
            "home.alert.message",
            fallback: "This clears the current round, both secret picks, and every eliminated card."
        )
    }

    private var homeTitle: String {
        localizedHomeCopy("home.title", fallback: "GuessWho")
    }

    private var homeOverview: String {
        localizedHomeCopy("home.overview", fallback: "Offline pass-and-play for two players on one iPhone.")
    }

    private var homeSummary: String {
        localizedHomeCopy(
            "home.summary",
            fallback: "Pick secret characters, ask smart yes-or-no questions, and make the final guess."
        )
    }

    private var homeStartTitle: String {
        localizedHomeCopy("home.start", fallback: "Start New Game")
    }

    private var homeResumeTitle: String {
        localizedHomeCopy("home.resume", fallback: "Resume Game")
    }

    private var homeRulesTitle: String {
        localizedHomeCopy("home.rules", fallback: "How to Play")
    }

    private var homeRoundInProgressTitle: String {
        localizedHomeCopy("home.live_round.title", fallback: "Round in progress")
    }

    private var homeFooter: String {
        localizedHomeCopy("home.footer", fallback: "© 2026 GuessWho")
    }

    private var rulesPageTitle: String {
        localizedHomeCopy("rules.title", fallback: "How to Play")
    }

    private var rulesPageSubtitle: String {
        localizedHomeCopy(
            "rules.subtitle",
            fallback: "A round is simple: pick privately, ask or guess, pass the phone, and repeat."
        )
    }

    private var rulesHomeButtonTitle: String {
        localizedHomeCopy("rules.home", fallback: "Home")
    }

    private var rulesStepOneTitle: String {
        localizedHomeCopy("rules.step1.title", fallback: "Pick a secret in private")
    }

    private var rulesStepOneMessage: String {
        localizedHomeCopy(
            "rules.step1.message",
            fallback: "Player 1 picks first, passes the phone, then Player 2 picks privately."
        )
    }

    private var rulesStepTwoTitle: String {
        localizedHomeCopy("rules.step2.title", fallback: "Choose one path each turn")
    }

    private var rulesStepTwoMessage: String {
        localizedHomeCopy(
            "rules.step2.message",
            fallback: "Start with either Ask a Question or Make a Guess."
        )
    }

    private var rulesStepThreeTitle: String {
        localizedHomeCopy("rules.step3.title", fallback: "Ask first, eliminate after")
    }

    private var rulesStepThreeMessage: String {
        localizedHomeCopy(
            "rules.step3.message",
            fallback: "Hear yes or no first, then hide suspects. Guess mode never changes the board."
        )
    }

    private var rulesStepFourTitle: String {
        localizedHomeCopy("rules.step4.title", fallback: "Win with an explicit guess")
    }

    private var rulesStepFourMessage: String {
        localizedHomeCopy(
            "rules.step4.message",
            fallback: "One card left is not enough. You still have to tap the final guess."
        )
    }

    private var menuTitle: String {
        localizedHomeCopy("common.menu", fallback: "Menu")
    }

    private var backTitle: String {
        localizedHomeCopy("common.back", fallback: "Back")
    }

    private var yesTitle: String {
        localizedHomeCopy("common.yes", fallback: "Yes")
    }

    private var noTitle: String {
        localizedHomeCopy("common.no", fallback: "No")
    }

    private var playerChipTitle: String {
        localizedHomeCopy("common.player", fallback: "Player")
    }

    private var leftChipTitle: String {
        localizedHomeCopy("common.left", fallback: "Left")
    }

    private var outChipTitle: String {
        localizedHomeCopy("common.out", fallback: "Out")
    }

    private var suspectsLeftTitle: String {
        localizedHomeCopy("common.suspects_left", fallback: "Suspects Left")
    }

    private var eliminatedTitle: String {
        localizedHomeCopy("common.eliminated", fallback: "Eliminated")
    }

    private var unknownTitle: String {
        localizedHomeCopy("common.unknown", fallback: "Unknown")
    }

    private var privatePickLabel: String {
        localizedHomeCopy("screen.secret.label", fallback: "Private Pick")
    }

    private var privacyHandoffLabel: String {
        localizedHomeCopy("screen.handoff.label", fallback: "Privacy Handoff")
    }

    private var startMyTurnTitle: String {
        localizedHomeCopy("screen.handoff.cta", fallback: "Start My Turn")
    }

    private var turnStartLabel: String {
        localizedHomeCopy("screen.turn.label", fallback: "Turn Start")
    }

    private var askTitle: String {
        localizedHomeCopy("screen.turn.ask.title", fallback: "Ask a Question")
    }

    private var askSubtitle: String {
        localizedHomeCopy("screen.turn.ask.subtitle", fallback: "Safer turn")
    }

    private var askMessage: String {
        localizedHomeCopy(
            "screen.turn.ask.message",
            fallback: "Say the question out loud, hear one answer, then update the board."
        )
    }

    private var askConsequence: String {
        localizedHomeCopy(
            "screen.turn.ask.consequence",
            fallback: "Elimination only begins after a Yes or No answer."
        )
    }

    private var chooseAskTitle: String {
        localizedHomeCopy("screen.turn.ask.cta", fallback: "Choose Ask")
    }

    private var guessSubtitle: String {
        localizedHomeCopy("screen.turn.guess.subtitle", fallback: "Risky turn")
    }

    private var guessConsequence: String {
        localizedHomeCopy("screen.turn.guess.consequence", fallback: "A wrong guess ends the turn at once.")
    }

    private var answerPrivacyTitle: String {
        localizedHomeCopy("screen.answer.notice.title", fallback: "Answer step")
    }

    private var answerPrivacyMessage: String {
        localizedHomeCopy(
            "screen.answer.notice.message",
            fallback: "The board stays locked until the other player gives one Yes or No answer."
        )
    }

    private var askModeLabel: String {
        localizedHomeCopy("screen.answer.label", fallback: "Ask Mode")
    }

    private var answerInstruction: String {
        localizedHomeCopy(
            "screen.answer.instruction",
            fallback: "When the other player answers, tap the matching button to unlock elimination."
        )
    }

    private var donePassPhoneTitle: String {
        localizedHomeCopy("screen.elimination.cta", fallback: "Done, Pass Phone")
    }

    private var finalGuessLabel: String {
        localizedHomeCopy("screen.guess.label", fallback: "Final Guess")
    }

    private var finalGuessTitle: String {
        localizedHomeCopy("screen.guess.title", fallback: "Tap one portrait to submit your guess")
    }

    private var finalGuessMessage: String {
        localizedHomeCopy(
            "screen.guess.message",
            fallback: "This is the only action for the turn now. A wrong guess ends the turn immediately."
        )
    }

    private var finalGuessBackoutMessage: String {
        localizedHomeCopy(
            "screen.guess.backout",
            fallback: "Need to back out before committing? Switch back now."
        )
    }

    private var chooseAskInsteadTitle: String {
        localizedHomeCopy("screen.guess.back", fallback: "Choose Ask Instead")
    }

    private var roundResultLabel: String {
        localizedHomeCopy("screen.result.label", fallback: "Round Result")
    }

    private var backToHomeTitle: String {
        localizedHomeCopy("screen.result.home", fallback: "Back to Home")
    }

    private var homeLanguageLabel: String {
        localizedHomeCopy("home.language.label", fallback: "Language")
    }

    private var homeLanguageEnglishTitle: String {
        localizedHomeCopy("home.language.english", fallback: "English")
    }

    private var homeLanguageUkrainianTitle: String {
        localizedHomeCopy("home.language.ukrainian", fallback: "Ukrainian")
    }

    private var activeHomeLanguage: GuessWhoLanguage {
        GuessWhoLanguage.resolved(override: homeLanguageOverride)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer

                switch gameState.appScreen {
                case .menu:
                    menuScreen
                case .rules:
                    rulesScreen
                case .game:
                    gameScreen
                }
            }
            .id(activeHomeLanguage.rawValue)
            .toolbar(.hidden, for: .navigationBar)
        }
        .alert(homeAlertTitle, isPresented: $showsNewGameConfirmation) {
            Button(homeAlertCancel, role: .cancel) {}
            Button(homeAlertConfirm, role: .destructive) {
                gameState.startNewGame()
            }
        } message: {
            Text(homeAlertMessage)
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [StudioTheme.canvasTop, StudioTheme.canvasBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(StudioTheme.gold.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 10)
                .offset(x: 150, y: -280)

            Circle()
                .fill(StudioTheme.coral.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 18)
                .offset(x: -150, y: 290)

            Circle()
                .fill(StudioTheme.teal.opacity(0.11))
                .frame(width: 240, height: 240)
                .blur(radius: 18)
                .offset(x: 170, y: 360)
        }
    }

    private var menuScreen: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                menuHero

                if gameState.hasRoundInProgress {
                    liveRoundPanel
                }

                Text(homeFooter)
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(StudioTheme.muted)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 72)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity)
        }
    }

    private var menuHero: some View {
        surface(fill: StudioTheme.card, border: StudioTheme.line.opacity(0.8), shadow: StudioTheme.shadowStrong) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(homeTitle)
                        .font(StudioTypography.displaySmall)
                        .foregroundStyle(StudioTheme.ink)

                    Text(homeOverview)
                        .font(StudioTypography.subheadline)
                        .foregroundStyle(StudioTheme.inkSoft)

                    Text(homeSummary)
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 12) {
                    menuButton(
                        title: homeStartTitle,
                        systemImage: "play.fill",
                        style: .filled(StudioTheme.coral),
                        action: handleStartNewGameTapped
                    )

                    if gameState.hasRoundInProgress {
                        menuButton(
                            title: homeResumeTitle,
                            systemImage: "arrow.clockwise.circle.fill",
                            style: .outlined(StudioTheme.teal),
                            action: gameState.resumeGame
                        )
                    }

                    menuButton(
                        title: homeRulesTitle,
                        systemImage: "questionmark.circle",
                        style: .ghost,
                        action: gameState.showRules
                    )
                }

                homeLanguageToggle
            }
        }
    }

    private var liveRoundPanel: some View {
        surface(padding: 16, fill: Color.white.opacity(0.72), border: StudioTheme.line.opacity(0.65), shadow: .clear) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text(homeRoundInProgressTitle)
                        .font(StudioTypography.subheadline)
                        .foregroundStyle(StudioTheme.ink)

                    Spacer()

                    Text(homePlayerLabel(for: gameState.currentPlayer))
                        .font(StudioTypography.compactLabel)
                        .foregroundStyle(StudioTheme.teal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(StudioTheme.teal.opacity(0.1))
                        .clipShape(Capsule())
                }

                Text(homeLiveRoundMessage)
                    .font(StudioTypography.footnote)
                    .foregroundStyle(StudioTheme.muted)
            }
        }
    }

    private var rulesScreen: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                surface(padding: 28, fill: StudioTheme.card, border: StudioTheme.line.opacity(0.7), shadow: StudioTheme.shadowStrong) {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(rulesPageTitle)
                                    .font(StudioTypography.displaySmall)
                                    .foregroundStyle(StudioTheme.ink)

                                Text(rulesPageSubtitle)
                                    .font(StudioTypography.subheadline)
                                    .foregroundStyle(StudioTheme.muted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            compactMenuButton(rulesHomeButtonTitle, systemImage: "house", action: gameState.showMenu)
                        }

                        VStack(spacing: 10) {
                            ruleStep(
                                number: "1",
                                title: rulesStepOneTitle,
                                message: rulesStepOneMessage
                            )
                            ruleStep(
                                number: "2",
                                title: rulesStepTwoTitle,
                                message: rulesStepTwoMessage
                            )
                            ruleStep(
                                number: "3",
                                title: rulesStepThreeTitle,
                                message: rulesStepThreeMessage
                            )
                            ruleStep(
                                number: "4",
                                title: rulesStepFourTitle,
                                message: rulesStepFourMessage
                            )
                        }

                        VStack(spacing: 12) {
                            if gameState.hasRoundInProgress {
                                menuButton(
                                    title: homeResumeTitle,
                                    systemImage: "arrow.clockwise.circle.fill",
                                    style: .outlined(StudioTheme.teal),
                                    action: gameState.resumeGame
                                )
                            }

                            menuButton(
                                title: homeStartTitle,
                                systemImage: "play.fill",
                                style: .filled(StudioTheme.coral),
                                action: handleStartNewGameTapped
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
    }

    @ViewBuilder
    private var gameScreen: some View {
        switch gameState.phase {
        case .selectingSecret(let player):
            secretSelectionScreen(for: player)
        case .handoff(_, let toPlayer, let reason):
            handoffScreen(to: toPlayer, reason: reason)
        case .choosingTurnAction(let player):
            turnChoiceScreen(for: player)
        case .awaitingAnswer(let player):
            answerStepScreen(for: player)
        case .eliminating(let player, let answer):
            eliminationScreen(for: player, answer: answer)
        case .guessing(let player):
            gameplayBoardScreen(
                for: player,
                label: finalGuessLabel,
                title: finalGuessTitle,
                message: finalGuessMessage,
                accent: StudioTheme.coral,
                mode: .guess
            ) {
                VStack(spacing: 10) {
                    Text(finalGuessBackoutMessage)
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)
                        .multilineTextAlignment(.center)

                    menuButton(
                        title: chooseAskInsteadTitle,
                        systemImage: "chevron.left",
                        style: .ghost,
                        action: gameState.returnToTurnChoice
                    )
                }
            }
        case .gameOver(let winner, let reason):
            gameOverScreen(winner: winner, reason: reason)
        }
    }

    private func secretSelectionScreen(for player: GameState.Player) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                privacyNotice(
                    title: secretPrivacyTitle(for: player),
                    message: secretPrivacyMessage,
                    accent: StudioTheme.teal
                )

                stageHeader(
                    label: privatePickLabel,
                    title: secretStageTitle(for: player),
                    message: secretStageMessage,
                    accent: StudioTheme.teal,
                    player: nil
                )

                characterBoard(for: player, mode: .selectSecret)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 34)
        }
    }

    private func handoffScreen(
        to player: GameState.Player,
        reason: GameState.HandoffReason
    ) -> some View {
        ZStack {
            LinearGradient(
                colors: [StudioTheme.handoffTop, StudioTheme.handoffBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(StudioTheme.gold.opacity(0.14))
                .frame(width: 260, height: 260)
                .blur(radius: 8)
                .offset(x: 120, y: -240)

            VStack(spacing: 28) {
                Spacer()

                surface(padding: 28, fill: StudioTheme.handoffCard, border: StudioTheme.handoffLine, shadow: StudioTheme.shadowStrong) {
                    VStack(spacing: 22) {
                        ZStack {
                            Circle()
                                .fill(StudioTheme.coral.opacity(0.16))
                                .frame(width: 84, height: 84)

                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(StudioTheme.coral)
                        }

                        VStack(spacing: 10) {
                            capsuleLabel(privacyHandoffLabel.uppercased(), accent: StudioTheme.gold)

                            Text(handoffTitle(for: player, reason: reason))
                                .font(StudioTypography.displaySmall)
                                .foregroundStyle(StudioTheme.ink)
                                .multilineTextAlignment(.center)

                            Text(handoffMessage(for: player, reason: reason))
                                .font(StudioTypography.body)
                                .foregroundStyle(StudioTheme.inkSoft)
                                .multilineTextAlignment(.center)
                        }

                        Text(onlyPlayerContinueTitle(for: player))
                            .font(StudioTypography.subheadline)
                            .foregroundStyle(StudioTheme.muted)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(StudioTheme.softWash)
                            .clipShape(Capsule())

                        menuButton(
                            title: startMyTurnTitle,
                            systemImage: "person.fill.checkmark",
                            style: .filled(StudioTheme.coral),
                            action: gameState.continueAfterHandoff
                        )
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
    }

    private func turnChoiceScreen(for player: GameState.Player) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                stageHeader(
                    label: turnStartLabel,
                    title: turnChoiceTitle(for: player),
                    message: turnChoiceMessage(for: player),
                    accent: StudioTheme.teal,
                    player: player
                )

                decisionCard(
                    title: askTitle,
                    subtitle: askSubtitle,
                    message: askMessage,
                    accent: StudioTheme.teal,
                    systemImage: "text.bubble.fill",
                    consequence: askConsequence,
                    buttonTitle: chooseAskTitle,
                    buttonStyle: .filled(StudioTheme.teal),
                    action: gameState.chooseAskQuestion
                )

                decisionCard(
                    title: guessDecisionTitle(for: player),
                    subtitle: guessSubtitle,
                    message: guessDecisionMessage(for: player),
                    accent: StudioTheme.coral,
                    systemImage: "scope",
                    consequence: guessConsequence,
                    buttonTitle: guessDecisionButtonTitle(for: player),
                    buttonStyle: .outlined(StudioTheme.coral),
                    action: gameState.chooseMakeGuess
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 34)
        }
    }

    private func answerStepScreen(for player: GameState.Player) -> some View {
        VStack(spacing: 24) {
            privacyNotice(
                title: answerPrivacyTitle,
                message: answerPrivacyMessage,
                accent: StudioTheme.teal
            )

            Spacer(minLength: 0)

            surface(fill: StudioTheme.card, border: StudioTheme.line.opacity(0.9), shadow: StudioTheme.shadowStrong) {
                VStack(alignment: .leading, spacing: 18) {
                    capsuleLabel(askModeLabel.uppercased(), accent: StudioTheme.teal)

                    Text(answerStepTitle(for: player))
                        .font(StudioTypography.displaySmall)
                        .foregroundStyle(StudioTheme.ink)

                    Text(answerInstruction)
                        .font(StudioTypography.body)
                        .foregroundStyle(StudioTheme.muted)

                    HStack(spacing: 12) {
                        summaryChip(title: playerChipTitle, value: playerName(player), accent: StudioTheme.teal)
                        summaryChip(
                            title: suspectsLeftTitle,
                            value: "\(gameState.remainingCharacters(for: player).count)",
                            accent: StudioTheme.gold
                        )
                    }
                }
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    menuButton(
                        title: yesTitle,
                        systemImage: "checkmark.circle.fill",
                        style: .filled(StudioTheme.teal),
                        action: { gameState.recordAnswer(true) }
                    )

                    menuButton(
                        title: noTitle,
                        systemImage: "xmark.circle.fill",
                        style: .filled(StudioTheme.coral),
                        action: { gameState.recordAnswer(false) }
                    )
                }

                menuButton(
                    title: backTitle,
                    systemImage: "chevron.left",
                    style: .ghost,
                    action: gameState.returnToTurnChoice
                )
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 28)
    }

    private func eliminationScreen(
        for player: GameState.Player,
        answer: Bool
    ) -> some View {
        gameplayBoardScreen(
            for: player,
            label: eliminationLabel(for: answer),
            title: eliminationTitle(for: answer),
            message: eliminationMessage(for: player, answer: answer),
            accent: answer ? StudioTheme.teal : StudioTheme.coral,
            mode: .eliminate
        ) {
            VStack(spacing: 10) {
                if gameState.remainingCharacters(for: player).count == 1 {
                    Text(eliminationFinalGuessReminder)
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)
                        .multilineTextAlignment(.center)
                }

                menuButton(
                    title: donePassPhoneTitle,
                    systemImage: "arrow.right.circle.fill",
                    style: .filled(StudioTheme.coral),
                    action: gameState.passTurn
                )
            }
        }
    }

    private func gameplayBoardScreen<Footer: View>(
        for player: GameState.Player,
        label: String,
        title: String,
        message: String,
        accent: Color,
        mode: CharacterCard.Mode,
        @ViewBuilder footer: @escaping () -> Footer
    ) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                gameplayHeader(
                    player: player,
                    label: label,
                    title: title,
                    message: message,
                    accent: accent
                )

                characterBoard(for: player, mode: mode)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 150)
        }
        .safeAreaInset(edge: .bottom) {
            footerBar(content: footer)
        }
    }

    private func gameOverScreen(
        winner: GameState.Player,
        reason: GameState.EndReason
    ) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                stageHeader(
                    label: roundResultLabel,
                    title: gameOverTitle(for: winner),
                    message: gameOverMessage(for: reason),
                    accent: StudioTheme.coral,
                    player: nil
                )

                HStack(spacing: 12) {
                    summaryChip(title: playerOneSecretTitle, value: gameState.secretCharacter(for: .one)?.name ?? unknownTitle, accent: StudioTheme.teal)
                    summaryChip(title: playerTwoSecretTitle, value: gameState.secretCharacter(for: .two)?.name ?? unknownTitle, accent: StudioTheme.coral)
                }

                characterBoard(for: winner, mode: .reveal)

                VStack(spacing: 12) {
                    menuButton(
                        title: homeStartTitle,
                        systemImage: "arrow.clockwise",
                        style: .filled(StudioTheme.coral),
                        action: gameState.startNewGame
                    )

                    menuButton(
                        title: backToHomeTitle,
                        systemImage: "house",
                        style: .ghost,
                        action: gameState.showMenu
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 34)
        }
    }

    private func stageHeader(
        label: String,
        title: String,
        message: String,
        accent: Color,
        player: GameState.Player?
    ) -> some View {
        surface(fill: StudioTheme.card, border: accent.opacity(0.16), shadow: StudioTheme.shadowSoft) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        capsuleLabel(label, accent: accent)

                        Text(title)
                            .font(StudioTypography.displaySmall)
                            .foregroundStyle(StudioTheme.ink)
                    }

                    Spacer()

                    compactMenuButton(menuTitle, systemImage: "house", action: gameState.showMenu)
                }

                Text(message)
                    .font(StudioTypography.body)
                    .foregroundStyle(StudioTheme.muted)

                if let player {
                    HStack(spacing: 12) {
                        summaryChip(title: playerChipTitle, value: playerName(player), accent: accent)
                        summaryChip(
                            title: leftChipTitle,
                            value: "\(gameState.remainingCharacters(for: player).count)",
                            accent: StudioTheme.teal
                        )
                        summaryChip(
                            title: outChipTitle,
                            value: "\(gameState.eliminatedCount(for: player))",
                            accent: StudioTheme.coral
                        )
                    }
                }
            }
        }
    }

    private func gameplayHeader(
        player: GameState.Player,
        label: String,
        title: String,
        message: String,
        accent: Color
    ) -> some View {
        surface(fill: StudioTheme.card, border: accent.opacity(0.16), shadow: StudioTheme.shadowSoft) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        capsuleLabel(label, accent: accent)

                        Text(playerName(player))
                            .font(StudioTypography.titleLarge)
                            .foregroundStyle(StudioTheme.ink)

                        Text(title)
                            .font(StudioTypography.title)
                            .foregroundStyle(StudioTheme.ink)
                    }

                    Spacer()

                    compactMenuButton(menuTitle, systemImage: "house", action: gameState.showMenu)
                }

                Text(message)
                    .font(StudioTypography.body)
                    .foregroundStyle(StudioTheme.muted)

                HStack(spacing: 12) {
                    summaryChip(
                        title: suspectsLeftTitle,
                        value: "\(gameState.remainingCharacters(for: player).count)",
                        accent: StudioTheme.teal
                    )
                    summaryChip(
                        title: eliminatedTitle,
                        value: "\(gameState.eliminatedCount(for: player))",
                        accent: StudioTheme.coral
                    )
                }
            }
        }
    }

    private func privacyNotice(
        title: String,
        message: String,
        accent: Color
    ) -> some View {
        surface(fill: accent.opacity(0.1), border: accent.opacity(0.22), shadow: .clear) {
            HStack(alignment: .top, spacing: 12) {
                iconStamp(systemImage: "eye.slash.fill", accent: accent)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(StudioTypography.title)
                        .foregroundStyle(StudioTheme.ink)

                    Text(message)
                        .font(StudioTypography.body)
                        .foregroundStyle(StudioTheme.muted)
                }
            }
        }
    }

    private func featureRow(
        title: String,
        message: String,
        tint: Color,
        icon: String
    ) -> some View {
        surface(fill: StudioTheme.card, border: tint.opacity(0.14), shadow: StudioTheme.shadowSoft) {
            HStack(alignment: .top, spacing: 14) {
                iconStamp(systemImage: icon, accent: tint)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(StudioTypography.title)
                        .foregroundStyle(StudioTheme.ink)

                    Text(message)
                        .font(StudioTypography.body)
                        .foregroundStyle(StudioTheme.muted)
                }
            }
        }
    }

    private func decisionCard(
        title: String,
        subtitle: String,
        message: String,
        accent: Color,
        systemImage: String,
        consequence: String,
        buttonTitle: String,
        buttonStyle: ActionButtonStyle.Kind,
        action: @escaping () -> Void
    ) -> some View {
        surface(fill: StudioTheme.card, border: accent.opacity(0.14), shadow: StudioTheme.shadowSoft) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    iconStamp(systemImage: systemImage, accent: accent)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(subtitle.uppercased())
                            .font(StudioTypography.label)
                            .foregroundStyle(accent)

                        Text(title)
                            .font(StudioTypography.titleLarge)
                            .foregroundStyle(StudioTheme.ink)

                        Text(message)
                            .font(StudioTypography.body)
                            .foregroundStyle(StudioTheme.muted)
                    }
                }

                Text(consequence)
                    .font(StudioTypography.subheadline)
                    .foregroundStyle(StudioTheme.inkSoft)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(accent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                menuButton(
                    title: buttonTitle,
                    systemImage: systemImage,
                    style: buttonStyle,
                    action: action
                )
            }
        }
    }

    private func characterBoard(
        for player: GameState.Player,
        mode: CharacterCard.Mode
    ) -> some View {
        let boardContext = boardContext(for: player, mode: mode)

        return surface(fill: StudioTheme.boardCard, border: StudioTheme.line.opacity(0.8), shadow: StudioTheme.shadowStrong) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    iconStamp(systemImage: boardContext.icon, accent: boardContext.accent)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(boardContext.title)
                            .font(StudioTypography.title)
                            .foregroundStyle(StudioTheme.ink)

                        Text(boardContext.message)
                            .font(StudioTypography.body)
                            .foregroundStyle(StudioTheme.muted)
                    }

                    Spacer()

                    Text(boardCountLabel(for: player))
                        .font(StudioTypography.label)
                        .foregroundStyle(boardContext.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(boardContext.accent.opacity(0.1))
                        .clipShape(Capsule())
                }

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(gameState.characters) { character in
                        CharacterCard(
                            character: character,
                            isEliminated: gameState.isEliminated(character, for: player),
                            mode: mode,
                            onTap: { gameState.handleCharacterTap(character) }
                        )
                    }
                }
            }
        }
    }

    private func footerBar<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(StudioTheme.line)

            VStack(spacing: 12) {
                content()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 20)
            .background(.ultraThinMaterial)
        }
    }

    private func ruleStep(number: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.teal)
                .frame(width: 26)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(StudioTypography.subheadline)
                    .foregroundStyle(StudioTheme.ink)

                Text(message)
                    .font(StudioTypography.footnote)
                    .foregroundStyle(StudioTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.58))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(StudioTheme.line.opacity(0.65), lineWidth: 1)
        }
    }

    private func menuButton(
        title: String,
        systemImage: String,
        style: ActionButtonStyle.Kind,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ActionButtonStyle(kind: style))
    }

    private func compactMenuButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(StudioTypography.compactLabel)
                .foregroundStyle(StudioTheme.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(StudioTheme.softWash)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(StudioTheme.line, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func featureChip(_ title: String) -> some View {
        Text(title)
            .font(StudioTypography.label)
            .foregroundStyle(StudioTheme.inkSoft)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color.white.opacity(0.62))
            .clipShape(Capsule())
    }

    private func capsuleLabel(_ title: String, accent: Color) -> some View {
        Text(title)
            .font(StudioTypography.label)
            .foregroundStyle(accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(accent.opacity(0.1))
            .clipShape(Capsule())
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(StudioTypography.titleLarge)
            .foregroundStyle(StudioTheme.ink)
    }

    private func summaryChip(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.muted)

            Text(value)
                .font(StudioTypography.subheadline)
                .foregroundStyle(StudioTheme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.18), lineWidth: 1)
        }
    }

    private func iconStamp(systemImage: String, accent: Color) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(accent)
            .frame(width: 42, height: 42)
            .background(accent.opacity(0.12))
            .clipShape(Circle())
    }

    private func surface<Content: View>(
        padding: CGFloat = 20,
        fill: Color = StudioTheme.card,
        border: Color = StudioTheme.line,
        shadow: Color = StudioTheme.shadowSoft,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(border, lineWidth: 1)
            }
            .shadow(color: shadow, radius: 18, x: 0, y: 10)
    }

    private var secretsLockedValue: String {
        let locked = [gameState.secretCharacter(for: .one), gameState.secretCharacter(for: .two)]
            .compactMap { $0 }
            .count
        return "\(locked)/2"
    }

    private func boardContext(
        for player: GameState.Player,
        mode: CharacterCard.Mode
    ) -> (title: String, message: String, accent: Color, icon: String) {
        switch mode {
        case .selectSecret:
            return (
                title: localizedHomeCopy("board.secret.title", fallback: "Secret board"),
                message: localizedHomeCopy("board.secret.message", fallback: "Tap one portrait to choose it as your hidden character."),
                accent: StudioTheme.teal,
                icon: "person.crop.square.fill"
            )
        case .eliminate:
            return (
                title: localizedHomeCopy("board.suspect.title", fallback: "Suspect board"),
                message: localizedHomeCopy("board.suspect.message", fallback: "Tap portraits to hide or restore them as you narrow the field."),
                accent: StudioTheme.teal,
                icon: "eye.slash.circle.fill"
            )
        case .guess:
            return (
                title: localizedHomeCopy("board.guess.title", fallback: "Final guess board"),
                message: localizedHomeCopy("board.guess.message", fallback: "Tapping a portrait submits the guess immediately."),
                accent: StudioTheme.coral,
                icon: "scope"
            )
        case .inactive:
            return (
                title: localizedHomeCopy("board.default.title", fallback: "Board"),
                message: guessWhoLocalizedFormat("board.default.message", fallback: "%@'s portraits.", playerName(player)),
                accent: StudioTheme.gold,
                icon: "square.grid.2x2.fill"
            )
        case .reveal:
            return (
                title: localizedHomeCopy("board.result.title", fallback: "Final board"),
                message: localizedHomeCopy("board.result.message", fallback: "The round is over. Remaining portraits show the winner's final view."),
                accent: StudioTheme.gold,
                icon: "sparkles"
            )
        }
    }

    private func handleStartNewGameTapped() {
        if gameState.hasRoundInProgress {
            showsNewGameConfirmation = true
        } else {
            gameState.startNewGame()
        }
    }

    private var homeLiveRoundMessage: String {
        let format = localizedHomeCopy(
            "home.live_round.message",
            fallback: "%@ secrets locked. Resume if you want to keep playing."
        )
        return String.localizedStringWithFormat(format, secretsLockedValue)
    }

    private func homePlayerLabel(for player: GameState.Player) -> String {
        playerName(player)
    }

    private func playerName(_ player: GameState.Player) -> String {
        switch player {
        case .one:
            return localizedHomeCopy("home.player.one", fallback: "Player 1")
        case .two:
            return localizedHomeCopy("home.player.two", fallback: "Player 2")
        }
    }

    private var secretPrivacyMessage: String {
        localizedHomeCopy(
            "screen.secret.notice.message",
            fallback: "Keep the phone to yourself. Tapping a portrait locks it in right away."
        )
    }

    private func secretPrivacyTitle(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat("screen.secret.notice.title", fallback: "%@ only", playerName(player))
    }

    private func secretStageTitle(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat("screen.secret.title", fallback: "%@, choose your secret", playerName(player))
    }

    private var secretStageMessage: String {
        localizedHomeCopy("screen.secret.message", fallback: "Pick one face quietly, then pass the phone when prompted.")
    }

    private func handoffTitle(for player: GameState.Player, reason: GameState.HandoffReason) -> String {
        switch reason {
        case .secretSelected:
            return guessWhoLocalizedFormat("screen.handoff.secret.title", fallback: "Pass to %@", playerName(player))
        case .turnPassed:
            return guessWhoLocalizedFormat("screen.handoff.turn.title", fallback: "%@, take the phone", playerName(player))
        case .wrongGuess:
            return localizedHomeCopy("screen.handoff.wrong.title", fallback: "Wrong guess")
        }
    }

    private func handoffMessage(for player: GameState.Player, reason: GameState.HandoffReason) -> String {
        switch reason {
        case .secretSelected:
            return guessWhoLocalizedFormat("screen.handoff.secret.message", fallback: "%@ should be the only one looking.", playerName(player))
        case .turnPassed, .wrongGuess:
            return guessWhoLocalizedFormat("screen.handoff.turn.message", fallback: "%@ starts the next turn in private.", playerName(player))
        }
    }

    private func onlyPlayerContinueTitle(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat("screen.handoff.only", fallback: "Only %@ should continue.", playerName(player))
    }

    private func guessDecisionTitle(for player: GameState.Player) -> String {
        if gameState.remainingCharacters(for: player).count == 1 {
            return localizedHomeCopy("screen.turn.guess.final_title", fallback: "Make the final guess")
        }

        return localizedHomeCopy("screen.turn.guess.title", fallback: "Make a Guess")
    }

    private func guessDecisionMessage(for player: GameState.Player) -> String {
        if gameState.remainingCharacters(for: player).count == 1 {
            return localizedHomeCopy(
                "screen.turn.guess.final_message",
                fallback: "One suspect remains. Tap through to make the explicit final guess."
            )
        }

        return localizedHomeCopy(
            "screen.turn.guess.message",
            fallback: "Enter guess mode and tap one portrait to submit immediately."
        )
    }

    private func guessDecisionButtonTitle(for player: GameState.Player) -> String {
        if gameState.remainingCharacters(for: player).count == 1 {
            return localizedHomeCopy("screen.turn.guess.final_cta", fallback: "Commit to Final Guess")
        }

        return localizedHomeCopy("screen.turn.guess.cta", fallback: "Choose Guess")
    }

    private func answerStepTitle(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat("screen.answer.title", fallback: "%@, ask out loud", playerName(player))
    }

    private func eliminationLabel(for answer: Bool) -> String {
        answer
            ? localizedHomeCopy("screen.elimination.yes.label", fallback: "Answer: Yes")
            : localizedHomeCopy("screen.elimination.no.label", fallback: "Answer: No")
    }

    private func eliminationTitle(for answer: Bool) -> String {
        answer
            ? localizedHomeCopy("screen.elimination.yes.title", fallback: "Update the board to match the yes answer")
            : localizedHomeCopy("screen.elimination.no.title", fallback: "Update the board to match the no answer")
    }

    private var eliminationFinalGuessReminder: String {
        localizedHomeCopy(
            "screen.elimination.reminder",
            fallback: "One suspect remains. Winning still requires an explicit final guess."
        )
    }

    private func gameOverTitle(for winner: GameState.Player) -> String {
        guessWhoLocalizedFormat("screen.result.title", fallback: "%@ wins", playerName(winner))
    }

    private func gameOverMessage(for reason: GameState.EndReason) -> String {
        switch reason {
        case .correctGuess(let character):
            return guessWhoLocalizedFormat("screen.result.message", fallback: "%@ was guessed correctly.", character.name)
        }
    }

    private var playerOneSecretTitle: String {
        localizedHomeCopy("screen.result.player_one_secret", fallback: "Player 1 Secret")
    }

    private var playerTwoSecretTitle: String {
        localizedHomeCopy("screen.result.player_two_secret", fallback: "Player 2 Secret")
    }

    private func boardCountLabel(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat("board.count", fallback: "%d left", gameState.remainingCharacters(for: player).count)
    }

    private func localizedHomeCopy(_ key: String, fallback: String) -> String {
        guessWhoLocalized(key, fallback: fallback, language: activeHomeLanguage)
    }

    private var homeLanguageToggle: some View {
        HStack(spacing: 10) {
            homeLanguageFlagButton(for: .english)
            homeLanguageFlagButton(for: .ukrainian)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(StudioTheme.line, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(homeLanguageLabel)
        .accessibilityValue(activeHomeLanguage == .ukrainian ? homeLanguageUkrainianTitle : homeLanguageEnglishTitle)
    }

    private func homeLanguageFlagButton(for language: GuessWhoLanguage) -> some View {
        let isSelected = activeHomeLanguage == language

        return Button {
            UserDefaults.standard.set(language.rawValue, forKey: guessWhoLanguageOverrideKey)
            homeLanguageOverride = language.rawValue
        } label: {
            HomeLanguageFlag(language: language)
                .frame(width: 42, height: 28)
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(isSelected ? Color.white.opacity(0.92) : Color.clear)
                .contentShape(Capsule())
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(
                            isSelected ? homeLanguageSelectionBorder(for: language) : Color.clear,
                            lineWidth: 1.5
                        )
                }
                .shadow(color: isSelected ? StudioTheme.shadowSoft.opacity(1.2) : .clear, radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(homeLanguageAccessibilityTitle(for: language))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func homeLanguageSelectionBorder(for language: GuessWhoLanguage) -> Color {
        switch language {
        case .english:
            return Color(red: 0.06, green: 0.20, blue: 0.53).opacity(0.28)
        case .ukrainian:
            return StudioTheme.gold.opacity(0.45)
        }
    }

    private func homeLanguageAccessibilityTitle(for language: GuessWhoLanguage) -> String {
        switch language {
        case .english:
            return homeLanguageEnglishTitle
        case .ukrainian:
            return homeLanguageUkrainianTitle
        }
    }

    private func turnChoiceTitle(for player: GameState.Player) -> String {
        if gameState.remainingCharacters(for: player).count == 1 {
            return guessWhoLocalizedFormat("screen.turn.title.final", fallback: "%@, it is final decision time", playerName(player))
        }

        return guessWhoLocalizedFormat("screen.turn.title", fallback: "%@, choose this turn's path", playerName(player))
    }

    private func turnChoiceMessage(for player: GameState.Player) -> String {
        if gameState.remainingCharacters(for: player).count == 1 {
            return localizedHomeCopy(
                "screen.turn.message.final",
                fallback: "One suspect remains. You can still ask again, or you can commit to the explicit final guess."
            )
        }

        return localizedHomeCopy(
            "screen.turn.message",
            fallback: "Pick one path now. The turn stays clean and focused once you commit."
        )
    }

    private func eliminationMessage(
        for player: GameState.Player,
        answer: Bool
    ) -> String {
        let lead = answer
            ? localizedHomeCopy("screen.elimination.message.yes", fallback: "Hide or restore portraits so the board matches the yes answer.")
            : localizedHomeCopy("screen.elimination.message.no", fallback: "Hide or restore portraits so the board matches the no answer.")

        if gameState.remainingCharacters(for: player).count == 1 {
            return "\(lead) \(localizedHomeCopy("screen.elimination.message.final", fallback: "One portrait left still does not end the round automatically."))"
        }

        return lead
    }
}

private struct HomeLanguageFlag: View {
    let language: GuessWhoLanguage

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                switch language {
                case .english:
                    englishFlag(width: width, height: height)
                case .ukrainian:
                    ukrainianFlag
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            }
        }
    }

    private var ukrainianFlag: some View {
        VStack(spacing: 0) {
            Color(red: 0.10, green: 0.42, blue: 0.88)
            Color(red: 0.98, green: 0.83, blue: 0.20)
        }
    }

    @ViewBuilder
    private func englishFlag(width: CGFloat, height: CGFloat) -> some View {
        let diagonalLength = sqrt((width * width) + (height * height))

        ZStack {
            Color(red: 0.06, green: 0.20, blue: 0.53)

            Rectangle()
                .fill(.white)
                .frame(width: diagonalLength, height: height * 0.22)
                .rotationEffect(.degrees(33))

            Rectangle()
                .fill(.white)
                .frame(width: diagonalLength, height: height * 0.22)
                .rotationEffect(.degrees(-33))

            Rectangle()
                .fill(Color(red: 0.79, green: 0.11, blue: 0.17))
                .frame(width: diagonalLength, height: height * 0.10)
                .rotationEffect(.degrees(33))

            Rectangle()
                .fill(Color(red: 0.79, green: 0.11, blue: 0.17))
                .frame(width: diagonalLength, height: height * 0.10)
                .rotationEffect(.degrees(-33))

            Rectangle()
                .fill(.white)
                .frame(width: width, height: height * 0.34)

            Rectangle()
                .fill(.white)
                .frame(width: width * 0.28, height: height)

            Rectangle()
                .fill(Color(red: 0.79, green: 0.11, blue: 0.17))
                .frame(width: width, height: height * 0.18)

            Rectangle()
                .fill(Color(red: 0.79, green: 0.11, blue: 0.17))
                .frame(width: width * 0.14, height: height)
        }
    }
}

private struct CharacterCard: View {
    enum Mode: Equatable {
        case selectSecret
        case eliminate
        case guess
        case inactive
        case reveal

        var isInteractive: Bool {
            switch self {
            case .selectSecret, .eliminate, .guess:
                return true
            case .inactive, .reveal:
                return false
            }
        }
    }

    let character: Character
    let isEliminated: Bool
    let mode: Mode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                portrait

                Text(character.name)
                    .font(StudioTypography.cardTitle)
                    .foregroundStyle(StudioTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundFill)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            }
            .shadow(color: StudioTheme.cardShadow, radius: 12, x: 0, y: 8)
            .opacity(cardOpacity)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .disabled(!mode.isInteractive)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(character.name)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(accessibilityHint)
    }

    private var portrait: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(StudioTheme.softWash)

            if let image = portraitImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .grayscale(isEliminated ? 0.65 : 0)
                    .saturation(isEliminated ? 0.2 : 1)
                    .blur(radius: isEliminated ? 7 : 0)
                    .overlay {
                        LinearGradient(
                            colors: [.clear, Color.black.opacity(0.24)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .opacity(isEliminated ? 0.18 : 0.32)
                    }
                    .overlay {
                        if isEliminated {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white.opacity(0.32))
                        }
                    }
            } else {
                Text(String(character.name.prefix(1)))
                    .font(StudioTypography.display)
                    .foregroundStyle(StudioTheme.inkSoft)
            }

            if isEliminated {
                VStack(spacing: 0) {
                    Spacer()

                    Rectangle()
                        .fill(StudioTheme.coral.opacity(0.9))
                        .frame(height: 3)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 18)
                }
            }
        }
        .frame(height: 184)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var backgroundFill: Color {
        switch mode {
        case .guess:
            return Color.white
        case .selectSecret:
            return Color.white
        case .eliminate, .inactive, .reveal:
            return isEliminated ? Color.white.opacity(0.8) : Color.white
        }
    }

    private var borderColor: Color {
        switch mode {
        case .selectSecret:
            return StudioTheme.teal.opacity(0.55)
        case .guess:
            return StudioTheme.coral.opacity(0.72)
        case .eliminate, .inactive, .reveal:
            return isEliminated ? StudioTheme.coral.opacity(0.3) : StudioTheme.line
        }
    }

    private var borderWidth: CGFloat {
        switch mode {
        case .selectSecret, .guess:
            return 2
        case .eliminate, .inactive, .reveal:
            return isEliminated ? 1.5 : 1
        }
    }

    private var cardOpacity: Double {
        switch mode {
        case .guess:
            return isEliminated ? 0.55 : 1
        case .inactive where !isEliminated:
            return 0.94
        case .eliminate, .selectSecret, .reveal, .inactive:
            return isEliminated ? 0.78 : 1
        }
    }

    private var accessibilityValue: String {
        let eliminationState = isEliminated
            ? guessWhoLocalized("card.accessibility.eliminated", fallback: "Eliminated.")
            : guessWhoLocalized("card.accessibility.in_play", fallback: "Still in play.")
        return "\(character.accessibilitySummary). \(eliminationState)"
    }

    private var accessibilityHint: String {
        switch mode {
        case .selectSecret:
            return guessWhoLocalized("card.hint.pick", fallback: "Double tap to choose this secret character.")
        case .eliminate:
            return isEliminated
                ? guessWhoLocalized("card.hint.restore", fallback: "Double tap to restore this suspect.")
                : guessWhoLocalized("card.hint.eliminate", fallback: "Double tap to eliminate this suspect.")
        case .guess:
            return guessWhoLocalized("card.hint.guess", fallback: "Double tap to submit this as your guess.")
        case .inactive, .reveal:
            return guessWhoLocalized("card.hint.default", fallback: "Character card.")
        }
    }

    private var portraitImage: UIImage? {
        guard
            let url = Bundle.main.url(
                forResource: character.portraitAssetName,
                withExtension: "png",
                subdirectory: "CharacterPortraits"
            )
        else {
            return nil
        }

        return UIImage(contentsOfFile: url.path)
    }
}

private struct ActionButtonStyle: ButtonStyle {
    enum Kind {
        case filled(Color)
        case outlined(Color)
        case ghost
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StudioTypography.button)
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .frame(minHeight: 58)
            .background(background(configuration: configuration))
            .foregroundStyle(foregroundColor)
            .overlay {
                Capsule()
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            }
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .shadow(
                color: shadowColor(configuration: configuration),
                radius: configuration.isPressed ? 4 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 6
            )
    }

    private func background(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        return Group {
            switch kind {
            case .filled(let color):
                color.opacity(pressed ? 0.86 : 1)
            case .outlined:
                Color.white.opacity(pressed ? 0.9 : 1)
            case .ghost:
                StudioTheme.softWash.opacity(pressed ? 0.76 : 1)
            }
        }
    }

    private var foregroundColor: Color {
        switch kind {
        case .filled:
            return .white
        case .outlined(let color):
            return color
        case .ghost:
            return StudioTheme.ink
        }
    }

    private var borderColor: Color {
        switch kind {
        case .filled:
            return .clear
        case .outlined(let color):
            return color.opacity(0.32)
        case .ghost:
            return StudioTheme.line
        }
    }

    private var borderWidth: CGFloat {
        switch kind {
        case .filled:
            return 0
        case .outlined, .ghost:
            return 1
        }
    }

    private func shadowColor(configuration: Configuration) -> Color {
        switch kind {
        case .filled(let color):
            return color.opacity(configuration.isPressed ? 0.12 : 0.22)
        case .outlined, .ghost:
            return StudioTheme.shadowSoft
        }
    }
}

private enum StudioTypography {
    static let display = Font.custom("AvenirNext-Heavy", size: 42)
    static let displaySmall = Font.custom("AvenirNext-Heavy", size: 34)
    static let titleLarge = Font.custom("AvenirNext-DemiBold", size: 28)
    static let title = Font.custom("AvenirNext-DemiBold", size: 22)
    static let subheadline = Font.custom("AvenirNext-Medium", size: 17)
    static let body = Font.custom("AvenirNext-Regular", size: 17)
    static let footnote = Font.custom("AvenirNext-Regular", size: 14)
    static let button = Font.custom("AvenirNext-DemiBold", size: 18)
    static let label = Font.custom("AvenirNext-DemiBold", size: 12)
    static let compactLabel = Font.custom("AvenirNext-DemiBold", size: 11)
    static let cardTitle = Font.custom("AvenirNext-DemiBold", size: 18)
}

private enum StudioTheme {
    static let canvasTop = Color(red: 0.985, green: 0.965, blue: 0.925)
    static let canvasBottom = Color(red: 0.949, green: 0.92, blue: 0.872)
    static let heroTop = Color(red: 0.99, green: 0.965, blue: 0.92)
    static let heroBottom = Color(red: 0.963, green: 0.924, blue: 0.872)
    static let handoffTop = Color(red: 0.981, green: 0.938, blue: 0.886)
    static let handoffBottom = Color(red: 0.938, green: 0.894, blue: 0.836)
    static let handoffCard = Color.white.opacity(0.9)
    static let handoffLine = Color.white.opacity(0.42)
    static let card = Color(red: 0.997, green: 0.991, blue: 0.979)
    static let cardWarm = Color(red: 0.985, green: 0.973, blue: 0.948)
    static let boardCard = Color(red: 0.993, green: 0.987, blue: 0.976)
    static let softWash = Color(red: 0.952, green: 0.94, blue: 0.914)
    static let line = Color(red: 0.866, green: 0.823, blue: 0.764)
    static let ink = Color(red: 0.152, green: 0.145, blue: 0.163)
    static let inkSoft = Color(red: 0.232, green: 0.228, blue: 0.243)
    static let muted = Color(red: 0.435, green: 0.44, blue: 0.458)
    static let coral = Color(red: 0.84, green: 0.352, blue: 0.278)
    static let teal = Color(red: 0.117, green: 0.47, blue: 0.447)
    static let gold = Color(red: 0.73, green: 0.58, blue: 0.27)
    static let shadowSoft = Color.black.opacity(0.08)
    static let shadowStrong = Color.black.opacity(0.12)
    static let cardShadow = Color.black.opacity(0.06)
}

#Preview {
    ContentView()
        .environmentObject(GameState())
}
