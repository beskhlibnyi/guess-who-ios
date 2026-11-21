import SwiftUI

/// Entry menu and match setup for the Alias feature.
struct AliasHomeScreen: View {
    @EnvironmentObject private var navigationState: AliasNavigationState
    @EnvironmentObject private var aliasGameState: AliasGameState
    @AppStorage(aliasLanguageOverrideKey) private var languageOverride = ""
    @AppStorage(aliasPlayerOneNameKey) private var playerOneName = ""
    @AppStorage(aliasPlayerTwoNameKey) private var playerTwoName = ""
    @AppStorage(AliasGameState.gameModeKey) private var gameModeRawValue = AliasGameState.GameMode.classic.rawValue
    @AppStorage(AliasGameState.targetScoreKey) private var targetScore = AliasGameState.defaultTargetScore
    @AppStorage(AliasGameState.turnDurationKey) private var turnDuration = AliasGameState.defaultTurnDuration
    @AppStorage(AliasGameState.easyWordsKey) private var includesEasyWords = false
    @AppStorage(AliasGameState.mediumWordsKey) private var includesMediumWords = true
    @AppStorage(AliasGameState.hardWordsKey) private var includesHardWords = false
    @AppStorage(AliasGameState.expertWordsKey) private var includesExpertWords = false
    @AppStorage(AliasVocabulary.includeAdjectivesKey) private var includeAdjectives = true
    @State private var showsNewMatchConfirmation = false
    @State private var showsSettings = false

    var body: some View {
        ZStack {
            YaliasPaperBackgroundView()

            VStack(spacing: 12) {
                header
                settings
                actions
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 12)

            AliasSettingsDrawer(
                languageOverride: $languageOverride,
                playerOneName: $playerOneName,
                playerTwoName: $playerTwoName,
                isPresented: $showsSettings,
                showsRail: false
            )
        }
        .alert(copy("alias.menu.alert.title", fallback: "Start a new match?"), isPresented: $showsNewMatchConfirmation) {
            Button(copy("common.cancel", fallback: "Cancel"), role: .cancel) {}
            Button(copy("alias.menu.new_match", fallback: "New Match"), role: .destructive, action: startMatch)
        } message: {
            Text(copy("alias.menu.alert.message", fallback: "The current YALIAS match will be cleared."))
        }
        .onAppear(perform: repairPersistedSetup)
    }

