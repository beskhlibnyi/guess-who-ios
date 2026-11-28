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
            AliasHomeBackgroundView()

            VStack(spacing: 12) {
                header
                Color.clear.frame(height: 32)
                settings
                primaryControls
                Spacer(minLength: 0)
                bottomControls
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 4)

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
        .onAppear(perform: repairPersistedSetup)
    }

    private var header: some View {
        Image("YaliasLogo")
            .resizable()
            .scaledToFit()
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .accessibilityLabel(copy("app.title", fallback: "YALIAS"))
    }

    private var settings: some View {
        PaperPanel(padding: 14, cornerRadius: 20) {
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
                    withAnimation(.snappy(duration: 0.22)) {
                        gameModeRawValue = mode.rawValue
                    }
                } label: {
                    Text(modeName(mode))
                        .font(StudioTypography.paperControl)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(modeForegroundColor(mode, isSelected: isSelected))
                        .background(isSelected ? modeSelectionColor(mode) : Color.clear, in: Capsule())
                        .shadow(
                            color: isSelected ? StudioTheme.paperInk.opacity(0.09) : .clear,
                            radius: 2,
                            x: 0,
                            y: 2
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(StudioTheme.paperHighlight, in: Capsule())
        .overlay { Capsule().stroke(StudioTheme.paperInk, lineWidth: 1.8) }
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
                        .font(StudioTypography.footnote.weight(.semibold))
                        .foregroundStyle(StudioTheme.paperInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            isSelected
                                ? difficultyGradientSegment(for: level)
                                : AnyShapeStyle(StudioTheme.paperHighlight),
                            in: RoundedRectangle(cornerRadius: 13, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(StudioTheme.paperInk, lineWidth: 1.5)
                        }
                        .shadow(
                            color: isSelected ? StudioTheme.paperInk.opacity(0.11) : .clear,
                            radius: 3,
                            x: 0,
                            y: 2
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
        Button {
            withAnimation(.snappy(duration: 0.22)) {
                includeAdjectives.toggle()
            }
        } label: {
            HStack(spacing: 16) {
                Text(copy("alias.filter.adjectives", fallback: "Include adjectives"))
                    .font(StudioTypography.subheadline.weight(.semibold))
                    .foregroundStyle(StudioTheme.paperInk)
                    .lineLimit(2)

                Spacer()

                AliasPaperToggle(isOn: includeAdjectives)
            }
            .padding(.horizontal, 4)
            .frame(minHeight: 56)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(includeAdjectives ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: includeAdjectives)
    }

    private var primaryControls: some View {
        VStack(spacing: 10) {
            Button(action: primaryAction) {
                Text(
                    aliasGameState.canResume
                        ? copy("alias.menu.resume", fallback: "Resume Match")
                        : copy("alias.menu.start_game", fallback: "Start game")
                )
            }
            .buttonStyle(AliasHomePrimaryButtonStyle())

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

    private var bottomControls: some View {
        HStack(spacing: 18) {
            bottomIconButton(
                title: copy("alias.vocabulary_review.title", fallback: "Review words"),
                systemImage: "book.closed.fill",
                action: navigationState.showReview
            )

            bottomIconButton(
                title: copy("settings.open", fallback: "Open settings"),
                systemImage: "gearshape.fill"
            ) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    showsSettings = true
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func bottomIconButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(StudioTheme.paperInk)
                .frame(width: 48, height: 48)
                .background(StudioTheme.paper, in: Circle())
                .overlay { Circle().stroke(StudioTheme.paperInk.opacity(0.18), lineWidth: 1.5) }
                .shadow(color: StudioTheme.paperInk.opacity(0.14), radius: 4, x: 1, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
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
        case .fastest: copy("alias.menu.mode.fastest", fallback: "Fast")
        }
    }

    private func modeSelectionColor(_ mode: AliasGameState.GameMode) -> Color {
        switch mode {
        case .classic: StudioTheme.mustard
        case .fastest: StudioTheme.vermilion
        }
    }

    private func modeForegroundColor(
        _ mode: AliasGameState.GameMode,
        isSelected: Bool
    ) -> Color {
        guard isSelected else { return StudioTheme.paperInk }
        return mode == .fastest ? StudioTheme.paperHighlight : StudioTheme.paperInk
    }

    private func difficultyGradientSegment(
        for level: AliasVocabulary.DifficultyLevel
    ) -> AnyShapeStyle {
        let levels = AliasVocabulary.DifficultyLevel.allCases
        let index = levels.firstIndex(of: level) ?? 0
        let segmentCount = Double(max(levels.count, 1))
        let start = Double(index) / segmentCount
        let end = Double(index + 1) / segmentCount

        return AnyShapeStyle(
            LinearGradient(
                colors: [
                    StudioTheme.accentGradientColor(at: start),
                    StudioTheme.accentGradientColor(at: end)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
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
                accessibilityValue: valueLabel(selection),
                fillStyle: AnyShapeStyle(
                    LinearGradient(
                        colors: [StudioTheme.mustard, StudioTheme.vermilion],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                ),
                thumbColor: StudioTheme.accentGradientColor(at: sliderProgress)
            )
            .accessibilityLabel(title)
        }
    }

    private var sliderProgress: Double {
        let span = max(range.upperBound - range.lowerBound, 1)
        return Double(selection - range.lowerBound) / Double(span)
    }
}

private struct AliasPaperToggle: View {
    let isOn: Bool

    var body: some View {
        ZStack {
            Capsule()
                .fill(isOn ? StudioTheme.olive : StudioTheme.paperHighlight)

            Capsule()
                .stroke(StudioTheme.paperInk.opacity(isOn ? 0.18 : 0.55), lineWidth: 1.5)

            Circle()
                .fill(StudioTheme.paperHighlight)
                .overlay {
                    Circle().stroke(StudioTheme.paperInk.opacity(0.16), lineWidth: 1)
                }
                .shadow(color: StudioTheme.paperInk.opacity(0.16), radius: 2, x: 0, y: 2)
                .padding(4)
                .frame(maxWidth: .infinity, alignment: isOn ? .trailing : .leading)
        }
        .frame(width: 68, height: 40)
        .accessibilityHidden(true)
    }
}

private struct AliasHomePrimaryButtonStyle: ButtonStyle {
    private let cornerRadius: CGFloat = 15

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StudioTypography.paperButton)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, minHeight: 64)
            .foregroundStyle(StudioTheme.paperHighlight)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(StudioTheme.vermilion.opacity(configuration.isPressed ? 0.86 : 1))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(StudioTheme.paperInk, lineWidth: 1.8)
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .shadow(
                color: StudioTheme.paperInk.opacity(configuration.isPressed ? 0.10 : 0.16),
                radius: configuration.isPressed ? 3 : 6,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
    }
}

private struct AliasHomeBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                StudioTheme.homeCanvas

                PaperGrain()
                    .stroke(StudioTheme.paperInk.opacity(0.012), lineWidth: 0.45)

                ribbon(kind: .mustard, color: StudioTheme.mustard)

                ribbon(kind: .vermilion, color: StudioTheme.vermilion)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func ribbon(kind: AliasHomeRibbonShape.Kind, color: Color) -> some View {
        AliasHomeRibbonShape(kind: kind)
            .fill(color)
            .overlay {
                Image("RibbonPaperTexture")
                    .resizable(resizingMode: .tile)
                    .brightness(-0.12)
                    .contrast(3.0)
                    .blendMode(.overlay)
                    .opacity(0.78)
                    .mask(AliasHomeRibbonShape(kind: kind))
            }
            .compositingGroup()
    }
}

private struct AliasHomeRibbonShape: Shape {
    enum Kind {
        case mustard
        case vermilion
    }

    let kind: Kind

    func path(in rect: CGRect) -> Path {
        let designWidth: CGFloat = 900
        let designHeight: CGFloat = 1_750

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + x / designWidth * rect.width,
                y: rect.minY + y / designHeight * rect.height
            )
        }

        var path = Path()

        switch kind {
        case .mustard:
            path.move(to: point(205, -55))
            path.addCurve(
                to: point(55, 1_800),
                control1: point(-75, 240),
                control2: point(-95, 1_100)
            )
            path.addLine(to: point(120, 1_800))
            path.addCurve(
                to: point(245, -20),
                control1: point(-70, 1_100),
                control2: point(-35, 260)
            )

        case .vermilion:
            path.move(to: point(950, 158))
            path.addCurve(
                to: point(497, 1_800),
                control1: point(760, 405),
                control2: point(625, 920)
            )
            path.addLine(to: point(538, 1_800))
            path.addCurve(
                to: point(982, 194),
                control1: point(720, 920),
                control2: point(823, 452)
            )
        }

        path.closeSubpath()
        return path
    }
}
