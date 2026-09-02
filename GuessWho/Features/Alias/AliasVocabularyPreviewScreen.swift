import SwiftUI

/// Read-only inspection screen while Alias rules are still being designed.
struct AliasVocabularyPreviewScreen: View {
    @EnvironmentObject private var gameState: GameState
    @State private var page = 0
    @State private var pageWords: [String] = []
    @State private var totalWordCount = 0

    private let pageSize = 24
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    private var pageCount: Int {
        max(1, (totalWordCount + pageSize - 1) / pageSize)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                wordGrid
                controls
            }
            .padding(.horizontal, 20)
            .padding(.top, 72)
            .padding(.bottom, 28)
        }
        .task { loadPage() }
        .onChange(of: page) { _, _ in loadPage() }
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
            Text(guessWhoLocalizedFormat("alias.preview.total", fallback: "%d words", totalWordCount))
                .font(StudioTypography.compactLabel)
                .foregroundStyle(StudioTheme.gold)
        }
        .padding(24)
        .background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(StudioTheme.line.opacity(0.8))
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
        pageWords = AliasVocabulary.words(page: page, pageSize: pageSize)
    }
}