    private var header: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 3) {
                HStack(spacing: -10) {
                    Image(systemName: "bubble.fill")
                        .foregroundStyle(StudioTheme.mustard)
                        .font(.system(size: 40, weight: .bold))
                        .rotationEffect(.degrees(-8))
                    Image(systemName: "bubble.fill")
                        .foregroundStyle(StudioTheme.vermilion)
                        .font(.system(size: 48, weight: .bold))
                        .rotationEffect(.degrees(7))
                }
                .frame(height: 40)

                AliasBrandTitle()
                    .foregroundStyle(StudioTheme.paperInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Capsule()
                    .fill(StudioTheme.mustard)
                    .frame(width: 166, height: 7)
                    .rotationEffect(.degrees(-2))
                    .offset(y: -7)

                Text(copy("alias.menu.tagline", fallback: "Pass. Explain. Guess."))
                    .font(StudioTypography.paperControl)
                    .foregroundStyle(StudioTheme.paperInk)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
                    .frame(minHeight: 48)
                    .background(TornPaperShape().fill(StudioTheme.paper))
                    .overlay(alignment: .bottom) {
                        Capsule()
                            .fill(StudioTheme.vermilion)
                            .frame(width: 176, height: 5)
                            .rotationEffect(.degrees(-2))
                            .offset(y: -8)
                    }
                    .shadow(color: StudioTheme.paperInk.opacity(0.12), radius: 5, x: 1, y: 4)
            }
            .frame(maxWidth: .infinity)

            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    showsSettings = true
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(StudioTheme.paperInk)
                    .frame(width: 46, height: 46)
                    .background(StudioTheme.paper, in: Circle())
                    .overlay { Circle().stroke(StudioTheme.paperInk.opacity(0.12)) }
                    .shadow(color: StudioTheme.paperInk.opacity(0.16), radius: 5, x: 1, y: 4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(copy("settings.open", fallback: "Open settings"))
        }
    }

    private var settings: some View {
        PaperPanel(padding: 14) {
            VStack(spacing: 10) {
                modePicker
                goalPicker

                if selectedGameMode == .classic {
                    turnDurationPicker
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                difficultyPicker
                adjectivesPicker
            }
            .animation(.snappy(duration: 0.25), value: selectedGameMode)
        }
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(AliasGameState.GameMode.allCases) { mode in
                let isSelected = selectedGameMode == mode
                Button {
                    gameModeRawValue = mode.rawValue
                } label: {
                    Text(modeName(mode))
                        .font(StudioTypography.paperControl)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundStyle(isSelected ? StudioTheme.paperHighlight : StudioTheme.paperInk)
                        .background(isSelected ? StudioTheme.olive : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(StudioTheme.paperHighlight, in: Capsule())
        .overlay { Capsule().stroke(StudioTheme.paperInk, lineWidth: 2.2) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(copy("alias.menu.mode", fallback: "Game mode"))
    }

    private var goalPicker: some View {
        AliasValueSlider(
            title: copy("alias.menu.goal", fallback: "Goal"),
            selection: $targetScore,
            range: AliasGameState.targetScoreRange,
            valueLabel: { copy("alias.menu.goal.option", fallback: "%d points", $0) }
        )
    }

    private var turnDurationPicker: some View {
        AliasValueSlider(
            title: copy("alias.menu.time", fallback: "Turn time"),
            selection: $turnDuration,
            range: AliasGameState.turnDurationRange,
            valueLabel: { copy("alias.menu.time.option", fallback: "%d sec", $0) }
        )
    }

    private var difficultyPicker: some View {
        HStack(spacing: 7) {
            ForEach(AliasVocabulary.DifficultyLevel.allCases, id: \.self) { level in
                let isSelected = selectedDifficultyLevels.contains(level)
                Button {
                    selectDifficulty(level)
                } label: {
                    Text(difficultyName(level))
                        .font(StudioTypography.compactLabel)
                        .foregroundStyle(StudioTheme.paperInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(difficultyColor(level).opacity(isSelected ? 1 : 0.27), in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(StudioTheme.paperHighlight, lineWidth: isSelected ? 4 : 0)
                                .padding(-2)
                        }
                        .shadow(
                            color: isSelected ? StudioTheme.paperInk.opacity(0.14) : .clear,
                            radius: 4,
                            x: 1,
                            y: 3
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(difficultyName(level))
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(copy("alias.menu.groups", fallback: "Word groups"))
    }

    private var adjectivesPicker: some View {
        Toggle(isOn: $includeAdjectives) {
            Text(copy("alias.filter.adjectives", fallback: "Include adjectives"))
                .font(StudioTypography.subheadline.weight(.semibold))
                .foregroundStyle(StudioTheme.paperInk)
                .lineLimit(2)
        }
        .tint(StudioTheme.olive)
        .padding(.horizontal, 16)
        .frame(minHeight: 56)
        .background(StudioTheme.paperHighlight.opacity(0.74), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .bottomLeading) {
            Capsule()
                .fill(StudioTheme.vermilion)
                .frame(width: 112, height: 4)
                .rotationEffect(.degrees(-2))
                .offset(x: 18, y: -8)
        }
        .shadow(color: StudioTheme.paperInk.opacity(0.08), radius: 4, x: 1, y: 3)
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button(action: primaryAction) {
                Text(
                    aliasGameState.canResume
                        ? copy("alias.menu.resume", fallback: "Resume Match")
                        : copy("alias.menu.start_game", fallback: "Start game")
                )
            }
            .buttonStyle(
                PaperActionButtonStyle(
                    kind: .filled(aliasGameState.canResume ? StudioTheme.olive : StudioTheme.vermilion)
                )
            )

            Button(action: navigationState.showReview) {
                Text(copy("alias.vocabulary_review.title", fallback: "Review words"))
            }
            .buttonStyle(PaperActionButtonStyle(kind: .outlined))

            if aliasGameState.canResume {
                Button(action: newMatchTapped) {
                    Label(copy("alias.menu.new_match", fallback: "New Match"), systemImage: "arrow.counterclockwise")
                        .font(StudioTypography.footnote.weight(.semibold))
                        .foregroundStyle(StudioTheme.paperInk)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var selectedDifficultyLevels: Set<AliasVocabulary.DifficultyLevel> {
        var levels: Set<AliasVocabulary.DifficultyLevel> = []
        if includesEasyWords { levels.insert(.easy) }
        if includesMediumWords { levels.insert(.medium) }
        if includesHardWords { levels.insert(.hard) }
        if includesExpertWords { levels.insert(.expert) }
        return levels
    }

    private var selectedGameMode: AliasGameState.GameMode {
        AliasGameState.GameMode(rawValue: gameModeRawValue) ?? .classic
    }

    private func modeName(_ mode: AliasGameState.GameMode) -> String {
        switch mode {
        case .classic: copy("alias.menu.mode.classic", fallback: "Classic")
        case .fastest: copy("alias.menu.mode.fastest", fallback: "Fastest")
        }
    }

    private func difficultyColor(_ level: AliasVocabulary.DifficultyLevel) -> Color {
        switch level {
        case .easy: StudioTheme.sky
        case .medium: StudioTheme.mustard
        case .hard: StudioTheme.vermilion
        case .expert: StudioTheme.sage
        }
    }

    private func selectDifficulty(_ level: AliasVocabulary.DifficultyLevel) {
        includesEasyWords = level == .easy
        includesMediumWords = level == .medium
        includesHardWords = level == .hard
        includesExpertWords = level == .expert
    }

    private func difficultyName(_ level: AliasVocabulary.DifficultyLevel) -> String {
        switch level {
        case .easy: copy("alias.vocabulary_review.level.easy", fallback: "Easy")
        case .medium: copy("alias.vocabulary_review.level.medium", fallback: "Medium")
        case .hard: copy("alias.vocabulary_review.level.hard", fallback: "Hard")
        case .expert: copy("alias.vocabulary_review.level.expert", fallback: "Expert")
        }
    }

    private func primaryAction() {
        if aliasGameState.canResume {
            aliasGameState.resumeMatch()
            navigationState.showGame()
        } else {
            startMatch()
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
        aliasGameState.startMatch(
            mode: selectedGameMode,
            targetScore: targetScore,
            turnDuration: turnDuration,
            difficultyLevels: selectedDifficultyLevels,
            includeAdjectives: includeAdjectives
        )
        navigationState.showGame()
    }

    private func repairPersistedSetup() {
        if AliasGameState.GameMode(rawValue: gameModeRawValue) == nil {
            gameModeRawValue = AliasGameState.GameMode.classic.rawValue
        }
        if !AliasGameState.targetScoreRange.contains(targetScore) {
            targetScore = AliasGameState.defaultTargetScore
        }
        if !AliasGameState.turnDurationRange.contains(turnDuration) {
            turnDuration = AliasGameState.defaultTurnDuration
        }
        if selectedDifficultyLevels.count != 1 {
            selectDifficulty(.medium)
        }
    }

    private func copy(_ key: String, fallback: String) -> String {
        aliasLocalized(key, fallback: fallback)
    }

    private func copy(_ key: String, fallback: String, _ value: Int) -> String {
        aliasLocalizedFormat(key, fallback: fallback, value)
    }
}

private struct AliasBrandTitle: View {
    private var accessibleTitle: String {
        aliasLocalized("app.title", fallback: "YALIAS")
    }

    @ViewBuilder
    var body: some View {
        if AliasLanguage.active == .ukrainian {
            Text(accessibleTitle)
                .font(StudioTypography.brandTitle)
        } else {
            HStack(alignment: .center, spacing: -3) {
                Text("УА")
                Text("Г")
                    .scaleEffect(x: 1, y: -1, anchor: .center)
                Text("ІАЗ")
            }
            .font(StudioTypography.brandTitle)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibleTitle)
        }
    }
}

private struct AliasValueSlider: View {
    let title: String
    @Binding var selection: Int
    let range: ClosedRange<Int>
    let valueLabel: (Int) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(title)
                    .font(StudioTypography.subheadline.weight(.semibold))
                    .foregroundStyle(StudioTheme.paperInk)

                Spacer()

                Text(valueLabel(selection))
                    .font(StudioTypography.subheadline.weight(.semibold))
                    .foregroundStyle(StudioTheme.paperInk)
                    .contentTransition(.numericText())
            }

            PaperSlider(
                value: $selection,
                range: range,
                accessibilityValue: valueLabel(selection)
            )
            .accessibilityLabel(title)
        }
    }
}
