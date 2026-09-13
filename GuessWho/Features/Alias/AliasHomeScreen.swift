import SwiftUI

/// Entry menu and match setup for the Alias feature.
struct AliasHomeScreen: View {
    @EnvironmentObject private var gameState: GameState
    @EnvironmentObject private var aliasGameState: AliasGameState
    @AppStorage(AliasGameState.targetScoreKey) private var targetScore = AliasGameState.defaultTargetScore
    @AppStorage(AliasGameState.turnDurationKey) private var turnDuration = AliasGameState.defaultTurnDuration
    @AppStorage(AliasGameState.easyWordsKey) private var includesEasyWords = true
    @AppStorage(AliasGameState.mediumWordsKey) private var includesMediumWords = true
    @AppStorage(AliasGameState.hardWordsKey) private var includesHardWords = true
    @AppStorage(AliasGameState.expertWordsKey) private var includesExpertWords = false
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
            if !AliasGameState.turnDurationOptions.contains(turnDuration) {
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
            turnDurationPicker
            difficultyPicker
            adjectivesPicker

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

    private var turnDurationPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(copy("alias.menu.time", fallback: "Turn time"))
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.ink)

            HStack(spacing: 8) {
                ForEach(AliasGameState.turnDurationOptions, id: \.self) { option in
                    setupOptionButton(
                        title: copy("alias.menu.time.option", fallback: "%d sec", option),
                        accessibilityLabel: copy("alias.menu.time.accessibility", fallback: "%d seconds", option),
                        isSelected: turnDuration == option
                    ) {
                        turnDuration = option
                    }
                }
            }
        }
    }

    private var difficultyPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(copy("alias.menu.groups", fallback: "Word groups"))
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.ink)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
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

            Text(copy("alias.menu.groups.message", fallback: "Choose one or more difficulty groups."))
                .font(StudioTypography.footnote)
                .foregroundStyle(StudioTheme.muted)
        }
    }

    private var adjectivesPicker: some View {
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
    }

    private func setupOptionButton(
        title: String,
        accessibilityLabel: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(title, action: action)
            .font(StudioTypography.label)
            .foregroundStyle(isSelected ? Color.white : StudioTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                isSelected ? StudioTheme.teal : Color.white.opacity(0.72),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var selectedDifficultyLevels: Set<AliasVocabulary.DifficultyLevel> {
        var levels: Set<AliasVocabulary.DifficultyLevel> = []
        if includesEasyWords { levels.insert(.easy) }
        if includesMediumWords { levels.insert(.medium) }
        if includesHardWords { levels.insert(.hard) }
        if includesExpertWords { levels.insert(.expert) }
        return levels
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
        case .easy: return copy("alias.preview.level.easy", fallback: "Easy")
        case .medium: return copy("alias.preview.level.medium", fallback: "Medium")
        case .hard: return copy("alias.preview.level.hard", fallback: "Hard")
        case .expert: return copy("alias.preview.level.expert", fallback: "Expert")
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
            targetScore: targetScore,
            turnDuration: turnDuration,
            difficultyLevels: selectedDifficultyLevels,
            includeAdjectives: includeAdjectives
        )
        gameState.showAliasGame()
    }

    private func copy(_ key: String, fallback: String) -> String {
        guessWhoLocalized(key, fallback: fallback)
    }

    private func copy(_ key: String, fallback: String, _ value: Int) -> String {
        guessWhoLocalizedFormat(key, fallback: fallback, value)
    }
}
