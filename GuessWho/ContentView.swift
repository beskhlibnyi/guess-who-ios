import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var gameState: GameState
    @AppStorage(guessWhoLanguageOverrideKey) private var homeLanguageOverride = ""
    @AppStorage(guessWhoPlayerOneNameKey) private var storedPlayerOneName = ""
    @AppStorage(guessWhoPlayerTwoNameKey) private var storedPlayerTwoName = ""
    @StateObject private var portraitRepository = PortraitImageRepository()
    @State private var showsNewGameConfirmation = false
    @State private var showsPlayerSetup = false

    private let columns = [
        GridItem(.adaptive(minimum: 156), spacing: 16, alignment: .top)
    ]

    private var homeAlertTitle: String {
        localizedHomeCopy("home.alert.title", fallback: "Start over?")
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
            fallback: "Your current game will be cleared."
        )
    }

    private var homeTitle: String {
        localizedHomeCopy("home.title", fallback: "ХТО")
    }

    private var homeOverview: String {
        localizedHomeCopy("home.overview", fallback: "Two players. One iPhone.")
    }

    private var homeSummary: String {
        localizedHomeCopy(
            "home.summary",
            fallback: "Pick a secret. Ask yes-or-no questions. Make your guess."
        )
    }

    private var homeStartTitle: String {
        localizedHomeCopy("home.start", fallback: "Start New Game")
    }

    private var homeResumeTitle: String {
        localizedHomeCopy("home.resume", fallback: "Resume Game")
    }

    private var homePlayersTitle: String {
        localizedHomeCopy("home.players.title", fallback: "Name your players")
    }

    private var homePlayersMessage: String {
        localizedHomeCopy(
            "home.players.message",
            fallback: "Add names for each side, or leave them blank to keep the default labels."
        )
    }

    private var homePlayersPlaceholder: String {
        localizedHomeCopy("home.players.placeholder", fallback: "Enter a name")
    }

    private var homePlayersBackTitle: String {
        localizedHomeCopy("home.players.back", fallback: "Back")
    }

    private var homePlayersStartTitle: String {
        localizedHomeCopy("home.players.start", fallback: "Start Game")
    }

    private var homeRulesTitle: String {
        localizedHomeCopy("home.rules", fallback: "How to Play")
    }

    private var homeRoundInProgressTitle: String {
        localizedHomeCopy("home.live_round.title", fallback: "Game in progress")
    }

    private var homeFooter: String {
        localizedHomeCopy("home.footer", fallback: "© 2026 ХТО")
    }

    private var rulesPageTitle: String {
        localizedHomeCopy("rules.title", fallback: "How to Play")
    }

    private var rulesPageSubtitle: String {
        localizedHomeCopy(
            "rules.subtitle",
            fallback: "Pick in private, pass the phone, and narrow it down."
        )
    }

    private var rulesBadgeTitle: String {
        localizedHomeCopy("rules.badge", fallback: "Quick Guide")
    }

    private var rulesHomeButtonTitle: String {
        localizedHomeCopy("rules.home", fallback: "Home")
    }

    private var rulesFlowTitle: String {
        localizedHomeCopy("rules.flow.title", fallback: "Round flow")
    }

    private var rulesFlowMessage: String {
        localizedHomeCopy(
            "rules.flow.message",
            fallback: "Secret picks happen once. After that, each turn follows the same simple rhythm."
        )
    }

    private var rulesQuickPlayersTitle: String {
        localizedHomeCopy("rules.quick.players.title", fallback: "Players")
    }

    private var rulesQuickPlayersValue: String {
        localizedHomeCopy("rules.quick.players.value", fallback: "2")
    }

    private var rulesQuickSetupTitle: String {
        localizedHomeCopy("rules.quick.setup.title", fallback: "Setup")
    }

    private var rulesQuickSetupValue: String {
        localizedHomeCopy("rules.quick.setup.value", fallback: "1 iPhone")
    }

    private var rulesQuickGoalTitle: String {
        localizedHomeCopy("rules.quick.goal.title", fallback: "Goal")
    }

    private var rulesQuickGoalValue: String {
        localizedHomeCopy("rules.quick.goal.value", fallback: "Find the secret face")
    }

    private var rulesStepOneTitle: String {
        localizedHomeCopy("rules.step1.title", fallback: "Pick in private")
    }

    private var rulesStepOneMessage: String {
        guessWhoLocalizedFormat(
            "rules.step1.message",
            fallback: "%@ picks first. Then %@.",
            playerName(.one),
            playerName(.two)
        )
    }

    private var rulesStepTwoTitle: String {
        localizedHomeCopy("rules.step2.title", fallback: "Ask or guess")
    }

    private var rulesStepTwoMessage: String {
        localizedHomeCopy(
            "rules.step2.message",
            fallback: "Start every turn by choosing one."
        )
    }

    private var rulesStepThreeTitle: String {
        localizedHomeCopy("rules.step3.title", fallback: "Answer first")
    }

    private var rulesStepThreeMessage: String {
        localizedHomeCopy(
            "rules.step3.message",
            fallback: "After Yes or No, cross off the faces that no longer fit."
        )
    }

    private var rulesStepFourTitle: String {
        localizedHomeCopy("rules.step4.title", fallback: "Guess to win")
    }

    private var rulesStepFourMessage: String {
        localizedHomeCopy(
            "rules.step4.message",
            fallback: "Even with one face left, you still need to make the final guess."
        )
    }

    private var rulesTipTitle: String {
        localizedHomeCopy("rules.tip.title", fallback: "Winning move")
    }

    private var rulesTipMessage: String {
        localizedHomeCopy(
            "rules.tip.message",
            fallback: "One face left does not end the round. Open Guess mode and name the character to win."
        )
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

    private var notesTitle: String {
        localizedHomeCopy("notes.title", fallback: "Notes")
    }

    private var notesMessage: String {
        localizedHomeCopy("notes.message", fallback: "One question per step.")
    }

    private var notesEmptyMessage: String {
        localizedHomeCopy("notes.empty", fallback: "Your saved steps will appear here.")
    }

    private var notesQuestionPlaceholder: String {
        localizedHomeCopy("notes.question.placeholder", fallback: "Asked question")
    }

    private var playerChipTitle: String {
        localizedHomeCopy("common.player", fallback: "Player")
    }

    private var suspectsLeftTitle: String {
        localizedHomeCopy("common.suspects_left", fallback: "Left")
    }

    private var eliminatedTitle: String {
        localizedHomeCopy("common.eliminated", fallback: "Eliminated")
    }

    private var unknownTitle: String {
        localizedHomeCopy("common.unknown", fallback: "Unknown")
    }

    private var turnStartLabel: String {
        localizedHomeCopy("screen.turn.label", fallback: "Your Turn")
    }

    private var askTitle: String {
        localizedHomeCopy("screen.turn.ask.title", fallback: "Ask a Question")
    }

    private var askMessage: String {
        localizedHomeCopy(
            "screen.turn.ask.message",
            fallback: "Ask it out loud. Then record the answer."
        )
    }

    private var chooseAskTitle: String {
        localizedHomeCopy("screen.turn.ask.cta", fallback: "Ask a Question")
    }

    private var askModeLabel: String {
        localizedHomeCopy("screen.answer.label", fallback: "Ask")
    }

    private var answerInstruction: String {
        localizedHomeCopy(
            "screen.answer.instruction",
            fallback: "Tap Yes or No after they answer."
        )
    }

    private var donePassPhoneTitle: String {
        localizedHomeCopy("screen.elimination.cta", fallback: "Pass the Phone")
    }

    private var finalGuessLabel: String {
        localizedHomeCopy("screen.guess.label", fallback: "Guess")
    }

    private var finalGuessMessage: String {
        localizedHomeCopy(
            "screen.guess.message",
            fallback: "A wrong guess ends your turn."
        )
    }

    private var finalGuessBackoutMessage: String {
        localizedHomeCopy(
            "screen.guess.backout",
            fallback: "Want to ask instead?"
        )
    }

    private var chooseAskInsteadTitle: String {
        localizedHomeCopy("screen.guess.back", fallback: "Ask Instead")
    }

    private var roundResultLabel: String {
        localizedHomeCopy("screen.result.label", fallback: "Round Over")
    }

    private var backToHomeTitle: String {
        localizedHomeCopy("screen.result.home", fallback: "Home")
    }

    private var resultRevealLabel: String {
        localizedHomeCopy("screen.result.reveal", fallback: "Secret character")
    }

    private var resultRecapTitle: String {
        localizedHomeCopy("screen.result.recap.title", fallback: "Round recap")
    }

    private var resultRecapMessage: String {
        localizedHomeCopy(
            "screen.result.recap.message",
            fallback: "Both secrets are revealed before the next round."
        )
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

    private var portraitPreloadKey: String {
        gameState.characters
            .map(\.portraitAssetName)
            .sorted()
            .joined(separator: "|")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer

                if showsPlayerSetup {
                    playerSetupScreen
                } else {
                    switch gameState.appScreen {
                    case .menu:
                        menuScreen
                    case .rules:
                        rulesScreen
                    case .game:
                        gameScreen
                    }
                }
            }
            .id(activeHomeLanguage.rawValue)
            .toolbar(.hidden, for: .navigationBar)
        }
        .task(id: portraitPreloadKey) {
            portraitRepository.preloadIfNeeded(for: gameState.characters)
        }
        .alert(homeAlertTitle, isPresented: $showsNewGameConfirmation) {
            Button(homeAlertCancel, role: .cancel) {}
            Button(homeAlertConfirm, role: .destructive) {
                showsPlayerSetup = true
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
                Text(homeTitle)
                    .font(StudioTypography.brandTitle)
                    .foregroundStyle(StudioTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)

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

    private var playerSetupScreen: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Button(action: { showsPlayerSetup = false }) {
                        Label(homePlayersBackTitle, systemImage: "chevron.left")
                            .font(StudioTypography.subheadline)
                            .foregroundStyle(StudioTheme.ink)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }

                surface(fill: StudioTheme.card, border: StudioTheme.line.opacity(0.8), shadow: StudioTheme.shadowStrong) {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .top, spacing: 12) {
                            iconStamp(systemImage: "person.2.fill", accent: StudioTheme.gold)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(homePlayersTitle)
                                    .font(StudioTypography.title)
                                    .foregroundStyle(StudioTheme.ink)

                                Text(homePlayersMessage)
                                    .font(StudioTypography.footnote)
                                    .foregroundStyle(StudioTheme.muted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        VStack(spacing: 12) {
                            playerNameField(
                                title: defaultPlayerName(.one),
                                text: $storedPlayerOneName,
                                accent: StudioTheme.teal
                            )

                            playerNameField(
                                title: defaultPlayerName(.two),
                                text: $storedPlayerTwoName,
                                accent: StudioTheme.coral
                            )
                        }

                        menuButton(
                            title: homePlayersStartTitle,
                            systemImage: "play.fill",
                            style: .filled(StudioTheme.coral),
                            action: startGameFromPlayerSetup
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 72)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity)
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
                                capsuleLabel(rulesBadgeTitle, accent: StudioTheme.gold)

                                VStack(alignment: .leading, spacing: 10) {
                                    Text(rulesPageTitle)
                                        .font(StudioTypography.displaySmall)
                                        .foregroundStyle(StudioTheme.ink)

                                    Text(rulesPageSubtitle)
                                        .font(StudioTypography.subheadline)
                                        .foregroundStyle(StudioTheme.muted)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            Spacer()

                            compactMenuButton(rulesHomeButtonTitle, systemImage: "house", action: gameState.showMenu)
                        }

                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                summaryChip(
                                    title: rulesQuickPlayersTitle,
                                    value: rulesQuickPlayersValue,
                                    accent: StudioTheme.teal
                                )
                                summaryChip(
                                    title: rulesQuickSetupTitle,
                                    value: rulesQuickSetupValue,
                                    accent: StudioTheme.gold
                                )
                            }

                            summaryChip(
                                title: rulesQuickGoalTitle,
                                value: rulesQuickGoalValue,
                                accent: StudioTheme.coral
                            )
                        }

                        surface(
                            padding: 18,
                            fill: Color.white.opacity(0.52),
                            border: StudioTheme.line.opacity(0.55),
                            shadow: .clear
                        ) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(alignment: .top, spacing: 12) {
                                    iconStamp(systemImage: "arrow.triangle.branch", accent: StudioTheme.teal)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(rulesFlowTitle)
                                            .font(StudioTypography.title)
                                            .foregroundStyle(StudioTheme.ink)

                                        Text(rulesFlowMessage)
                                            .font(StudioTypography.footnote)
                                            .foregroundStyle(StudioTheme.muted)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }

                                VStack(spacing: 12) {
                                    ruleStep(
                                        number: "1",
                                        title: rulesStepOneTitle,
                                        message: rulesStepOneMessage,
                                        systemImage: "hand.tap.fill",
                                        accent: StudioTheme.gold
                                    )
                                    ruleStep(
                                        number: "2",
                                        title: rulesStepTwoTitle,
                                        message: rulesStepTwoMessage,
                                        systemImage: "questionmark.bubble.fill",
                                        accent: StudioTheme.teal
                                    )
                                    ruleStep(
                                        number: "3",
                                        title: rulesStepThreeTitle,
                                        message: rulesStepThreeMessage,
                                        systemImage: "checkmark.message.fill",
                                        accent: StudioTheme.gold
                                    )
                                    ruleStep(
                                        number: "4",
                                        title: rulesStepFourTitle,
                                        message: rulesStepFourMessage,
                                        systemImage: "scope",
                                        accent: StudioTheme.coral
                                    )
                                }
                            }
                        }

                        surface(
                            padding: 18,
                            fill: StudioTheme.coral.opacity(0.1),
                            border: StudioTheme.coral.opacity(0.24),
                            shadow: .clear
                        ) {
                            HStack(alignment: .top, spacing: 12) {
                                iconStamp(systemImage: "exclamationmark.circle.fill", accent: StudioTheme.coral)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(rulesTipTitle)
                                        .font(StudioTypography.subheadline)
                                        .foregroundStyle(StudioTheme.ink)

                                    Text(rulesTipMessage)
                                        .font(StudioTypography.footnote)
                                        .foregroundStyle(StudioTheme.muted)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
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
        case .idle:
            EmptyView()
        case .selectingSecret(let player):
            secretSelectionScreen(for: player)
        case .handoff(_, let toPlayer, _):
            handoffScreen(to: toPlayer)
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

                characterBoard(for: player, mode: .selectSecret)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 34)
        }
    }

    private func handoffScreen(to player: GameState.Player) -> some View {
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
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(StudioTheme.coral.opacity(0.16))
                                .frame(width: 84, height: 84)

                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(StudioTheme.coral)
                        }

                        Text(handoffTitle(for: player))
                            .font(StudioTypography.displaySmall)
                            .foregroundStyle(StudioTheme.ink)
                            .multilineTextAlignment(.center)

                        Text(handoffMessage(for: player))
                            .font(StudioTypography.body)
                            .foregroundStyle(StudioTheme.inkSoft)
                            .multilineTextAlignment(.center)

                        menuButton(
                            title: handoffContinueTitle(for: player),
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
                    accent: StudioTheme.teal
                )

                questionNotesPanel(for: player)

                decisionCard(
                    title: askTitle,
                    message: askMessage,
                    accent: StudioTheme.teal,
                    systemImage: "text.bubble.fill",
                    buttonTitle: chooseAskTitle,
                    buttonStyle: .filled(StudioTheme.teal),
                    action: gameState.chooseAskQuestion
                )

                decisionCard(
                    title: guessDecisionTitle(for: player),
                    message: guessDecisionMessage(for: player),
                    accent: StudioTheme.coral,
                    systemImage: "scope",
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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                stageHeader(
                    label: askModeLabel,
                    title: answerStepTitle(for: player),
                    message: answerInstruction,
                    accent: StudioTheme.teal
                )

                questionNotesPanel(for: player, includesDraft: true)

                menuButton(
                    title: backTitle,
                    systemImage: "chevron.left",
                    style: .ghost,
                    action: gameState.returnToTurnChoice
                )

            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
    }

    private func eliminationScreen(
        for player: GameState.Player,
        answer: Bool
    ) -> some View {
        gameplayBoardScreen(
            for: player,
            label: eliminationLabel(for: answer),
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
                    message: message,
                    accent: accent
                )

                questionNotesPanel(for: player)

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
        let revealedCharacter = revealedCharacter(for: reason)

        return ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                stageHeader(
                    label: roundResultLabel,
                    title: gameOverTitle(for: winner),
                    message: gameOverMessage(for: reason),
                    accent: StudioTheme.coral
                )

                resultRevealCard(character: revealedCharacter)

                resultRecapCard()

                VStack(spacing: 12) {
                    menuButton(
                        title: homeStartTitle,
                        systemImage: "arrow.clockwise",
                        style: .filled(StudioTheme.coral),
                        action: gameState.startNewGame
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 34)
        }
    }

    private func resultRevealCard(character: Character) -> some View {
        surface(fill: Color.white.opacity(0.88), border: StudioTheme.coral.opacity(0.2), shadow: StudioTheme.shadowSoft) {
            VStack(alignment: .center, spacing: 16) {
                capsuleLabel(resultRevealLabel, accent: StudioTheme.coral)
                    .frame(maxWidth: .infinity, alignment: .center)

                resultPortrait(for: character)

                VStack(spacing: 6) {
                    Text(character.name)
                        .font(StudioTypography.titleLarge)
                        .foregroundStyle(StudioTheme.ink)
                        .multilineTextAlignment(.center)

                    Text(character.boardSummary)
                        .font(StudioTypography.body)
                        .foregroundStyle(StudioTheme.muted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func resultRecapCard() -> some View {
        surface(
            padding: 16,
            fill: Color.white.opacity(0.78),
            border: StudioTheme.line.opacity(0.65),
            shadow: .clear
        ) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(resultRecapTitle)
                        .font(StudioTypography.title)
                        .foregroundStyle(StudioTheme.ink)

                    Text(resultRecapMessage)
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)
                }

                HStack(spacing: 12) {
                    summaryChip(
                        title: playerSecretTitle(for: .one),
                        value: gameState.secretCharacter(for: .one)?.name ?? unknownTitle,
                        accent: StudioTheme.teal
                    )
                    summaryChip(
                        title: playerSecretTitle(for: .two),
                        value: gameState.secretCharacter(for: .two)?.name ?? unknownTitle,
                        accent: StudioTheme.coral
                    )
                }
            }
        }
    }

    private func resultPortrait(for character: Character) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(StudioTheme.softWash)

            if let image = portraitImage(for: character) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(14)
            } else {
                Text(String(character.name.prefix(1)))
                    .font(StudioTypography.display)
                    .foregroundStyle(StudioTheme.inkSoft)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .overlay(alignment: .topTrailing) {
            iconStamp(systemImage: "trophy.fill", accent: StudioTheme.gold)
                .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(StudioTheme.line.opacity(0.6), lineWidth: 1)
        }
    }

    private func stageHeader(
        label: String,
        title: String,
        message: String,
        accent: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    capsuleLabel(label, accent: accent)

                    Text(title)
                        .font(StudioTypography.displaySmall)
                        .foregroundStyle(StudioTheme.ink)
                }

                Spacer()

                compactMenuButton(backToHomeTitle, systemImage: "house", action: gameState.showMenu)
            }

            Text(message)
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.muted)
        }
    }

    private func gameplayHeader(
        player: GameState.Player,
        label: String,
        message: String,
        accent: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    capsuleLabel(label, accent: accent)

                    Text(playerName(player))
                        .font(StudioTypography.titleLarge)
                        .foregroundStyle(StudioTheme.ink)
                }

                Spacer()

                compactMenuButton(backToHomeTitle, systemImage: "house", action: gameState.showMenu)
            }

            Text(message)
                .font(StudioTypography.footnote)
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

    private func decisionCard(
        title: String,
        message: String,
        accent: Color,
        systemImage: String,
        buttonTitle: String,
        buttonStyle: ActionButtonStyle.Kind,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                iconStamp(systemImage: systemImage, accent: accent)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(StudioTypography.title)
                        .foregroundStyle(StudioTheme.ink)

                    Text(message)
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)
                }
            }

            menuButton(
                title: buttonTitle,
                systemImage: systemImage,
                style: buttonStyle,
                action: action
            )
        }
    }

    private func questionNotesPanel(
        for player: GameState.Player,
        includesDraft: Bool = false
    ) -> some View {
        let notes = gameState.questionNotes(for: player)

        return surface(padding: 16, fill: Color.white.opacity(0.72), border: StudioTheme.line.opacity(0.65), shadow: .clear) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    iconStamp(systemImage: "note.text", accent: StudioTheme.gold)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(notesTitle)
                            .font(StudioTypography.title)
                            .foregroundStyle(StudioTheme.ink)

                        Text(notesMessage)
                            .font(StudioTypography.footnote)
                            .foregroundStyle(StudioTheme.muted)
                    }
                }

                if notes.isEmpty && !includesDraft {
                    Text(notesEmptyMessage)
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)
                }

                VStack(spacing: 10) {
                    ForEach(notes) { note in
                        questionNoteRow(
                            stepTitle: stepTitle(for: note.stepNumber),
                            question: savedQuestionBinding(for: player, noteID: note.id),
                            selectedAnswer: note.answer,
                            onSelectYes: {
                                gameState.updateQuestionNoteAnswer(true, noteID: note.id, for: player)
                            },
                            onSelectNo: {
                                gameState.updateQuestionNoteAnswer(false, noteID: note.id, for: player)
                            }
                        )
                    }

                    if includesDraft {
                        questionNoteRow(
                            stepTitle: stepTitle(for: gameState.nextQuestionStep(for: player)),
                            question: draftQuestionBinding(for: player),
                            selectedAnswer: nil,
                            onSelectYes: { gameState.recordAnswer(true) },
                            onSelectNo: { gameState.recordAnswer(false) }
                        )
                    }
                }
            }
        }
    }

    private func questionNoteRow(
        stepTitle: String,
        question: Binding<String>,
        selectedAnswer: Bool?,
        onSelectYes: @escaping () -> Void,
        onSelectNo: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stepTitle.uppercased())
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.muted)

            HStack(spacing: 10) {
                TextField(notesQuestionPlaceholder, text: question)
                    .font(StudioTypography.body)
                    .foregroundStyle(StudioTheme.ink)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(false)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(StudioTheme.line.opacity(0.85), lineWidth: 1)
                    }

                noteAnswerButton(
                    title: yesTitle,
                    isSelected: selectedAnswer == true,
                    accent: StudioTheme.teal,
                    action: onSelectYes
                )

                noteAnswerButton(
                    title: noTitle,
                    isSelected: selectedAnswer == false,
                    accent: StudioTheme.coral,
                    action: onSelectNo
                )
            }
        }
    }

    private func noteAnswerButton(
        title: String,
        isSelected: Bool,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(StudioTypography.label)
                .foregroundStyle(isSelected ? Color.white : accent)
                .frame(width: 54, height: 48)
                .background(isSelected ? accent : Color.white.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(accent.opacity(isSelected ? 0 : 0.45), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
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
                            portraitImage: portraitRepository.image(for: character),
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

    private func ruleStep(
        number: String,
        title: String,
        message: String,
        systemImage: String,
        accent: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(accent.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(accent)
            }
            .overlay(alignment: .topTrailing) {
                Text(number)
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(accent)
                    .clipShape(Capsule())
                    .offset(x: 6, y: -6)
            }

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
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.9), accent.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.18), lineWidth: 1)
        }
    }

    private func playerNameField(
        title: String,
        text: Binding<String>,
        accent: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.muted)

            TextField(homePlayersPlaceholder, text: text)
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.ink)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accent.opacity(0.2), lineWidth: 1)
                }
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

    private func capsuleLabel(_ title: String, accent: Color) -> some View {
        Text(title)
            .font(StudioTypography.label)
            .foregroundStyle(accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(accent.opacity(0.1))
            .clipShape(Capsule())
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
                title: localizedHomeCopy("board.secret.title", fallback: "Pick a secret"),
                message: localizedHomeCopy("board.secret.message", fallback: "Tap one face."),
                accent: StudioTheme.teal,
                icon: "person.crop.square.fill"
            )
        case .eliminate:
            return (
                title: localizedHomeCopy("board.suspect.title", fallback: "Your board"),
                message: localizedHomeCopy("board.suspect.message", fallback: "Tap faces to cross them off or bring them back."),
                accent: StudioTheme.teal,
                icon: "eye.slash.circle.fill"
            )
        case .guess:
            return (
                title: localizedHomeCopy("board.guess.title", fallback: "Make your guess"),
                message: localizedHomeCopy("board.guess.message", fallback: "Tap one face."),
                accent: StudioTheme.coral,
                icon: "scope"
            )
        case .inactive:
            return (
                title: localizedHomeCopy("board.default.title", fallback: "Board"),
                message: guessWhoLocalizedFormat("board.default.message", fallback: "%@'s board.", playerName(player)),
                accent: StudioTheme.gold,
                icon: "square.grid.2x2.fill"
            )
        case .reveal:
            return (
                title: localizedHomeCopy("board.result.title", fallback: "Final board"),
                message: localizedHomeCopy("board.result.message", fallback: "The winning board at the end of the round."),
                accent: StudioTheme.gold,
                icon: "sparkles"
            )
        }
    }

    private func handleStartNewGameTapped() {
        if gameState.hasRoundInProgress {
            showsNewGameConfirmation = true
        } else {
            showsPlayerSetup = true
        }
    }

    private func startGameFromPlayerSetup() {
        showsPlayerSetup = false
        gameState.startNewGame()
    }

    private var homeLiveRoundMessage: String {
        let format = localizedHomeCopy(
            "home.live_round.message",
            fallback: "%@ secrets picked. Jump back in."
        )
        return String.localizedStringWithFormat(format, secretsLockedValue)
    }

    private func homePlayerLabel(for player: GameState.Player) -> String {
        playerName(player)
    }

    private func playerName(_ player: GameState.Player) -> String {
        let customName = trimmedPlayerName(for: player)
        if !customName.isEmpty {
            return customName
        }

        return defaultPlayerName(player)
    }

    private func defaultPlayerName(_ player: GameState.Player) -> String {
        switch player {
        case .one:
            return localizedHomeCopy("home.player.one", fallback: "Player 1")
        case .two:
            return localizedHomeCopy("home.player.two", fallback: "Player 2")
        }
    }

    private func trimmedPlayerName(for player: GameState.Player) -> String {
        let rawName: String

        switch player {
        case .one:
            rawName = storedPlayerOneName
        case .two:
            rawName = storedPlayerTwoName
        }

        return rawName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var secretPrivacyMessage: String {
        localizedHomeCopy(
            "screen.secret.notice.message",
            fallback: "Make your pick in private."
        )
    }

    private func secretPrivacyTitle(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat("screen.secret.notice.title", fallback: "%@ only", playerName(player))
    }

    private func handoffTitle(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat(
            "screen.handoff.title",
            fallback: "Pass the phone to %@",
            playerName(player)
        )
    }

    private func handoffMessage(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat(
            "screen.handoff.message",
            fallback: "%@, tap below when you are ready.",
            playerName(player)
        )
    }

    private func handoffContinueTitle(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat("screen.handoff.cta", fallback: "I am %@", playerName(player))
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
                fallback: "One face left. Make the final guess."
            )
        }

        return localizedHomeCopy(
            "screen.turn.guess.message",
            fallback: "Open guess mode, then tap one face."
        )
    }

    private func guessDecisionButtonTitle(for player: GameState.Player) -> String {
        if gameState.remainingCharacters(for: player).count == 1 {
            return localizedHomeCopy("screen.turn.guess.final_cta", fallback: "Make Final Guess")
        }

        return localizedHomeCopy("screen.turn.guess.cta", fallback: "Make a Guess")
    }

    private func answerStepTitle(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat("screen.answer.title", fallback: "%@, ask your question", playerName(player))
    }

    private func eliminationLabel(for answer: Bool) -> String {
        answer
            ? localizedHomeCopy("screen.elimination.yes.label", fallback: "Yes")
            : localizedHomeCopy("screen.elimination.no.label", fallback: "No")
    }

    private var eliminationFinalGuessReminder: String {
        localizedHomeCopy(
            "screen.elimination.reminder",
            fallback: "One face left. You still need to guess."
        )
    }

    private func gameOverTitle(for winner: GameState.Player) -> String {
        guessWhoLocalizedFormat("screen.result.title", fallback: "%@ wins", playerName(winner))
    }

    private func gameOverMessage(for reason: GameState.EndReason) -> String {
        switch reason {
        case .correctGuess(let character):
            return guessWhoLocalizedFormat("screen.result.message", fallback: "The answer was %@.", character.name)
        }
    }

    private func playerSecretTitle(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat(
            "screen.result.player_secret",
            fallback: "%@'s secret",
            playerName(player)
        )
    }

    private func revealedCharacter(for reason: GameState.EndReason) -> Character {
        switch reason {
        case .correctGuess(let character):
            return character
        }
    }

    private func portraitImage(for character: Character) -> UIImage? {
        portraitRepository.image(for: character)
    }

    private func stepTitle(for stepNumber: Int) -> String {
        guessWhoLocalizedFormat("notes.step.title", fallback: "Step %d", stepNumber)
    }

    private func boardCountLabel(for player: GameState.Player) -> String {
        guessWhoLocalizedFormat("board.count", fallback: "%d left", gameState.remainingCharacters(for: player).count)
    }

    private func localizedHomeCopy(_ key: String, fallback: String) -> String {
        guessWhoLocalized(key, fallback: fallback, language: activeHomeLanguage)
    }

    private func draftQuestionBinding(for player: GameState.Player) -> Binding<String> {
        Binding(
            get: { gameState.questionDraft(for: player) },
            set: { gameState.updateQuestionDraft($0, for: player) }
        )
    }

    private func savedQuestionBinding(
        for player: GameState.Player,
        noteID: GameState.QuestionNote.ID
    ) -> Binding<String> {
        Binding(
            get: {
                gameState.questionNotes(for: player)
                    .first(where: { $0.id == noteID })?
                    .question ?? ""
            },
            set: { gameState.updateQuestionNoteText($0, noteID: noteID, for: player) }
        )
    }

    private var homeLanguageToggle: some View {
        HomeLanguagePicker(
            selectedLanguage: activeHomeLanguage,
            label: homeLanguageLabel,
            englishTitle: homeLanguageEnglishTitle,
            ukrainianTitle: homeLanguageUkrainianTitle,
            onSelect: { language in
                UserDefaults.standard.set(language.rawValue, forKey: guessWhoLanguageOverrideKey)
                homeLanguageOverride = language.rawValue
            }
        )
    }

    private func turnChoiceTitle(for player: GameState.Player) -> String {
        if gameState.remainingCharacters(for: player).count == 1 {
            return guessWhoLocalizedFormat("screen.turn.title.final", fallback: "%@, your call", playerName(player))
        }

        return guessWhoLocalizedFormat("screen.turn.title", fallback: "%@, make your move", playerName(player))
    }

    private func turnChoiceMessage(for player: GameState.Player) -> String {
        if gameState.remainingCharacters(for: player).count == 1 {
            return localizedHomeCopy(
                "screen.turn.message.final",
                fallback: "One face left. Ask one more question or make the final guess."
            )
        }

        return localizedHomeCopy(
            "screen.turn.message",
            fallback: "Ask a question or make a guess."
        )
    }

    private func eliminationMessage(
        for player: GameState.Player,
        answer: Bool
    ) -> String {
        let lead = answer
            ? localizedHomeCopy("screen.elimination.message.yes", fallback: "Hide the faces that do not match Yes.")
            : localizedHomeCopy("screen.elimination.message.no", fallback: "Hide the faces that do not match No.")

        if gameState.remainingCharacters(for: player).count == 1 {
            return "\(lead) \(localizedHomeCopy("screen.elimination.message.final", fallback: "One face left does not end the game."))"
        }

        return lead
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
    let portraitImage: UIImage?
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
    static let brandTitle = Font.custom("Yakutovych", size: 64)
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

enum StudioTheme {
    static let canvasTop = Color(red: 0.985, green: 0.965, blue: 0.925)
    static let canvasBottom = Color(red: 0.949, green: 0.92, blue: 0.872)
    static let handoffTop = Color(red: 0.981, green: 0.938, blue: 0.886)
    static let handoffBottom = Color(red: 0.938, green: 0.894, blue: 0.836)
    static let handoffCard = Color.white.opacity(0.9)
    static let handoffLine = Color.white.opacity(0.42)
    static let card = Color(red: 0.997, green: 0.991, blue: 0.979)
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
