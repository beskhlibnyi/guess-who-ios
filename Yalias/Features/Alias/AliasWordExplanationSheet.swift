import SwiftUI

struct AliasWordExplanationSheet: View {
    let word: String
    @Environment(\.dismiss) private var dismiss
    @State private var state: LoadState = .loading
    @State private var attempt = 0
    @State private var graceSecondsRemaining: Int?

    private enum LoadState {
        case loading
        case loaded(String)
        case failed(String)
    }

    var body: some View {
        ZStack {
            YaliasPaperBackgroundView()

            VStack(spacing: 16) {
                sheetHeader
                wordCard
                explanationCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(StudioTheme.paperCanvas)
        .interactiveDismissDisabled(graceSecondsRemaining != nil)
        .task(id: attempt) { await load() }
    }

    private var sheetHeader: some View {
        HStack(spacing: 12) {
            Text(copy("alias.explanation.title"))
                .font(StudioTypography.paperTitle)
                .foregroundStyle(StudioTheme.paperInk)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(StudioTheme.paperInk)
                    .frame(width: 44, height: 44)
                    .background(StudioTheme.paperHighlight, in: Circle())
                    .overlay {
                        Circle().stroke(StudioTheme.paperInk, lineWidth: 1.8)
                    }
            }
            .buttonStyle(.plain)
            .disabled(graceSecondsRemaining != nil)
            .opacity(graceSecondsRemaining == nil ? 1 : 0.35)
            .accessibilityLabel(copy("alias.vocabulary_review.close"))
        }
    }

    private var wordCard: some View {
        Text(word.uppercased())
            .font(StudioTypography.paperDisplay)
            .foregroundStyle(StudioTheme.paperInk)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.center)
            .textSelection(.enabled)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, minHeight: 112)
            .background(TornPaperShape().fill(StudioTheme.mustard))
            .overlay {
                TornPaperShape()
                    .stroke(StudioTheme.paperInk, lineWidth: 1.8)
            }
            .shadow(color: StudioTheme.paperInk.opacity(0.12), radius: 5, x: 1, y: 4)
    }

    private var explanationCard: some View {
        VStack(spacing: 14) {
            Group {
                switch state {
                case .loading:
                    VStack(spacing: 14) {
                        ProgressView()
                            .tint(StudioTheme.olive)
                            .controlSize(.large)
                        Text(copy("alias.explanation.loading"))
                            .font(StudioTypography.body)
                            .foregroundStyle(StudioTheme.paperInk)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loaded(let explanation):
                    ScrollView {
                        Text(explanation)
                            .font(StudioTypography.body)
                            .foregroundStyle(StudioTheme.paperInk)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    .scrollIndicators(.visible)

                case .failed(let key):
                    VStack(spacing: 18) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(StudioTheme.vermilion)

                        Text(copy(key))
                            .font(StudioTypography.body)
                            .foregroundStyle(StudioTheme.paperInk)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Button(copy("alias.explanation.retry")) {
                            state = .loading
                            attempt += 1
                        }
                        .buttonStyle(PaperActionButtonStyle(kind: .outlined))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            if let graceSecondsRemaining {
                Text(copy("alias.explanation.resume_countdown", graceSecondsRemaining))
                    .font(StudioTypography.compactLabel)
                    .foregroundStyle(StudioTheme.paperInk)
                    .padding(.horizontal, 16)
                    .frame(minHeight: 34)
                    .background(TornPaperShape().fill(StudioTheme.olive.opacity(0.28)))
            }

            Text(copy("alias.explanation.note"))
                .font(StudioTypography.footnote)
                .foregroundStyle(StudioTheme.paperInk.opacity(0.62))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                TornPaperShape()
                    .fill(StudioTheme.sky)
                    .offset(x: 6, y: 6)
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

    @MainActor
    private func load() async {
        graceSecondsRemaining = nil
        do {
            let explanation = try await AliasWordExplanationService().explanation(for: word)
            try Task.checkCancellation()
            state = .loaded(explanation)
            try await runReadingGracePeriod()
            dismiss()
        } catch is CancellationError {
            // Dismissing the sheet cancels loading or the reading grace period.
        } catch {
            guard !Task.isCancelled else { return }
            graceSecondsRemaining = nil
            if let lookupError = error as? AliasWordExplanationService.LookupError {
                state = .failed(lookupError.localizationKey)
            } else if error is URLError {
                state = .failed("alias.explanation.network_error")
            } else {
                state = .failed("alias.explanation.unavailable")
            }
        }
    }

    @MainActor
    private func runReadingGracePeriod() async throws {
        for seconds in stride(from: 5, through: 1, by: -1) {
            graceSecondsRemaining = seconds
            try await Task.sleep(for: .seconds(1))
        }
        graceSecondsRemaining = nil
    }

    private func copy(_ key: String) -> String {
        AliasLocalizationCatalog.stringsByKey[key]?.localized() ?? key
    }

    private func copy(_ key: String, _ value: CVarArg) -> String {
        aliasLocalizedFormat(key, fallback: key, value)
    }
}
