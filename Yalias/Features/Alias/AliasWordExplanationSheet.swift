import SwiftUI

struct AliasWordExplanationSheet: View {
    let word: String
    @Environment(\.dismiss) private var dismiss
    @State private var state: LoadState = .loading
    @State private var attempt = 0

    private enum LoadState {
        case loading
        case loaded(String)
        case failed(String)
    }

    var body: some View {
        expandedContent
        .background(StudioTheme.card)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task(id: attempt) { await load() }
    }

    private var expandedContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text(copy("alias.explanation.title"))
                        .font(StudioTypography.subheadline)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(copy("alias.vocabulary_review.close"))
                }

                Text(word)
                    .font(StudioTypography.displaySmall)
                    .textSelection(.enabled)

                switch state {
                case .loading:
                    ProgressView(copy("alias.explanation.loading"))
                        .tint(StudioTheme.teal)
                        .frame(maxWidth: .infinity, minHeight: 120)
                case .loaded(let explanation):
                    Text(explanation)
                        .font(StudioTypography.body)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                case .failed(let key):
                    Text(copy(key))
                        .font(StudioTypography.body)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(copy("alias.explanation.retry")) {
                        state = .loading
                        attempt += 1
                    }
                    .buttonStyle(ActionButtonStyle(kind: .outlined(StudioTheme.teal)))
                }

                Text(copy("alias.explanation.note"))
                    .font(StudioTypography.footnote)
                    .foregroundStyle(StudioTheme.muted)
            }
            .foregroundStyle(StudioTheme.ink)
            .padding(24)
        }
    }

    @MainActor
    private func load() async {
        do {
            let explanation = try await AliasWordExplanationService().explanation(for: word)
            try Task.checkCancellation()
            state = .loaded(explanation)
        } catch is CancellationError {
            // Dismissing the sheet cancels its request.
        } catch {
            guard !Task.isCancelled else { return }
            if let lookupError = error as? AliasWordExplanationService.LookupError {
                state = .failed(lookupError.localizationKey)
            } else if error is URLError {
                state = .failed("alias.explanation.network_error")
            } else {
                state = .failed("alias.explanation.unavailable")
            }
        }
    }

    private func copy(_ key: String) -> String {
        AliasLocalizationCatalog.stringsByKey[key]?.localized() ?? key
    }
}
