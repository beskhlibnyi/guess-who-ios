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

    private func readyState(_ player: AliasPlayer) -> some View {
        contentScreen {
            header(title: playerName(player), subtitle: readyTitle)
            Text(readyMessage)
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 20)
            Button(copy("alias.game.ready.cta", fallback: "Start Turn")) {
                aliasGameState.startTurn()
            }
            .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
            menuButton
        }
    }

    private func playingState(_: AliasPlayer) -> some View {
        VStack(spacing: 16) {
            if aliasGameState.isPaused {
                pausedControls
            } else {
                liveControls
            }
            scoreBoard

            Spacer(minLength: 16)

            if aliasGameState.isPaused {
                pausedContent
            } else {
                swipeableWordCard
            }

            Spacer(minLength: 16)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }

    private var swipeableWordCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(wordCardColor)

            Text(aliasGameState.currentWord?.text ?? "—")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(StudioTheme.ink)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(28)

            if abs(wordDragOffset) > 18 {
                Image(systemName: wordDragOffset < 0 ? "checkmark.circle.fill" : "minus.circle.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(wordDragOffset < 0 ? StudioTheme.teal : StudioTheme.coral)
                    .frame(maxHeight: .infinity, alignment: wordDragOffset < 0 ? .bottom : .top)
                    .padding(20)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(wordCardBorderColor, lineWidth: abs(wordDragOffset) > 18 ? 2 : 1)
        }
        .offset(y: wordDragOffset)
        .highPriorityGesture(wordSwipeGesture)
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
        guard abs(wordDragOffset) > 18 else { return StudioTheme.card }
        return (wordDragOffset < 0 ? StudioTheme.teal : StudioTheme.coral).opacity(0.1)
    }

    private var wordCardBorderColor: Color {
        guard abs(wordDragOffset) > 18 else { return StudioTheme.line.opacity(0.55) }
        return (wordDragOffset < 0 ? StudioTheme.teal : StudioTheme.coral).opacity(0.55)
    }

    private var wordSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard !isCompletingSwipe,
                      abs(value.translation.height) > abs(value.translation.width) else { return }
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

                if isVertical, translation <= -64 {
                    completeSwipe(isCorrect: true)
                } else if isVertical, translation >= 64 {
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
        HStack(spacing: 12) {
            Text(timeText)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timerColor)
                .accessibilityLabel(timerAccessibilityLabel)

            Spacer()

            Button(action: pauseTurn) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(StudioTheme.inkSoft)
                    .frame(width: 40, height: 40)
                    .background(StudioTheme.card.opacity(0.74), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(copy("alias.game.pause", fallback: "Pause"))

            Button {
                explanationWord = aliasGameState.currentWord
            } label: {
                Image(systemName: "book.closed")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(StudioTheme.teal)
                    .frame(width: 40, height: 40)
                    .background(StudioTheme.teal.opacity(0.1), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(aliasGameState.currentWord == nil)
            .accessibilityLabel(copy("alias.explanation.action", fallback: "Explain word"))

            Button(action: excludeCurrentWord) {
                Image(systemName: "rectangle.badge.minus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(StudioTheme.coral)
                    .frame(width: 40, height: 40)
                    .background(StudioTheme.coral.opacity(0.1), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(aliasGameState.currentWord == nil)
            .accessibilityLabel(copy("alias.game.exclude", fallback: "Exclude word"))

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
            return formatDuration(aliasGameState.elapsedTime)
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

    private var readyTitle: String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return copy(
                "alias.game.ready.title",
                fallback: "%d seconds",
                Int(aliasGameState.configuration.turnDuration)
            )
        case .fastest:
            return copy(
                "alias.game.ready.fastest.title",
                fallback: "Reach %d points",
                aliasGameState.configuration.targetScore
            )
        }
    }

    private var readyMessage: String {
        switch aliasGameState.configuration.mode {
        case .classic:
            return copy(
                "alias.game.ready.message",
                fallback: "Describe each word without saying it. Swipe up when guessed or down to skip."
            )
        case .fastest:
            return copy(
                "alias.game.ready.fastest.message",
                fallback: "The stopwatch runs until you reach the goal. Swipe up when guessed or down to skip."
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

    private func formatDuration(_ duration: TimeInterval, showsTenths: Bool = true) -> String {
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
