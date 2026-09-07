import SwiftUI

/// Persistent word-review screen for preparing the Alias game deck.
struct AliasVocabularyPreviewScreen: View {
    @EnvironmentObject private var gameState: GameState
    @AppStorage(AliasVocabulary.includeAdjectivesKey) private var includeAdjectives = true
    @State private var selectedLevel: AliasVocabulary.DifficultyLevel = .easy
    @State private var pageWords: [AliasVocabulary.Word] = []
    @State private var approvedWords: [AliasVocabulary.Word] = []
    @State private var discardedWords: [AliasVocabulary.Word] = []
    @State private var statisticsByLevel: [AliasVocabulary.DifficultyLevel: AliasVocabulary.Statistics] = [:]
    @State private var shuffleSeed = AliasVocabulary.persistentReviewShuffleSeed()
    @State private var approvedPage = 0
    @State private var discardedPage = 0
    @State private var approvedBasketExpanded = false
    @State private var discardedBasketExpanded = false
    @State private var difficultyStatisticsExpanded = false
    @State private var presentedWord: AliasVocabulary.Word?
    @State private var loadID = UUID()
    @State private var isLoading = true

    private let pageSize = 9
    private let basketPageSize = 9
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    private var selectedStatistics: AliasVocabulary.Statistics {
        statisticsByLevel[selectedLevel] ?? .zero
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header
                reviewBasket(.approved, isExpanded: $approvedBasketExpanded)
                wordGrid
                reviewBasket(.discarded, isExpanded: $discardedBasketExpanded)
                levelTabs
                deckDetails
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .task { loadPage() }
        .onChange(of: approvedPage) { _, _ in
            approvedWords = []
            loadPage()
        }
        .onChange(of: discardedPage) { _, _ in
            discardedWords = []
            loadPage()
        }
        .onChange(of: selectedLevel) { _, _ in
            clearWords()
            approvedPage = 0
            discardedPage = 0
            loadPage()
        }
        .onChange(of: includeAdjectives) { _, _ in
            presentedWord = nil
            clearWords()
            approvedPage = 0
            discardedPage = 0
            loadPage()
        }
        .fullScreenCover(item: $presentedWord) { word in
            AliasWordReviewModal(
                word: word,
                approveLabel: copy("alias.preview.approve", fallback: "Approve"),
                discardLabel: copy("alias.preview.discard", fallback: "Discard"),
                hint: copy(
                    "alias.preview.modal_hint",
                    fallback: "Swipe up to approve or down to discard."
                ),
                closeLabel: copy("alias.preview.close", fallback: "Close"),
                onReview: { decision in
                    presentedWord = nil
                    review(word, as: decision)
                },
                onClose: {
                    presentedWord = nil
                }
            )
            .presentationBackground(.clear)
            .interactiveDismissDisabled()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(copy("common.back", fallback: "Back"), action: gameState.showMenu)
                .buttonStyle(ActionButtonStyle(kind: .ghost))
            Spacer(minLength: 0)
            Text(copy("game.alias.preview", fallback: "Review words"))
                .font(StudioTypography.subheadline)
                .foregroundStyle(StudioTheme.ink)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var deckDetails: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(copy("alias.statistics.title", fallback: "Deck statistics"))
                .font(StudioTypography.displaySmall)
                .foregroundStyle(StudioTheme.ink)

            Toggle(isOn: $includeAdjectives) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(copy("alias.filter.adjectives", fallback: "Include adjectives"))
                        .font(StudioTypography.label)
                        .foregroundStyle(StudioTheme.ink)
                    Text(copy("alias.filter.adjectives.message", fallback: "Nouns are always included."))
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)
                }
            }
            .tint(StudioTheme.teal)

            statisticsSection(
                title: levelTitle(for: selectedLevel),
                statistics: selectedStatistics,
                accent: levelAccent(for: selectedLevel)
            )

            Button {
                withAnimation(.snappy) {
                    difficultyStatisticsExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(copy("alias.statistics.other_difficulties", fallback: "Other difficulty levels"))
                        .font(StudioTypography.label)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(StudioTypography.compactLabel)
                        .rotationEffect(.degrees(difficultyStatisticsExpanded ? 180 : 0))
                }
                .foregroundStyle(StudioTheme.muted)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if difficultyStatisticsExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(AliasVocabulary.DifficultyLevel.allCases.filter { $0 != selectedLevel }, id: \.self) { level in
                        statisticsSection(
                            title: levelTitle(for: level),
                            statistics: statisticsByLevel[level] ?? .zero,
                            accent: levelAccent(for: level)
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(24)
        .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(StudioTheme.line.opacity(0.8))
        }
    }

    private func statisticsSection(
        title: String,
        statistics: AliasVocabulary.Statistics,
        accent: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(StudioTypography.label)
                .foregroundStyle(accent)

            HStack(spacing: 8) {
                statisticCell(
                    value: statistics.total,
                    label: copy("alias.statistics.total", fallback: "Total")
                )
                statisticCell(
                    value: statistics.revealed,
                    label: copy("alias.statistics.revealed", fallback: "Revealed")
                )
                statisticCell(
                    value: statistics.approved,
                    label: copy("alias.statistics.approved", fallback: "Approved")
                )
                statisticCell(
                    value: statistics.discarded,
                    label: copy("alias.statistics.discarded", fallback: "Discarded")
                )
            }
        }
    }

    private func statisticCell(value: Int, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value.formatted())
                .font(StudioTypography.subheadline)
                .foregroundStyle(StudioTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Text(label)
                .font(StudioTypography.footnote)
                .foregroundStyle(StudioTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.52), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var levelTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AliasVocabulary.DifficultyLevel.allCases, id: \.self) { level in
                    Button {
                        selectedLevel = level
                    } label: {
                        Text(levelTitle(for: level))
                            .font(StudioTypography.label)
                            .frame(minWidth: 72)
                    }
                    .buttonStyle(ActionButtonStyle(kind: level == selectedLevel ? .filled(levelAccent(for: level)) : .outlined(levelAccent(for: level))))
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func reviewBasket(
        _ decision: AliasVocabulary.Decision,
        isExpanded: Binding<Bool>
    ) -> some View {
        let isApproved = decision == .approved
        let accent = isApproved ? StudioTheme.teal : StudioTheme.coral
        let count = isApproved ? selectedStatistics.approved : selectedStatistics.discarded
        let words = isApproved ? approvedWords : discardedWords
        let basketPage = isApproved ? approvedPage : discardedPage
        let key = isApproved ? "alias.preview.approved" : "alias.preview.discarded"
        let fallback = isApproved ? "%d approved" : "%d discarded"

        return AliasReviewBasket(
            title: guessWhoLocalizedFormat(key, fallback: fallback, count),
            emptyMessage: copy("alias.preview.basket.empty", fallback: "No words here yet."),
            moveLabel: copy(
                isApproved ? "alias.preview.move_to_discarded" : "alias.preview.move_to_approved",
                fallback: isApproved ? "Move to discarded" : "Move to approved"
            ),
            returnLabel: copy("alias.preview.return_to_review", fallback: "Return to review"),
            previousLabel: copy("alias.preview.previous", fallback: "Previous"),
            nextLabel: copy("alias.preview.next", fallback: "Next"),
            decision: decision,
            accent: accent,
            words: words,
            page: basketPage,
            pageCount: max(1, (count + basketPageSize - 1) / basketPageSize),
            isExpanded: isExpanded,
            onPrevious: { changeBasketPage(for: decision, by: -1) },
            onNext: { changeBasketPage(for: decision, by: 1) },
            onMove: { move($0, from: decision) },
            onReturn: returnToReview
        )
    }

    private var wordGrid: some View {
        Group {
            if pageWords.isEmpty && isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 96)
            } else if pageWords.isEmpty {
                Text(copy("alias.preview.review_complete", fallback: "All words in this level have been reviewed."))
                    .font(StudioTypography.body)
                    .foregroundStyle(StudioTheme.muted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 96)
                    .padding(.horizontal, 20)
                    .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(pageWords) { word in
                        AliasReviewWordCard(
                            word: word,
                            revealLabel: copy("alias.preview.reveal", fallback: "Tap to reveal"),
                            hideLabel: copy("alias.preview.hide", fallback: "Tap to hide"),
                            hiddenLabel: copy("alias.preview.hidden", fallback: "Hidden word"),
                            approveLabel: copy("alias.preview.approve", fallback: "Approve"),
                            discardLabel: copy("alias.preview.discard", fallback: "Discard"),
                            onToggleReveal: { toggleReveal(word) },
                            onReview: { review(word, as: $0) }
                        )
                    }
                }
            }
        }
    }

    private func copy(_ key: String, fallback: String) -> String {
        guessWhoLocalized(key, fallback: fallback)
    }

    private var loadRequest: AliasVocabularyReviewLoader.Request {
        AliasVocabularyReviewLoader.Request(
            level: selectedLevel,
            approvedPage: approvedPage,
            discardedPage: discardedPage,
            pageSize: pageSize,
            basketPageSize: basketPageSize,
            shuffleSeed: shuffleSeed,
            includeAdjectives: includeAdjectives
        )
    }

    private func loadPage(applying change: AliasVocabularyReviewLoader.Change? = nil) {
        let id = UUID()
        let request = loadRequest
        loadID = id
        isLoading = true
        AliasVocabularyReviewLoader.load(request, applying: change) { snapshot in
            // A previous page/filter or an older save must never replace newer UI state.
            guard loadID == id, loadRequest == request else { return }
            statisticsByLevel = snapshot.statistics
            approvedPage = snapshot.approvedPage
            discardedPage = snapshot.discardedPage
            pageWords = snapshot.words
            approvedWords = snapshot.approvedWords
            discardedWords = snapshot.discardedWords
            isLoading = false
            if let presentedWord,
               snapshot.words.contains(where: { $0.id == presentedWord.id && !$0.isRevealed }) {
                self.presentedWord = nil
            }
        }
    }

    private func clearWords() {
        isLoading = true
        pageWords = []
        approvedWords = []
        discardedWords = []
    }

    private func toggleReveal(_ word: AliasVocabulary.Word) {
        let isRevealed = !word.isRevealed
        let updatedWord = AliasVocabulary.Word(
            id: word.id,
            text: word.text,
            isRevealed: isRevealed,
            decision: word.decision
        )
        replace(word, with: updatedWord)
        if isRevealed {
            presentedWord = updatedWord
        }
        loadPage(applying: .reveal(word.id, isRevealed))
    }

    private func review(_ word: AliasVocabulary.Word, as decision: AliasVocabulary.Decision) {
        guard word.isRevealed, pageWords.contains(where: { $0.id == word.id }) else { return }
        pageWords.removeAll { $0.id == word.id }
        loadPage(applying: .review(word.id, decision))
    }

    private func replace(_ oldWord: AliasVocabulary.Word, with newWord: AliasVocabulary.Word) {
        guard let index = pageWords.firstIndex(where: { $0.id == oldWord.id }) else { return }
        pageWords[index] = newWord
    }

    private func changeBasketPage(for decision: AliasVocabulary.Decision, by offset: Int) {
        if decision == .approved {
            approvedPage += offset
        } else {
            discardedPage += offset
        }
    }

    private func move(_ word: AliasVocabulary.Word, from decision: AliasVocabulary.Decision) {
        let newDecision: AliasVocabulary.Decision = decision == .approved ? .discarded : .approved
        loadPage(applying: .review(word.id, newDecision))
    }

    private func returnToReview(_ word: AliasVocabulary.Word) {
        loadPage(applying: .returnToReview(word.id))
    }

    private func levelTitle(for level: AliasVocabulary.DifficultyLevel) -> String {
        switch level {
        case .easy:
            return copy("alias.preview.level.easy", fallback: "Easy")
        case .medium:
            return copy("alias.preview.level.medium", fallback: "Medium")
        case .hard:
            return copy("alias.preview.level.hard", fallback: "Hard")
        case .expert:
            return copy("alias.preview.level.expert", fallback: "Expert")
        }
    }

    private func levelAccent(for level: AliasVocabulary.DifficultyLevel) -> Color {
        switch level {
        case .easy:
            return StudioTheme.teal
        case .medium:
            return StudioTheme.gold
        case .hard:
            return StudioTheme.coral
        case .expert:
            return StudioTheme.inkSoft
        }
    }
}

