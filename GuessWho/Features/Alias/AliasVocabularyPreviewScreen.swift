import SwiftUI

/// Read-only inspection screen while Alias rules are still being designed.
struct AliasVocabularyPreviewScreen: View {
    @EnvironmentObject private var gameState: GameState
    @State private var selectedLevel: AliasVocabulary.DifficultyLevel = .easy
    @State private var page = 0
    @State private var pageWords: [String] = []
    @State private var selectedLevelWordCount = 0
    @State private var totalWordCount = 0

    private let pageSize = 24
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    private var pageCount: Int {
        max(1, (selectedLevelWordCount + pageSize - 1) / pageSize)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                levelTabs
                wordGrid
                controls
            }
            .padding(.horizontal, 20)
            .padding(.top, 72)
            .padding(.bottom, 28)
        }
        .task { loadPage() }
        .onChange(of: page) { _, _ in loadPage() }
        .onChange(of: selectedLevel) { _, _ in
            if page == 0 {
                loadPage()
            } else {
                page = 0
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(copy("home.games", fallback: "Games"), action: gameState.showGamePicker)
                    .buttonStyle(ActionButtonStyle(kind: .ghost))
                Spacer()
                Image(systemName: "text.bubble.fill")
                    .foregroundStyle(StudioTheme.gold)
            }

            Text(copy("alias.preview.title", fallback: "Ukrainian word deck"))
                .font(StudioTypography.displaySmall)
                .foregroundStyle(StudioTheme.ink)
            Text(copy("alias.preview.message", fallback: "Read-only preview of the complete Alias vocabulary."))
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.muted)
            HStack(spacing: 10) {
                Text(levelTitle(for: selectedLevel))
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(levelAccent(for: selectedLevel), in: Capsule())

                Text(guessWhoLocalizedFormat("alias.preview.level_count", fallback: "%d words in this tab", selectedLevelWordCount))
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(StudioTheme.gold)
            }

            Text(guessWhoLocalizedFormat("alias.preview.total", fallback: "%d words total", totalWordCount))
                .font(StudioTypography.footnote)
                .foregroundStyle(StudioTheme.muted)
        }
        .padding(24)
        .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(StudioTheme.line.opacity(0.8))
        }
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

    private var wordGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(pageWords, id: \.self) { word in
                Text(word)
                    .font(StudioTypography.subheadline)
                    .foregroundStyle(StudioTheme.ink)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(StudioTheme.line.opacity(0.65))
                    }
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button(copy("alias.preview.previous", fallback: "Previous")) {
                page -= 1
            }
            .buttonStyle(ActionButtonStyle(kind: .outlined(StudioTheme.teal)))
            .disabled(page == 0)

            Text(guessWhoLocalizedFormat("alias.preview.page", fallback: "Page %d of %d", page + 1, pageCount))
                .font(StudioTypography.compactLabel)
                .foregroundStyle(StudioTheme.muted)
                .frame(maxWidth: .infinity)

            Button(copy("alias.preview.next", fallback: "Next")) {
                page += 1
            }
            .buttonStyle(ActionButtonStyle(kind: .filled(StudioTheme.coral)))
            .disabled(page + 1 == pageCount)
        }
        .animation(.snappy, value: page)
    }

    private func copy(_ key: String, fallback: String) -> String {
        guessWhoLocalized(key, fallback: fallback)
    }

    private func loadPage() {
        totalWordCount = AliasVocabulary.wordCount()
        selectedLevelWordCount = AliasVocabulary.wordCount(in: selectedLevel)
        pageWords = AliasVocabulary.words(in: selectedLevel, page: page, pageSize: pageSize)
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
