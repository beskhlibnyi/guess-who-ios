import SwiftUI

struct RulesView: View {
    let language: GuessWhoLanguage; let hasRoundInProgress: Bool; let playerName: (GameState.Player) -> String
    let onHome: () -> Void; let onResume: () -> Void; let onStart: () -> Void
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 20) {
        StudioSurface { VStack(alignment: .leading, spacing: 18) {
            HStack { StageHeader(label: localized("rules.badge", "Quick Guide", language), title: localized("rules.title", "How to Play", language), message: localized("rules.subtitle", "Pick in private, pass the phone, and narrow it down.", language), tint: StudioTheme.gold); Spacer(); Button(action: onHome) { Image(systemName: "house") }.foregroundStyle(StudioTheme.ink) }
            RuleStep(number: "1", title: localized("rules.step1.title", "Pick in private", language), message: guessWhoLocalizedFormat("rules.step1.message", fallback: "%@ picks first. Then %@.", language: language, [playerName(.one) as CVarArg, playerName(.two) as CVarArg]))
            RuleStep(number: "2", title: localized("rules.step2.title", "Ask or guess", language), message: localized("rules.step2.message", "Start every turn by choosing one.", language))
            RuleStep(number: "3", title: localized("rules.step3.title", "Answer first", language), message: localized("rules.step3.message", "After Yes or No, cross off the faces that no longer fit.", language))
            RuleStep(number: "4", title: localized("rules.step4.title", "Guess to win", language), message: localized("rules.step4.message", "Even with one face left, you still need to make the final guess.", language))
            if hasRoundInProgress { StudioButton(title: localized("home.resume", "Resume Game", language), icon: "arrow.clockwise", tint: StudioTheme.teal, outlined: true, action: onResume) }
            StudioButton(title: localized("home.start", "Start New Game", language), icon: "play.fill", tint: StudioTheme.coral, outlined: false, action: onStart)
        }}
    }.padding(20).padding(.top, 20) } }
}

private struct RuleStep: View {
    let number: String; let title: String; let message: String
    var body: some View { HStack(alignment: .top, spacing: 12) { Text(number).font(.headline).foregroundStyle(Color.white).frame(width: 28, height: 28).background(StudioTheme.teal, in: Circle()); VStack(alignment: .leading, spacing: 3) { Text(title).font(.headline); Text(message).font(.subheadline).foregroundStyle(StudioTheme.muted) } } }
}