private struct AliasWordReviewModal: View {
    let word: AliasVocabulary.Word
    let approveLabel: String
    let discardLabel: String
    let hint: String
    let closeLabel: String
    let onReview: (AliasVocabulary.Decision) -> Void
    let onClose: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var didReview = false

    private var dragAccent: Color {
        if dragOffset < 0 {
            return StudioTheme.teal
        }
        if dragOffset > 0 {
            return StudioTheme.coral
        }
        return StudioTheme.gold
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.24)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(StudioTheme.muted)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(closeLabel)
                }

                Label(approveLabel, systemImage: "arrow.up.circle.fill")
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(StudioTheme.teal)

                Text(word.text)
                    .font(StudioTypography.displaySmall)
                    .foregroundStyle(StudioTheme.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.55)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, minHeight: 112)
                    .padding(.horizontal, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(dragAccent.opacity(0.12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(dragAccent.opacity(0.75), lineWidth: 2)
                            }
                            .transaction { transaction in
                                // Direction feedback should not inherit the spring-back animation.
                                transaction.animation = nil
                                transaction.disablesAnimations = true
                            }
                    }
                    .offset(y: dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset / 35)))
                    .highPriorityGesture(reviewGesture)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityHint(hint)
                    .accessibilityAction(named: Text(approveLabel)) {
                        submitReview(.approved)
                    }
                    .accessibilityAction(named: Text(discardLabel)) {
                        submitReview(.discarded)
                    }

                Label(discardLabel, systemImage: "arrow.down.circle.fill")
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(StudioTheme.coral)

                Text(hint)
                    .font(StudioTypography.footnote)
                    .foregroundStyle(StudioTheme.muted)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(StudioTheme.card)
                    .shadow(color: StudioTheme.shadowStrong, radius: 24, y: 12)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(StudioTheme.line.opacity(0.8))
            }
            .padding(.horizontal, 20)
        }
    }

    private func submitReview(_ decision: AliasVocabulary.Decision) {
        guard !didReview else { return }
        didReview = true
        onReview(decision)
    }

    private var reviewGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                guard !didReview, abs(value.translation.height) > abs(value.translation.width) else { return }
                var transaction = Transaction(animation: nil)
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    dragOffset = value.translation.height
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let isVertical = abs(translation) > abs(value.translation.width)
                if isVertical, translation <= -56 {
                    submitReview(.approved)
                } else if isVertical, translation >= 56 {
                    submitReview(.discarded)
                } else {
                    withAnimation(.snappy) {
                        dragOffset = 0
                    }
                }
            }
    }
}

