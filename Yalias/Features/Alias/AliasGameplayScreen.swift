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
    @State private var reviewScrollOffset: CGFloat = 0
    @State private var reviewContentHeight: CGFloat = 0
    @State private var reviewViewportHeight: CGFloat = 0
    @State private var showsLoadingIndicator = false
    @State private var loadingShufflePhase = false

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
        .sheet(item: $explanationWord, onDismiss: resumeAfterExplanation) { word in
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
        ZStack {
            YaliasPaperBackgroundView()

            if showsLoadingIndicator {
                VStack(spacing: 18) {
                    loadingCardStack

                    Text(copy("alias.game.loading.title", fallback: "Shuffling words") + "…")
                        .font(StudioTypography.paperControl)
                        .foregroundStyle(StudioTheme.paperInk)
                        .multilineTextAlignment(.center)
                }
                .transition(.opacity)
            }
        }
        .task {
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                showsLoadingIndicator = false
                loadingShufflePhase = false
            }

            do {
                try await Task.sleep(for: .milliseconds(200))
            } catch {
                return
            }
            guard case .loading = aliasGameState.phase else { return }

            withAnimation(.easeOut(duration: 0.16)) {
                showsLoadingIndicator = true
            }
            withAnimation(.easeInOut(duration: 0.52).repeatForever(autoreverses: true)) {
                loadingShufflePhase = true
            }
        }
    }

    private var loadingCardStack: some View {
        ZStack {
            loadingCard(color: StudioTheme.sky)
                .rotationEffect(.degrees(loadingShufflePhase ? 8 : 4))
                .offset(x: loadingShufflePhase ? 12 : 8, y: -7)

            loadingCard(color: StudioTheme.olive)
                .rotationEffect(.degrees(loadingShufflePhase ? -8 : -4))
                .offset(x: loadingShufflePhase ? -12 : -8, y: 1)

            loadingCard(color: StudioTheme.paperHighlight)
                .overlay(alignment: .top) {
                    TornPaperShape()
                        .fill(StudioTheme.mustard)
                        .frame(height: 11)
                }
                .rotationEffect(.degrees(loadingShufflePhase ? 1.5 : -1.5))
                .offset(y: loadingShufflePhase ? 4 : 0)
        }
        .frame(width: 116, height: 84)
        .shadow(color: StudioTheme.paperInk.opacity(0.12), radius: 4, x: 1, y: 3)
        .accessibilityHidden(true)
    }

    private func loadingCard(color: Color) -> some View {
        TornPaperShape()
            .fill(color)
            .frame(width: 86, height: 58)
            .overlay {
                TornPaperShape()
                    .stroke(StudioTheme.paperInk, lineWidth: 1.5)
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
        ZStack {
            YaliasPaperBackgroundView()

            VStack(spacing: 14) {
                turnResultHeader(player)
                turnReviewPanel
                    .frame(maxHeight: 490)

                Spacer(minLength: 0)

                Button(reviewContinueLabel, action: aliasGameState.continueAfterTurn)
                    .buttonStyle(PaperActionButtonStyle(kind: .filled(StudioTheme.vermilion)))
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
    }

    private func turnResultHeader(_ player: AliasPlayer) -> some View {
        ZStack(alignment: .topLeading) {
            Button(action: returnToMenu) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(StudioTheme.paperInk)
                    .frame(width: 44, height: 44)
                    .background(StudioTheme.paperHighlight, in: Circle())
                    .overlay { Circle().stroke(StudioTheme.paperInk, lineWidth: 1.8) }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(copy("common.menu", fallback: "Menu"))

            HStack(alignment: .bottom, spacing: 10) {
                ZStack(alignment: .top) {
                    Text(copy("alias.game.result.completed", fallback: "Turn complete"))
                        .font(StudioTypography.paperTitle)
                        .foregroundStyle(StudioTheme.paperInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity, minHeight: 66)
                        .padding(.top, 8)
                        .background(TornPaperShape().fill(StudioTheme.paperHighlight))
                        .overlay {
                            TornPaperShape()
                                .stroke(StudioTheme.paperInk, lineWidth: 1.8)
                        }

                    Text(playerName(player))
                        .font(StudioTypography.subheadline.weight(.bold))
                        .foregroundStyle(StudioTheme.paperHighlight)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .padding(.horizontal, 18)
                        .frame(minWidth: 112, minHeight: 34)
                        .background(TornPaperShape().fill(StudioTheme.olive))
                        .offset(y: -13)
                }
                .padding(.top, 13)

                Text(turnResultBadgeText(for: player))
                    .font(StudioTypography.subheadline.weight(.bold))
                    .foregroundStyle(StudioTheme.paperInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                    .padding(.horizontal, 12)
                    .frame(minWidth: 104, minHeight: 54)
                    .background(TornPaperShape().fill(StudioTheme.mustard))
                    .overlay {
                        TornPaperShape()
                            .stroke(StudioTheme.paperInk, lineWidth: 1.6)
                    }
                    .padding(.bottom, 1)
            }
            .padding(.leading, 54)
        }
        .frame(maxWidth: .infinity)
    }

    private var turnReviewPanel: some View {
        VStack(spacing: 10) {
            Text(copy("alias.game.review.title", fallback: "Review words"))
                .font(StudioTypography.paperTitle)
                .foregroundStyle(StudioTheme.paperInk)

            reviewLegend

            Capsule()
                .fill(StudioTheme.paperInk.opacity(0.48))
                .frame(height: 1.5)
                .padding(.horizontal, 6)

            if aliasGameState.turnWords.isEmpty {
                Text(copy("alias.game.review.empty", fallback: "No words were completed this turn."))
                    .font(StudioTypography.body)
                    .foregroundStyle(StudioTheme.paperInk.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(20)
            } else {
                ZStack(alignment: .trailing) {
                    ScrollView(.vertical) {
                        VStack(spacing: 8) {
                            ForEach(aliasGameState.turnWords) { turnWord in
                                turnWordReviewRow(turnWord)
                            }
                        }
                        .padding(.horizontal, 2)
                        .padding(.vertical, 2)
                        .padding(.trailing, 20)
                        .background {
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(
                                        key: ReviewScrollOffsetPreferenceKey.self,
                                        value: max(
                                            0,
                                            -proxy.frame(in: .named("turnReviewScroll")).minY
                                        )
                                    )
                                    .preference(
                                        key: ReviewContentHeightPreferenceKey.self,
                                        value: proxy.size.height
                                    )
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .background {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ReviewViewportHeightPreferenceKey.self,
                                value: proxy.size.height
                            )
                        }
                    }

                    if reviewContentHeight > reviewViewportHeight + 1 {
                        reviewScrollIndicator
                            .padding(.vertical, 4)
                            .padding(.trailing, 2)
                    }
                }
                .coordinateSpace(name: "turnReviewScroll")
                .onPreferenceChange(ReviewScrollOffsetPreferenceKey.self) {
                    reviewScrollOffset = $0
                }
                .onPreferenceChange(ReviewContentHeightPreferenceKey.self) {
                    reviewContentHeight = $0
                }
                .onPreferenceChange(ReviewViewportHeightPreferenceKey.self) {
                    reviewViewportHeight = $0
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                TornPaperShape()
                    .fill(StudioTheme.mustard)
                    .offset(x: -5, y: 5)
                TornPaperShape()
                    .fill(StudioTheme.sky)
                    .offset(x: 5, y: 6)
                TornPaperShape()
                    .fill(StudioTheme.olive)
                    .offset(y: 9)
                TornPaperShape()
                    .fill(StudioTheme.paperHighlight)
            }
        }
        .overlay {
            TornPaperShape()
                .stroke(StudioTheme.paperInk.opacity(0.72), lineWidth: 1.5)
        }
        .shadow(color: StudioTheme.paperInk.opacity(0.11), radius: 5, x: 1, y: 4)
    }

    private var reviewScrollIndicator: some View {
        GeometryReader { geometry in
            let trackHeight = max(geometry.size.height, 1)
            let visibleRatio = min(reviewViewportHeight / max(reviewContentHeight, 1), 1)
            let thumbHeight = max(34, trackHeight * visibleRatio)
            let thumbTravel = max(trackHeight - thumbHeight, 0)
            let maxScrollOffset = max(reviewContentHeight - reviewViewportHeight, 1)
            let progress = min(max(reviewScrollOffset / maxScrollOffset, 0), 1)

            ZStack(alignment: .top) {
                Capsule()
                    .fill(StudioTheme.paperHighlight)
                    .overlay {
                        Capsule()
                            .stroke(StudioTheme.paperInk, lineWidth: 1.4)
                    }

                Capsule()
                    .fill(StudioTheme.olive)
                    .frame(height: thumbHeight)
                    .overlay {
                        Capsule()
                            .stroke(StudioTheme.paperInk, lineWidth: 1.2)
                    }
                    .offset(y: thumbTravel * progress)
            }
            .frame(width: 14)
        }
        .frame(width: 14)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var reviewLegend: some View {
        HStack(spacing: 6) {
            ForEach(AliasGameState.WordOutcome.allCases) { outcome in
                VStack(spacing: 3) {
                    Image(systemName: reviewOutcomeSystemImage(outcome))
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(reviewOutcomeForegroundColor(outcome))
                        .frame(width: 28, height: 28)
                        .background(reviewOutcomeColor(outcome), in: Circle())

                    Text(reviewOutcomeLabel(outcome))
                        .font(StudioTypography.compactLabel)
                        .foregroundStyle(StudioTheme.paperInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(TornPaperShape().fill(StudioTheme.mustard.opacity(0.18)))
    }

    private func turnWordReviewRow(_ turnWord: AliasGameState.TurnWord) -> some View {
        HStack(spacing: 8) {
            Text(turnWord.word.text)
                .font(StudioTypography.subheadline.weight(.bold))
                .foregroundStyle(StudioTheme.paperInk)
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                ForEach(AliasGameState.WordOutcome.allCases) { outcome in
                    reviewOutcomeButton(outcome, for: turnWord)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StudioTheme.paper, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(StudioTheme.paperInk.opacity(0.68), lineWidth: 1.4)
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
            Image(systemName: reviewOutcomeSystemImage(outcome))
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(isSelected ? reviewOutcomeForegroundColor(outcome) : StudioTheme.paperInk)
                .frame(width: 42, height: 42)
                .background(isSelected ? color : StudioTheme.paperHighlight, in: Circle())
                .overlay {
                    Circle()
                        .stroke(StudioTheme.paperInk, lineWidth: isSelected ? 1.4 : 1.8)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(reviewOutcomeLabel(outcome))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func reviewOutcomeSystemImage(_ outcome: AliasGameState.WordOutcome) -> String {
        switch outcome {
        case .guessed: return "checkmark"
        case .skipped: return "arrow.down"
        case .declined: return "nosign"
        }
    }

    private func reviewOutcomeLabel(_ outcome: AliasGameState.WordOutcome) -> String {
        switch outcome {
        case .guessed:
            return copy("alias.game.review.guessed", fallback: "Guessed")
        case .skipped:
            return copy("alias.game.review.skipped", fallback: "Skipped")
        case .declined:
            return copy("alias.game.review.declined", fallback: "Excluded")
        }
    }

    private func reviewOutcomeColor(_ outcome: AliasGameState.WordOutcome) -> Color {
        switch outcome {
        case .guessed:
            return StudioTheme.olive
        case .skipped:
            return StudioTheme.vermilion
        case .declined:
            return StudioTheme.mustard
        }
    }

    private func reviewOutcomeForegroundColor(_ outcome: AliasGameState.WordOutcome) -> Color {
        outcome == .declined ? StudioTheme.paperInk : StudioTheme.paperHighlight
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
        ZStack {
            YaliasPaperBackgroundView()

            VStack(spacing: 14) {
                matchWinnerTrophy

                Text(copy("alias.game.over.title", fallback: "%@ wins", playerName(winner)))
                    .font(StudioTypography.paperTitle)
                    .foregroundStyle(StudioTheme.paperHighlight)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(TornPaperShape().fill(StudioTheme.olive))
                    .shadow(color: StudioTheme.paperInk.opacity(0.15), radius: 5, x: 1, y: 4)
                    .zIndex(2)

                finalResultPanel(winner)
                    .offset(y: -24)

                Spacer(minLength: 0)

                Button(copy("alias.game.over.rematch", fallback: "Play again")) {
                    aliasGameState.startMatch(
                        mode: aliasGameState.configuration.mode,
                        targetScore: aliasGameState.configuration.targetScore,
                        turnDuration: Int(aliasGameState.configuration.turnDuration),
                        difficultyLevels: aliasGameState.configuration.difficultyLevels,
                        includeAdjectives: aliasGameState.configuration.includeAdjectives
                    )
                }
                .buttonStyle(PaperActionButtonStyle(kind: .filled(StudioTheme.vermilion)))

                Button(copy("alias.game.over.main_menu", fallback: "Main menu"), action: returnToMenu)
                    .buttonStyle(PaperActionButtonStyle(kind: .outlined))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
    }

    private var matchWinnerTrophy: some View {
        ZStack {
            Capsule()
                .fill(StudioTheme.paperInk)
                .frame(width: 4, height: 15)
                .offset(y: -37)

            Capsule()
                .fill(StudioTheme.paperInk)
                .frame(width: 4, height: 15)
                .rotationEffect(.degrees(-42))
                .offset(x: -28, y: -28)

            Capsule()
                .fill(StudioTheme.paperInk)
                .frame(width: 4, height: 15)
                .rotationEffect(.degrees(42))
                .offset(x: 28, y: -28)

            Image(systemName: "trophy.fill")
                .font(.system(size: 50, weight: .black))
                .foregroundStyle(StudioTheme.paperInk)

            Image(systemName: "trophy.fill")
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(StudioTheme.mustard)
        }
        .frame(width: 90, height: 74)
        .accessibilityHidden(true)
    }

    private func finalResultPanel(_ winner: AliasPlayer) -> some View {
        VStack(spacing: 20) {
            Text(finalResultTitle)
                .font(StudioTypography.paperTitle)
                .foregroundStyle(StudioTheme.paperInk)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            HStack(spacing: 14) {
                finalResultTile(.one, winner: winner, accent: StudioTheme.olive)
                finalResultTile(.two, winner: winner, accent: StudioTheme.sky)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 52)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity)
        .background {
            ZStack {
                TornPaperShape()
                    .fill(StudioTheme.mustard)
                    .offset(x: -6, y: 7)
                TornPaperShape()
                    .fill(StudioTheme.sky)
                    .offset(x: 7, y: 7)
                TornPaperShape()
                    .fill(StudioTheme.olive)
                    .offset(y: 10)
                TornPaperShape()
                    .fill(StudioTheme.paperHighlight)
            }
        }
        .overlay {
            TornPaperShape()
                .stroke(StudioTheme.paperInk, lineWidth: 1.8)
        }
        .shadow(color: StudioTheme.paperInk.opacity(0.12), radius: 6, x: 1, y: 5)
    }

    private func finalResultTile(
        _ player: AliasPlayer,
        winner: AliasPlayer,
        accent: Color
    ) -> some View {
        VStack(spacing: -14) {
            Text(playerName(player))
                .font(StudioTypography.subheadline.weight(.bold))
                .foregroundStyle(StudioTheme.paperHighlight)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(TornPaperShape().fill(accent))
                .zIndex(2)

            VStack(spacing: 6) {
                Text(finalResultValue(for: player))
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(StudioTheme.paperInk)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                Capsule()
                    .fill(player == winner ? StudioTheme.mustard : .clear)
                    .frame(height: 5)
                    .padding(.horizontal, 12)
            }
            .padding(.horizontal, 10)
            .padding(.top, 20)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, minHeight: 112)
            .background(TornPaperShape().fill(StudioTheme.paperHighlight))
            .overlay {
                TornPaperShape()
                    .stroke(StudioTheme.paperInk, lineWidth: 1.8)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var finalResultTitle: String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return copy("alias.game.over.final_score", fallback: "Final score")
        case .fastest:
            return copy("alias.game.over.final_time", fallback: "Final time")
        }
    }

    private func finalResultValue(for player: AliasPlayer) -> String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return String(aliasGameState.score(for: player))
        case .fastest:
            guard let elapsedTime = aliasGameState.elapsedTime(for: player) else { return "—" }
            return formatDuration(elapsedTime, showsTenths: true)
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

            Button(action: openWordExplanation) {
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

    private func openWordExplanation() {
        guard let currentWord = aliasGameState.currentWord else { return }
        wordDragOffset = 0
        isCompletingSwipe = false
        aliasGameState.pause()
        explanationWord = currentWord
    }

    private func resumeAfterExplanation() {
        aliasGameState.resumeTurn()
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

    private func turnResultValue(for player: AliasPlayer) -> String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return signed(aliasGameState.turnScore)
        case .fastest:
            return formatDuration(aliasGameState.elapsedTime(for: player) ?? aliasGameState.elapsedTime)
        }
    }

    private func turnResultBadgeText(for player: AliasPlayer) -> String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return copy(
                "alias.game.result.summary_score",
                fallback: "Result %@",
                turnResultValue(for: player)
            )
        case .fastest:
            return copy(
                "alias.game.result.summary_time",
                fallback: "Time %@",
                turnResultValue(for: player)
            )
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

private struct ReviewScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ReviewContentHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ReviewViewportHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
