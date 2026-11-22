import Combine
import SwiftUI

struct AliasGameplayScreen: View {
    @EnvironmentObject private var navigationState: AliasNavigationState
    @EnvironmentObject private var aliasGameState: AliasGameState
    @AppStorage(aliasPlayerOneNameKey) private var storedPlayerOneName = ""
    @AppStorage(aliasPlayerTwoNameKey) private var storedPlayerTwoName = ""
    @State private var explanationWord: AliasVocabulary.Word?
    @State private var wordDragOffset: CGFloat = 0
    @State private var isCompletingSwipe = false
    @State private var showsExclusionError = false

    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    private let swipeCompletionDistance: CGFloat = 120

    var body: some View {
        Group {
            switch aliasGameState.phase {
            case .idle:
                emptyState
            case .loading:
                loadingState
            case .handoff(let player):
                handoffState(player)
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
        .onChange(of: aliasGameState.currentWord?.id) { _, _ in
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                wordDragOffset = 0
                isCompletingSwipe = false
            }
        }
        .sheet(item: $explanationWord) { word in
            AliasWordExplanationSheet(word: word.text)
        }
        .alert(
            copy("alias.game.exclude.error.title", fallback: "Couldn’t exclude word"),
            isPresented: $showsExclusionError
        ) {
            Button(copy("common.ok", fallback: "OK"), role: .cancel) {}
        } message: {
            Text(copy("alias.game.exclude.error.message", fallback: "The word remains in the deck. Please try again."))
        }
    }

    private var emptyState: some View {
        messageScreen(
            icon: "text.bubble.fill",
            title: copy("alias.game.empty.title", fallback: "No active match"),
            message: copy("alias.game.empty.message", fallback: "Return to the YALIAS menu to start one.")
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

    private func handoffState(_ player: AliasPlayer) -> some View {
        ZStack {
            YaliasPaperBackgroundView()

            VStack(spacing: 14) {
                Color.clear.frame(height: 76)

                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(StudioTheme.paperInk)
                    .frame(width: 92, height: 66)
                    .background(TornPaperShape().fill(StudioTheme.mustard))
                    .overlay(alignment: .bottomTrailing) {
                        Circle()
                            .fill(StudioTheme.vermilion)
                            .frame(width: 22, height: 22)
                            .offset(x: 2, y: 1)
                    }
                    .rotationEffect(.degrees(-2))
                    .shadow(color: StudioTheme.paperInk.opacity(0.15), radius: 5, x: 1, y: 4)

                VStack(spacing: 12) {
                    Text(copy("alias.game.handoff.title", fallback: "Pass the phone to %@", playerName(player)))
                        .font(StudioTypography.paperTitle)
                        .foregroundStyle(StudioTheme.paperInk)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.78)
                        .fixedSize(horizontal: false, vertical: true)

                    Capsule()
                        .fill(StudioTheme.vermilion)
                        .frame(width: 152, height: 5)
                        .rotationEffect(.degrees(-2))

                    Text(copy("alias.game.handoff.message", fallback: "Only %@ should see the next word.", playerName(player)))
                        .font(StudioTypography.footnote.weight(.semibold))
                        .foregroundStyle(StudioTheme.paperInk)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(TornPaperShape().fill(StudioTheme.paper))
                .shadow(color: StudioTheme.paperInk.opacity(0.12), radius: 6, x: 1, y: 4)

                VStack(alignment: .leading, spacing: 12) {
                    Text(copy(
                        "alias.game.handoff.rules.title",
                        fallback: "%@, explain the word and follow these rules:",
                        playerName(player)
                    ))
                        .font(StudioTypography.subheadline.weight(.semibold))
                        .foregroundStyle(StudioTheme.paperInk)
                        .fixedSize(horizontal: false, vertical: true)

                    ruleRow(
                        systemImage: "xmark",
                        color: StudioTheme.vermilion,
                        title: copy("alias.game.handoff.rules.no_word", fallback: "Do not say the word itself.")
                    )
                    ruleRow(
                        systemImage: "arrow.up",
                        color: StudioTheme.olive,
                        title: copy("alias.game.handoff.rules.guessed", fallback: "Swipe up when the word is guessed.")
                    )
                    ruleRow(
                        systemImage: "arrow.down",
                        color: StudioTheme.mustard,
                        title: copy("alias.game.handoff.rules.skipped", fallback: "Swipe down to skip it.")
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(TornPaperShape().fill(StudioTheme.paperHighlight))
                .overlay {
                    TornPaperShape()
                        .stroke(StudioTheme.paperInk.opacity(0.16), lineWidth: 1.2)
                }
                .shadow(color: StudioTheme.paperInk.opacity(0.10), radius: 5, x: 1, y: 4)

                Button(copy("alias.game.handoff.cta", fallback: "I’m %@, start", playerName(player))) {
                    aliasGameState.startTurn()
                }
                .buttonStyle(PaperActionButtonStyle(kind: .filled(StudioTheme.vermilion)))

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)

            Button(action: returnToMenu) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(StudioTheme.paperInk)
                    .frame(width: 44, height: 44)
                    .background(StudioTheme.paper, in: Circle())
                    .overlay { Circle().stroke(StudioTheme.paperInk, lineWidth: 1.8) }
                    .shadow(color: StudioTheme.paperInk.opacity(0.13), radius: 5, x: 1, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(copy("common.menu", fallback: "Menu"))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.leading, 20)
            .padding(.top, 12)
        }
    }

    private func ruleRow(systemImage: String, color: Color, title: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(StudioTheme.paperInk)
                .frame(width: 34, height: 28)
                .background(TornPaperShape().fill(color.opacity(0.72)))
                .rotationEffect(.degrees(systemImage == "arrow.up" ? -2 : 2))

            Text(title)
                .font(StudioTypography.footnote.weight(.medium))
                .foregroundStyle(StudioTheme.paperInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func playingState(_: AliasPlayer) -> some View {
        ZStack {
            YaliasPaperBackgroundView()

            VStack(spacing: 0) {
                if aliasGameState.isPaused {
                    pausedControls
                    Spacer().frame(height: 14)
                    scoreBoard
                    Spacer(minLength: 16)
                    pausedContent
                    Spacer(minLength: 16)
                } else {
                    Spacer().frame(height: 12)
                    playingScoreBoard
                    Spacer().frame(height: 60)
                    swipeableWordCard
                    Spacer(minLength: 12)
                    liveControls
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
    }

    private var swipeableWordCard: some View {
        GeometryReader { geometry in
            let cardWidth = min(geometry.size.width - 8, 360)
            let cardHeight: CGFloat = 240
            let centerX = geometry.size.width * 0.5

            ZStack(alignment: .topLeading) {
                swipeActionTab(
                    color: StudioTheme.olive,
                    systemImage: "arrow.up",
                    title: copy("alias.game.stack.guessed", fallback: "Guessed!")
                )
                .frame(width: cardWidth * 0.52, height: 110)
                .position(x: centerX, y: 55)

                swipeActionTab(
                    color: StudioTheme.vermilion,
                    systemImage: "arrow.down",
                    title: copy("alias.game.stack.skip", fallback: "Skip")
                )
                .frame(width: cardWidth * 0.54, height: 110)
                .position(x: centerX, y: 335)

                stackedPaperCard(color: StudioTheme.mustard)
                    .frame(width: cardWidth, height: cardHeight)
                    .rotationEffect(.degrees(-1.8))
                    .position(x: centerX - 6, y: 194)

                stackedPaperCard(color: StudioTheme.sky)
                    .frame(width: cardWidth, height: cardHeight)
                    .rotationEffect(.degrees(1.7))
                    .position(x: centerX + 6, y: 195)

                stackedPaperCard(color: StudioTheme.olive)
                    .frame(width: cardWidth, height: cardHeight)
                    .rotationEffect(.degrees(0.6))
                    .position(x: centerX + 2, y: 198)

                ZStack {
                    TornPaperShape()
                        .fill(wordCardColor)

                    Text(aliasGameState.currentWord?.text.uppercased() ?? "—")
                        .font(.system(size: 43, weight: .black, design: .rounded))
                        .foregroundStyle(StudioTheme.paperInk)
                        .minimumScaleFactor(0.43)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(28)
                }
                .frame(width: cardWidth, height: cardHeight)
                .overlay {
                    TornPaperShape()
                        .stroke(wordCardBorderColor, lineWidth: 1.8)
                }
                .shadow(color: StudioTheme.paperInk.opacity(0.14), radius: 5, x: 1, y: 4)
                .rotationEffect(.degrees(-0.7 + Double(wordDragOffset / 80)))
                .position(x: centerX, y: 190)
                .offset(y: wordDragOffset)
                .opacity(isCompletingSwipe ? 0.92 : 1)
            }
            .frame(width: geometry.size.width, height: 400)
            .contentShape(Rectangle())
            .highPriorityGesture(wordSwipeGesture)
        }
        .frame(height: 400)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(copy("alias.game.swipe.hint", fallback: "Swipe up if guessed or down to skip."))
        .accessibilityAction(named: Text(copy("alias.game.correct", fallback: "Correct +1"))) {
            aliasGameState.markCorrect()
        }
        .accessibilityAction(named: Text(copy("alias.game.skip", fallback: "Skip −1"))) {
            aliasGameState.skipWord()
        }
    }

    private var wordCardColor: Color {
        StudioTheme.paperHighlight
    }

    private var wordCardBorderColor: Color {
        StudioTheme.paperInk.opacity(abs(wordDragOffset) > 18 ? 0.82 : 0.60)
    }

    private func stackedPaperCard(color: Color) -> some View {
        TornPaperShape()
            .fill(color)
            .overlay {
                TornPaperShape()
                    .stroke(StudioTheme.paperInk.opacity(0.48), lineWidth: 1.35)
            }
            .shadow(color: StudioTheme.paperInk.opacity(0.09), radius: 3, x: 1, y: 2)
    }

    private func swipeActionTab(
        color: Color,
        systemImage: String,
        title: String
    ) -> some View {
        let pointsUp = systemImage == "arrow.up"

        return VStack(spacing: 2) {
            if pointsUp {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .black))
                Text(title)
                    .font(StudioTypography.subheadline.weight(.bold))
            } else {
                Text(title)
                    .font(StudioTypography.subheadline.weight(.bold))
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .black))
            }
        }
        .foregroundStyle(StudioTheme.paperHighlight)
        .padding(.top, pointsUp ? 8 : 42)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background {
            SwipeActionTabShape(pointsUp: pointsUp)
                .fill(color)
        }
        .shadow(color: StudioTheme.paperInk.opacity(0.10), radius: 3, x: 1, y: 2)
    }

    private var wordSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard !isCompletingSwipe else { return }
                var transaction = Transaction(animation: nil)
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    wordDragOffset = value.translation.height
                }
            }
            .onEnded { value in
                guard !isCompletingSwipe else { return }
                let translation = value.translation.height
                let isVertical = abs(translation) > abs(value.translation.width)

                if isVertical, translation <= -swipeCompletionDistance {
                    completeSwipe(isCorrect: true)
                } else if isVertical, translation >= swipeCompletionDistance {
                    completeSwipe(isCorrect: false)
                } else {
                    withAnimation(.snappy) {
                        wordDragOffset = 0
                    }
                }
            }
    }

    private func completeSwipe(isCorrect: Bool) {
        guard aliasGameState.currentWord != nil else { return }
        isCompletingSwipe = true
        withAnimation(.easeOut(duration: 0.14)) {
            wordDragOffset = isCorrect ? -520 : 520
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            if isCorrect {
                aliasGameState.markCorrect()
            } else {
                aliasGameState.skipWord()
            }
        }
    }

    private func turnResultState(_ player: AliasPlayer) -> some View {
        contentScreen {
            header(
                title: turnResultTitle(for: player),
                subtitle: turnResultSubtitle(for: player)
            )
            scoreBoard
            card {
                VStack(spacing: 16) {
                    resultRow(copy("alias.game.result.correct", fallback: "Correct"), value: aliasGameState.correctCount, color: StudioTheme.teal)
                    resultRow(copy("alias.game.result.skipped", fallback: "Skipped"), value: aliasGameState.skippedCount, color: StudioTheme.coral)
                    resultRow(copy("alias.game.result.declined", fallback: "Declined"), value: aliasGameState.declinedCount, color: StudioTheme.gold)
                    Divider()
                    HStack {
                        Text(
                            aliasGameState.configuration.mode == .classic
                                ? copy("alias.game.result.turn_score", fallback: "Turn score")
                                : copy("alias.game.result.time", fallback: "Time")
                        )
                        Spacer()
                        Text(turnResultValue(for: player))
                    }
                    .font(StudioTypography.title)
                    .foregroundStyle(StudioTheme.ink)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(copy("alias.game.review.title", fallback: "Review words"))
                    .font(StudioTypography.title)
                    .foregroundStyle(StudioTheme.ink)
                Text(copy("alias.game.review.message", fallback: "Tap a result to correct the score before continuing."))
                    .font(StudioTypography.body)
                    .foregroundStyle(StudioTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if aliasGameState.turnWords.isEmpty {
                Text(copy("alias.game.review.empty", fallback: "No words were completed this turn."))
                    .font(StudioTypography.body)
                    .foregroundStyle(StudioTheme.muted)
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(aliasGameState.turnWords) { turnWord in
                        turnWordReviewRow(turnWord)
                    }
                }
            }

            Button(reviewContinueLabel, action: aliasGameState.continueAfterTurn)
                .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
            menuButton
        }
    }

    private func turnWordReviewRow(_ turnWord: AliasGameState.TurnWord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(turnWord.word.text)
                .font(StudioTypography.title)
                .foregroundStyle(StudioTheme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            HStack(spacing: 8) {
                ForEach(AliasGameState.WordOutcome.allCases) { outcome in
                    reviewOutcomeButton(outcome, for: turnWord)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(StudioTheme.line.opacity(0.5))
        }
    }

    private func reviewOutcomeButton(
        _ outcome: AliasGameState.WordOutcome,
        for turnWord: AliasGameState.TurnWord
    ) -> some View {
        let isSelected = turnWord.outcome == outcome
        let color = reviewOutcomeColor(outcome)

        return Button {
            if !aliasGameState.updateTurnWord(turnWord.id, to: outcome) {
                showsExclusionError = true
            }
        } label: {
            Text(reviewOutcomeLabel(outcome))
                .font(StudioTypography.compactLabel)
                .foregroundStyle(isSelected ? Color.white : color)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity, minHeight: 38)
                .background(isSelected ? color : color.opacity(0.1), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func reviewOutcomeLabel(_ outcome: AliasGameState.WordOutcome) -> String {
        switch outcome {
        case .guessed:
            return copy("alias.game.review.guessed", fallback: "Guessed")
        case .skipped:
            return copy("alias.game.review.skipped", fallback: "Skipped")
        case .declined:
            return copy("alias.game.review.declined", fallback: "Declined")
        }
    }

    private func reviewOutcomeColor(_ outcome: AliasGameState.WordOutcome) -> Color {
        switch outcome {
        case .guessed:
            return StudioTheme.teal
        case .skipped:
            return StudioTheme.coral
        case .declined:
            return StudioTheme.gold
        }
    }

    private var reviewContinueLabel: String {
        if aliasGameState.configuration.mode == .fastest,
           case .turnResult(let player) = aliasGameState.phase,
           aliasGameState.score(for: player) < aliasGameState.configuration.targetScore {
            return copy("alias.game.review.resume", fallback: "Resume turn")
        }
        return copy("alias.game.result.continue", fallback: "Continue")
    }

    private func matchOverState(_ winner: AliasPlayer) -> some View {
        contentScreen {
            header(title: copy("alias.game.over.title", fallback: "%@ wins", playerName(winner)))
            scoreBoard
            Button(copy("alias.game.over.rematch", fallback: "Rematch")) {
                aliasGameState.startMatch(
                    mode: aliasGameState.configuration.mode,
                    targetScore: aliasGameState.configuration.targetScore,
                    turnDuration: Int(aliasGameState.configuration.turnDuration),
                    difficultyLevels: aliasGameState.configuration.difficultyLevels,
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
        HStack(spacing: 12) {
            scoreTile(.one, accent: StudioTheme.teal)

            VStack(spacing: 2) {
                Text(copy("alias.game.goal", fallback: "GOAL"))
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(StudioTheme.muted)
                Text(String(aliasGameState.configuration.targetScore))
                    .font(StudioTypography.subheadline.weight(.semibold))
                    .foregroundStyle(StudioTheme.ink)
            }
            .frame(width: 52)

            scoreTile(.two, accent: StudioTheme.coral)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(StudioTheme.card.opacity(0.66), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var playingScoreBoard: some View {
        HStack(alignment: .center, spacing: 8) {
            playingScoreTile(.one, labelColor: StudioTheme.olive)

            Text(timeText)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(StudioTheme.paperInk)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
                .frame(width: 132, height: 86)
                .background(TornPaperShape().fill(StudioTheme.mustard))
                .overlay {
                    TornPaperShape()
                        .stroke(StudioTheme.paperInk, lineWidth: 2)
                }
                .shadow(color: StudioTheme.paperInk.opacity(0.12), radius: 4, x: 1, y: 3)
                .accessibilityLabel(timerAccessibilityLabel)

            playingScoreTile(.two, labelColor: StudioTheme.sky)
        }
        .frame(maxWidth: .infinity)
    }

    private func playingScoreTile(_ player: AliasPlayer, labelColor: Color) -> some View {
        VStack(spacing: -22) {
            Text(playerName(player))
                .font(StudioTypography.footnote.weight(.bold))
                .foregroundStyle(StudioTheme.paperHighlight)
                .lineLimit(1)
                .minimumScaleFactor(0.64)
                .frame(maxWidth: .infinity, minHeight: 42)
                .padding(.horizontal, 6)
                .background(TornPaperShape().fill(labelColor))
                .offset(y: -4)
                .zIndex(2)

            Text(String(aliasGameState.score(for: player)))
                .font(.system(size: 39, weight: .black, design: .rounded))
                .foregroundStyle(StudioTheme.paperInk)
                .monospacedDigit()
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(TornPaperShape().fill(StudioTheme.paperHighlight))
                .overlay {
                    TornPaperShape()
                        .stroke(StudioTheme.paperInk, lineWidth: 2)
                }
        }
        .frame(maxWidth: .infinity)
        .shadow(color: StudioTheme.paperInk.opacity(0.10), radius: 3, x: 1, y: 2)
    }

    private func scoreTile(_ player: AliasPlayer, accent: Color) -> some View {
        HStack(spacing: 8) {
            if player == .two {
                scoreValue(player, accent: accent)
            }

            VStack(alignment: player == .one ? .leading : .trailing, spacing: 2) {
                Text(playerName(player))
                    .font(StudioTypography.footnote)
                    .foregroundStyle(StudioTheme.muted)
                    .lineLimit(1)

                if aliasGameState.configuration.mode == .fastest,
                   let elapsedTime = aliasGameState.elapsedTime(for: player) {
                    Text(formatDuration(elapsedTime))
                        .font(StudioTypography.compactLabel)
                        .foregroundStyle(StudioTheme.muted)
                        .monospacedDigit()
                }
            }

            if player == .one {
                scoreValue(player, accent: accent)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func scoreValue(_ player: AliasPlayer, accent: Color) -> some View {
        Text(String(aliasGameState.score(for: player)))
            .font(.system(size: 25, weight: .black, design: .rounded))
            .foregroundStyle(accent)
            .monospacedDigit()
    }

    private var liveControls: some View {
        HStack(spacing: 18) {
            Button(action: pauseTurn) {
                gameplayControlIcon("pause.fill")
            }
            .buttonStyle(.plain)
            .accessibilityLabel(copy("alias.game.pause", fallback: "Pause"))

            Button {
                explanationWord = aliasGameState.currentWord
            } label: {
                gameplayControlIcon("book.closed")
            }
            .buttonStyle(.plain)
            .disabled(aliasGameState.currentWord == nil)
            .accessibilityLabel(copy("alias.explanation.action", fallback: "Explain word"))

            Button(action: excludeCurrentWord) {
                gameplayControlIcon("nosign")
            }
            .buttonStyle(.plain)
            .disabled(aliasGameState.currentWord == nil)
            .accessibilityLabel(copy("alias.game.exclude", fallback: "Exclude word"))

            Button(action: returnToMenu) {
                gameplayControlIcon("line.3.horizontal")
            }
            .buttonStyle(.plain)
            .accessibilityLabel(copy("common.menu", fallback: "Menu"))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func gameplayControlIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 20, weight: .black))
            .foregroundStyle(StudioTheme.paperInk)
            .frame(width: 50, height: 50)
            .background(StudioTheme.paperHighlight, in: Circle())
            .overlay {
                Circle().stroke(StudioTheme.paperInk, lineWidth: 2)
            }
            .shadow(color: StudioTheme.paperInk.opacity(0.11), radius: 3, x: 1, y: 2)
    }

    private var pausedControls: some View {
        HStack {
            Text(timeText)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timerColor)
                .accessibilityLabel(timerAccessibilityLabel)

            Spacer()

            Button(action: returnToMenu) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(StudioTheme.inkSoft)
                    .frame(width: 40, height: 40)
                    .background(StudioTheme.card.opacity(0.74), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(copy("common.menu", fallback: "Menu"))
        }
    }

    private var pausedContent: some View {
        VStack(spacing: 20) {
            Text(copy("alias.game.paused", fallback: "Paused"))
                .font(StudioTypography.displaySmall)
                .foregroundStyle(StudioTheme.ink)

            Button(copy("alias.game.resume", fallback: "Resume")) {
                aliasGameState.resumeTurn()
            }
            .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.teal)))
        }
        .frame(maxWidth: .infinity)
    }

    private var menuButton: some View {
        Button(copy("common.menu", fallback: "Menu"), action: returnToMenu)
            .font(StudioTypography.subheadline)
            .foregroundStyle(StudioTheme.muted)
            .frame(minHeight: 44)
            .buttonStyle(.plain)
    }

    private func excludeCurrentWord() {
        if !aliasGameState.excludeCurrentWord(),
           case .playing = aliasGameState.phase {
            showsExclusionError = true
        }
    }

    private func pauseTurn() {
        wordDragOffset = 0
        isCompletingSwipe = false
        aliasGameState.pause()
    }

    private func returnToMenu() {
        aliasGameState.returnToMenu()
        navigationState.showMenu()
    }

    private func header(title: String, subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if aliasGameState.isOvertime {
                Text(copy("alias.game.overtime", fallback: "OVERTIME"))
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(StudioTheme.coral)
            }
            Text(title)
                .font(StudioTypography.displaySmall)
                .foregroundStyle(StudioTheme.ink)
            if let subtitle {
                Text(subtitle)
                    .font(StudioTypography.body)
                    .foregroundStyle(StudioTheme.muted)
            }
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
            VStack(spacing: 16, content: content)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 36)
        }
    }

    private func messageScreen<Content: View>(
        icon: String,
        title: String,
        message: String,
        @ViewBuilder action: () -> Content
    ) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(StudioTheme.coral)
            Text(title)
                .font(StudioTypography.displaySmall)
                .foregroundStyle(StudioTheme.ink)
                .multilineTextAlignment(.center)
            Text(message)
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            action()
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
                    .stroke(StudioTheme.line.opacity(0.5))
            }
    }

    private var timeText: String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return formatDuration(TimeInterval(aliasGameState.secondsRemaining), showsTenths: false)
        case .fastest:
            return formatDuration(aliasGameState.elapsedTime, showsTenths: false)
        }
    }

    private var timerColor: Color {
        if aliasGameState.configuration.mode == .classic,
           aliasGameState.secondsRemaining <= 10 {
            return StudioTheme.coral
        }
        return StudioTheme.teal
    }

    private var timerAccessibilityLabel: String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return copy(
                "alias.game.timer.accessibility",
                fallback: "%d seconds remaining",
                aliasGameState.secondsRemaining
            )
        case .fastest:
            return copy(
                "alias.game.timer.elapsed.accessibility",
                fallback: "%d seconds elapsed",
                Int(aliasGameState.elapsedTime)
            )
        }
    }

    private func turnResultTitle(for player: AliasPlayer) -> String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return copy("alias.game.result.title", fallback: "%@’s turn is over", playerName(player))
        case .fastest:
            if aliasGameState.score(for: player) < aliasGameState.configuration.targetScore {
                return copy(
                    "alias.game.result.fastest.resume_title",
                    fallback: "%@ needs more points",
                    playerName(player)
                )
            }
            return copy("alias.game.result.fastest.title", fallback: "%@ reached the goal", playerName(player))
        }
    }

    private func turnResultSubtitle(for _: AliasPlayer) -> String? {
        switch aliasGameState.configuration.mode {
        case .classic:
            return copy("alias.game.result.round", fallback: "Round %d", aliasGameState.roundNumber)
        case .fastest:
            return nil
        }
    }

    private func turnResultValue(for player: AliasPlayer) -> String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return signed(aliasGameState.turnScore)
        case .fastest:
            return formatDuration(aliasGameState.elapsedTime(for: player) ?? aliasGameState.elapsedTime)
        }
    }

    private func formatDuration(_ duration: TimeInterval, showsTenths: Bool = false) -> String {
        let clampedDuration = max(0, duration)
        let minutes = Int(clampedDuration) / 60
        let seconds = Int(clampedDuration) % 60
        if showsTenths {
            let tenths = Int((clampedDuration * 10).rounded(.down)) % 10
            return String(format: "%d:%02d.%d", minutes, seconds, tenths)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func signed(_ value: Int) -> String {
        value > 0 ? "+\(value)" : String(value)
    }

    private func playerName(_ player: AliasPlayer) -> String {
        let stored = (player == .one ? storedPlayerOneName : storedPlayerTwoName)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !stored.isEmpty { return stored }
        return player == .one
            ? copy("player.one", fallback: "Player 1")
            : copy("player.two", fallback: "Player 2")
    }

    private func copy(_ key: String, fallback: String) -> String {
        aliasLocalized(key, fallback: fallback)
    }

    private func copy(_ key: String, fallback: String, _ value: CVarArg) -> String {
        aliasLocalizedFormat(key, fallback: fallback, value)
    }
}

private struct SwipeActionTabShape: Shape {
    let pointsUp: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let left = rect.minX + 5
        let right = rect.maxX - 5
        let top = rect.minY + 4
        let bottom = rect.maxY - 4

        if pointsUp {
            path.move(to: CGPoint(x: left, y: bottom - 3))
            path.addLine(to: CGPoint(x: left + 1, y: rect.midY + 4))
            path.addLine(to: CGPoint(x: left + 16, y: rect.midY - 5))
            path.addQuadCurve(
                to: CGPoint(x: rect.midX, y: top),
                control: CGPoint(x: rect.midX - 34, y: top + 24)
            )
            path.addQuadCurve(
                to: CGPoint(x: right - 15, y: rect.midY - 3),
                control: CGPoint(x: rect.midX + 35, y: top + 24)
            )
            path.addLine(to: CGPoint(x: right, y: rect.midY + 5))
            path.addLine(to: CGPoint(x: right - 2, y: bottom - 1))
            path.addLine(to: CGPoint(x: rect.midX + 30, y: bottom - 4))
            path.addLine(to: CGPoint(x: rect.midX - 22, y: bottom))
        } else {
            path.move(to: CGPoint(x: left, y: top + 3))
            path.addLine(to: CGPoint(x: rect.midX - 28, y: top))
            path.addLine(to: CGPoint(x: right, y: top + 4))
            path.addLine(to: CGPoint(x: right - 1, y: rect.midY - 4))
            path.addLine(to: CGPoint(x: right - 16, y: rect.midY + 5))
            path.addQuadCurve(
                to: CGPoint(x: rect.midX, y: bottom),
                control: CGPoint(x: rect.midX + 34, y: bottom - 24)
            )
            path.addQuadCurve(
                to: CGPoint(x: left + 15, y: rect.midY + 5),
                control: CGPoint(x: rect.midX - 35, y: bottom - 24)
            )
            path.addLine(to: CGPoint(x: left, y: rect.midY - 4))
        }

        path.closeSubpath()
        return path
    }
}