private struct AliasReviewBasket: View {
    let title: String
    let emptyMessage: String
    let moveLabel: String
    let returnLabel: String
    let previousLabel: String
    let nextLabel: String
    let decision: AliasVocabulary.Decision
    let accent: Color
    let words: [AliasVocabulary.Word]
    let page: Int
    let pageCount: Int
    @Binding var isExpanded: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onMove: (AliasVocabulary.Word) -> Void
    let onReturn: (AliasVocabulary.Word) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.snappy) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: decision == .approved ? "tray.and.arrow.down.fill" : "trash.fill")
                    Text(title)
                        .font(StudioTypography.compactLabel)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .foregroundStyle(accent)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: 46)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .overlay(accent.opacity(0.3))

                if words.isEmpty {
                    Text(emptyMessage)
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(words) { word in
                            reviewedWordRow(word)
                            if word.id != words.last?.id {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }

                    if pageCount > 1 {
                        Divider()
                        HStack(spacing: 16) {
                            Button(action: onPrevious) {
                                Label(previousLabel, systemImage: "chevron.left")
                                    .labelStyle(.iconOnly)
                            }
                            .disabled(page == 0)

                            Text("\(page + 1) / \(pageCount)")
                                .font(StudioTypography.footnote)
                                .foregroundStyle(StudioTheme.muted)

                            Button(action: onNext) {
                                Label(nextLabel, systemImage: "chevron.right")
                                    .labelStyle(.iconOnly)
                            }
                            .disabled(page + 1 >= pageCount)
                        }
                        .foregroundStyle(accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
        .background(accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accent.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5]))
        }
    }

    private func reviewedWordRow(_ word: AliasVocabulary.Word) -> some View {
        HStack(spacing: 12) {
            Text(word.text)
                .font(StudioTypography.subheadline)
                .foregroundStyle(StudioTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                onMove(word)
            } label: {
                Image(systemName: decision == .approved ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(decision == .approved ? StudioTheme.coral : StudioTheme.teal)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(moveLabel)

            Button {
                onReturn(word)
            } label: {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.title3)
                    .foregroundStyle(StudioTheme.gold)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(returnLabel)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 48)
    }
}

private struct AliasReviewWordCard: View {
    let word: AliasVocabulary.Word
    let revealLabel: String
    let hideLabel: String
    let hiddenLabel: String
    let approveLabel: String
    let discardLabel: String
    let onToggleReveal: () -> Void
    let onReview: (AliasVocabulary.Decision) -> Void

    @State private var dragOffset: CGFloat = 0

    private var decisionColor: Color {
        switch word.decision {
        case .approved:
            return StudioTheme.teal
        case .discarded:
            return StudioTheme.coral
        case nil:
            return StudioTheme.line
        }
    }

    var body: some View {
        VStack(spacing: 7) {
            if word.isRevealed {
                Text(word.text)
                    .font(StudioTypography.subheadline)
                    .foregroundStyle(StudioTheme.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                if let decision = word.decision {
                    Image(systemName: decision == .approved ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(decisionColor)
                } else {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.caption)
                        .foregroundStyle(StudioTheme.muted)
                }
            } else {
                Image(systemName: "questionmark")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(StudioTheme.gold)
                Text(revealLabel)
                    .font(StudioTypography.footnote)
                    .foregroundStyle(StudioTheme.muted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 82)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
        .background(decisionColor.opacity(word.decision == nil ? 0.04 : 0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(decisionColor.opacity(word.decision == nil ? 0.65 : 0.9))
        }
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture(perform: onToggleReveal)
        .offset(y: dragOffset)
        .opacity(Double(1 - min(abs(dragOffset) / CGFloat(240), CGFloat(0.35))))
        .simultaneousGesture(reviewGesture)
        .animation(.snappy, value: word)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(word.isRevealed ? word.text : hiddenLabel)
        .accessibilityHint(word.isRevealed ? "\(hideLabel). \(approveLabel), \(discardLabel)" : revealLabel)
        .accessibilityAction {
            onToggleReveal()
        }
        .accessibilityAction(named: Text(approveLabel)) {
            if word.isRevealed { onReview(.approved) }
        }
        .accessibilityAction(named: Text(discardLabel)) {
            if word.isRevealed { onReview(.discarded) }
        }
    }

    private var reviewGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard word.isRevealed, abs(value.translation.height) > abs(value.translation.width) else { return }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                guard word.isRevealed else { return }
                let translation = value.translation.height
                let isVertical = abs(translation) > abs(value.translation.width)
                if isVertical, translation <= -36 {
                    onReview(.approved)
                } else if isVertical, translation >= 36 {
                    onReview(.discarded)
                }
                withAnimation(.snappy) {
                    dragOffset = 0
                }
            }
    }
}
