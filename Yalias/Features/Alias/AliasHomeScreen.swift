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
    @AppStorage(AliasGameState.easyWordsKey) private var includesEasyWords = true
    @AppStorage(AliasGameState.mediumWordsKey) private var includesMediumWords = true
    @AppStorage(AliasGameState.hardWordsKey) private var includesHardWords = true
    @AppStorage(AliasGameState.expertWordsKey) private var includesExpertWords = false
    @AppStorage(AliasVocabulary.includeAdjectivesKey) private var includeAdjectives = true
    @State private var showsNewMatchConfirmation = false
    @State private var showsSettings = false

    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    settings
                    actions
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 36)
            }

            AliasSettingsDrawer(
                languageOverride: $languageOverride,
                playerOneName: $playerOneName,
                playerTwoName: $playerTwoName,
                isPresented: $showsSettings
            )
        }
        .alert(copy("alias.menu.alert.title", fallback: "Start a new match?"), isPresented: $showsNewMatchConfirmation) {
            Button(copy("common.cancel", fallback: "Cancel"), role: .cancel) {}
            Button(copy("alias.menu.new_match", fallback: "New Match"), role: .destructive, action: startMatch)
        } message: {
            Text(copy("alias.menu.alert.message", fallback: "The current YALIAS match will be cleared."))
        }
        .onAppear {
            if AliasGameState.GameMode(rawValue: gameModeRawValue) == nil {
                gameModeRawValue = AliasGameState.GameMode.classic.rawValue
            }
            if !AliasGameState.targetScoreRange.contains(targetScore) {
                targetScore = AliasGameState.defaultTargetScore
            }
            if !AliasGameState.turnDurationRange.contains(turnDuration) {
                turnDuration = AliasGameState.defaultTurnDuration
            }
            if selectedDifficultyLevels.isEmpty {
                includesEasyWords = true
                includesMediumWords = true
                includesHardWords = true
            }
        }
    }

    private var header: some View {
        HStack {
            AliasBrandTitle()
                .foregroundStyle(StudioTheme.ink)
            Spacer()
        }
    }

    private var settings: some View {
        settingsCard {
            modePicker

            Divider()
                .overlay(StudioTheme.line.opacity(0.6))

            goalPicker
            if selectedGameMode == .classic {
                turnDurationPicker
            }

            Divider()
                .overlay(StudioTheme.line.opacity(0.6))

            difficultyPicker

            Divider()
                .overlay(StudioTheme.line.opacity(0.6))

            adjectivesPicker
        }
    }

    private var actions: some View {
        VStack(spacing: 14) {
            if aliasGameState.canResume {
                Button {
                    aliasGameState.resumeMatch()
                    navigationState.showGame()
                } label: {
                    Text(copy("alias.menu.resume", fallback: "Resume Match"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.teal)))
            } else {
                Button(action: newMatchTapped) {
                    Text(copy("alias.menu.new_match", fallback: "New Match"))
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
            }

            HStack(spacing: 18) {
                if aliasGameState.canResume {
                    compactAction(
                        copy("alias.menu.new_match", fallback: "New Match"),
                        systemImage: "arrow.counterclockwise",
                        action: newMatchTapped
                    )
                }

                compactAction(
                    copy("alias.menu.review", fallback: "Review"),
                    systemImage: "text.book.closed",
                    action: navigationState.showReview
                )
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(copy("alias.menu.mode", fallback: "Game mode"))
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.ink)

            Picker(copy("alias.menu.mode", fallback: "Game mode"), selection: $gameModeRawValue) {
                ForEach(AliasGameState.GameMode.allCases) { mode in
                    Text(modeName(mode)).tag(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .tint(StudioTheme.ink)
        }
    }

    private var goalPicker: some View {
        AliasValueSlider(
            title: copy("alias.menu.goal", fallback: "Goal score"),
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
        VStack(alignment: .leading, spacing: 10) {
            Text(copy("alias.menu.groups", fallback: "Word groups"))
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.ink)

            HStack(spacing: 8) {
                ForEach(AliasVocabulary.DifficultyLevel.allCases, id: \.self) { level in
                    let isSelected = selectedDifficultyLevels.contains(level)
                    setupOptionButton(
                        title: difficultyName(level),
                        accessibilityLabel: difficultyName(level),
                        isSelected: isSelected
                    ) {
                        toggleDifficulty(level)
                    }
                    .disabled(isSelected && selectedDifficultyLevels.count == 1)
                }
            }

        }
    }

    private var adjectivesPicker: some View {
        Toggle(isOn: $includeAdjectives) {
            Text(copy("alias.filter.adjectives", fallback: "Include adjectives"))
                .font(StudioTypography.subheadline)
                .foregroundStyle(StudioTheme.ink)
        }
        .tint(StudioTheme.teal)
    }

    private func setupOptionButton(
        title: String,
        accessibilityLabel: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(title, action: action)
            .font(StudioTypography.compactLabel)
            .foregroundStyle(isSelected ? StudioTheme.teal : StudioTheme.muted)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 40)
            .background(
                isSelected ? StudioTheme.teal.opacity(0.13) : StudioTheme.softWash.opacity(0.7),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(isSelected ? StudioTheme.teal.opacity(0.3) : Color.clear)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 18, content: content)
            .padding(20)
            .background(StudioTheme.card.opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func compactAction(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(StudioTypography.footnote.weight(.semibold))
                .foregroundStyle(StudioTheme.inkSoft)
                .padding(.horizontal, 10)
                .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
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
        case .classic:
            return copy("alias.menu.mode.classic", fallback: "Classic")
        case .fastest:
            return copy("alias.menu.mode.fastest", fallback: "Fastest")
        }
    }

    private func toggleDifficulty(_ level: AliasVocabulary.DifficultyLevel) {
        switch level {
        case .easy: includesEasyWords.toggle()
        case .medium: includesMediumWords.toggle()
        case .hard: includesHardWords.toggle()
        case .expert: includesExpertWords.toggle()
        }
    }

    private func difficultyName(_ level: AliasVocabulary.DifficultyLevel) -> String {
        switch level {
        case .easy: return copy("alias.vocabulary_review.level.easy", fallback: "Easy")
        case .medium: return copy("alias.vocabulary_review.level.medium", fallback: "Medium")
        case .hard: return copy("alias.vocabulary_review.level.hard", fallback: "Hard")
        case .expert: return copy("alias.vocabulary_review.level.expert", fallback: "Expert")
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(title)
                    .font(StudioTypography.subheadline)
                    .foregroundStyle(StudioTheme.ink)

                Spacer()

                Text(valueLabel(selection))
                    .font(StudioTypography.footnote.weight(.semibold))
                    .foregroundStyle(StudioTheme.teal)
                    .contentTransition(.numericText())
            }

            Slider(
                value: Binding(
                    get: { Double(selection) },
                    set: { selection = Int($0.rounded()) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 1
            )
            .tint(StudioTheme.teal)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}
