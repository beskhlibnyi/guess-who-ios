import SwiftUI

/// Current deck progress: approval is a subset of revealed words; discards are a separate outcome.
struct AliasStatisticsFunnel: View {
    let title: String
    let statistics: AliasVocabulary.Statistics
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(StudioTypography.label)
                .foregroundStyle(accent)
                .accessibilityAddTraits(.isHeader)

            stage("alias.statistics.total", count: statistics.total, outOf: statistics.total, color: accent)
            conversion(statistics.revealed, from: statistics.total, key: "alias.statistics.of_total")
            stage("alias.statistics.revealed", count: statistics.revealed, outOf: statistics.total, color: accent)
            conversion(statistics.approved, from: statistics.revealed, key: "alias.statistics.of_revealed")
            stage("alias.statistics.approved", count: statistics.approved, outOf: statistics.revealed, color: StudioTheme.teal)

            VStack(alignment: .leading, spacing: 6) {
                countLabel("alias.statistics.discarded", count: statistics.discarded)
                Text(conversionText(statistics.discarded, from: statistics.revealed, key: "alias.statistics.of_revealed"))
                    .font(StudioTypography.footnote)
                    .foregroundStyle(StudioTheme.muted)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StudioTheme.coral.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            .accessibilityElement(children: .combine)
        }
    }

    private func stage(_ key: String, count: Int, outOf previous: Int, color: Color) -> some View {
        VStack(spacing: 8) {
            countLabel(key, count: count)

            // Each fill matches the conversion percentage immediately above its stage.
            GeometryReader { geometry in
                Capsule()
                    .fill(StudioTheme.softWash)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(color)
                            .frame(width: geometry.size.width * share(count, of: previous))
                    }
                    .clipShape(Capsule())
            }
            .frame(height: 12)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    private func countLabel(_ key: String, count: Int) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) {
                Text(copy(key))
                Spacer(minLength: 12)
                Text(count.formatted(.number.locale(AliasLanguage.active.locale)))
                    .monospacedDigit()
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(copy(key))
                Text(count.formatted(.number.locale(AliasLanguage.active.locale)))
                    .monospacedDigit()
            }
        }
        .font(StudioTypography.subheadline)
        .foregroundStyle(StudioTheme.ink)
    }

    private func conversion(_ count: Int, from previous: Int, key: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "arrow.down")
                .accessibilityHidden(true)
            Text(conversionText(count, from: previous, key: key))
        }
        .font(StudioTypography.footnote)
        .foregroundStyle(StudioTheme.muted)
        .frame(maxWidth: .infinity)
    }

    private func conversionText(_ count: Int, from previous: Int, key: String) -> String {
        guard previous > 0 else { return copy("alias.statistics.unavailable") }
        let percentage = share(count, of: previous).formatted(
            .percent.precision(.significantDigits(1...3)).locale(AliasLanguage.active.locale)
        )
        return String(format: copy(key), locale: AliasLanguage.active.locale, percentage)
    }

    private func share(_ count: Int, of total: Int) -> Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, Double(count) / Double(total)))
    }

    private func copy(_ key: String) -> String {
        aliasLocalized(key, fallback: key)
    }
}
