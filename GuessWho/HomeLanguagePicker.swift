import SwiftUI

struct HomeLanguagePicker: View {
    let selectedLanguage: GuessWhoLanguage
    let label: String
    let englishTitle: String
    let ukrainianTitle: String
    let onSelect: (GuessWhoLanguage) -> Void

    var body: some View {
        HStack(spacing: 10) {
            languageButton(for: .english, title: englishTitle)
            languageButton(for: .ukrainian, title: ukrainianTitle)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(StudioTheme.line, lineWidth: 1) }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(selectedLanguage == .ukrainian ? ukrainianTitle : englishTitle)
    }

    private func languageButton(for language: GuessWhoLanguage, title: String) -> some View {
        let isSelected = selectedLanguage == language
        return Button { onSelect(language) } label: {
            LanguageFlagView(language: language)
                .frame(width: 42, height: 28).padding(.horizontal, 6).frame(maxWidth: .infinity).frame(height: 46)
                .background(isSelected ? Color.white.opacity(0.92) : Color.clear).contentShape(Capsule()).clipShape(Capsule())
                .overlay { Capsule().stroke(isSelected ? selectionBorder(for: language) : Color.clear, lineWidth: 1.5) }
                .shadow(color: isSelected ? StudioTheme.shadowSoft.opacity(1.2) : .clear, radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func selectionBorder(for language: GuessWhoLanguage) -> Color {
        switch language {
        case .english: Color(red: 0.06, green: 0.20, blue: 0.53).opacity(0.28)
        case .ukrainian: StudioTheme.gold.opacity(0.45)
        }
    }
}
