import SwiftUI

enum StudioTheme {
    static let canvasTop = Color(red: 0.97, green: 0.94, blue: 0.86)
    static let canvasBottom = Color(red: 0.89, green: 0.94, blue: 0.91)
    static let card = Color.white.opacity(0.82)
    static let ink = Color(red: 0.12, green: 0.15, blue: 0.16)
    static let muted = Color(red: 0.35, green: 0.40, blue: 0.39)
    static let teal = Color(red: 0.08, green: 0.50, blue: 0.47)
    static let coral = Color(red: 0.84, green: 0.30, blue: 0.23)
    static let gold = Color(red: 0.82, green: 0.58, blue: 0.17)
    static let line = Color.black.opacity(0.10)
}

struct AppBackgroundView: View {
    var body: some View { ZStack {
        LinearGradient(colors: [StudioTheme.canvasTop, StudioTheme.canvasBottom], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
        Circle().fill(StudioTheme.gold.opacity(0.14)).frame(width: 260).blur(radius: 12).offset(x: 150, y: -280)
        Circle().fill(StudioTheme.coral.opacity(0.10)).frame(width: 220).blur(radius: 18).offset(x: -150, y: 300)
    }}
}

struct StudioSurface<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View { content.padding(20).background(StudioTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(StudioTheme.line, lineWidth: 1)).shadow(color: .black.opacity(0.08), radius: 16, y: 8) }
}

struct StudioButton: View {
    let title: String; let icon: String; let tint: Color; let outlined: Bool; let action: () -> Void
    var body: some View { Button(action: action) { Label(title, systemImage: icon).font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14) }.foregroundStyle(outlined ? tint : Color.white).background(outlined ? Color.clear : tint, in: RoundedRectangle(cornerRadius: 16, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(tint, lineWidth: outlined ? 1.5 : 0)) }
}

struct StageHeader: View {
    let label: String; let title: String; let message: String; let tint: Color
    var body: some View { VStack(alignment: .leading, spacing: 8) { Text(label.uppercased()).font(.caption.weight(.bold)).foregroundStyle(tint); Text(title).font(.system(.title, design: .rounded).weight(.bold)).foregroundStyle(StudioTheme.ink); Text(message).font(.subheadline).foregroundStyle(StudioTheme.muted) } }
}

func localized(_ key: String, _ fallback: String, _ language: GuessWhoLanguage) -> String { guessWhoLocalized(key, fallback: fallback, language: language) }
