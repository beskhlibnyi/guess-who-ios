import SwiftUI

struct HomeView: View {
    let language: GuessWhoLanguage; let hasRoundInProgress: Bool; let currentPlayer: GameState.Player; let lockedSecrets: Int
    let playerName: (GameState.Player) -> String; let onStart: () -> Void; let onResume: () -> Void; let onRules: () -> Void; let onLanguageChange: (GuessWhoLanguage) -> Void
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 20) {
        Text(localized("home.title", "ХТО", language)).font(.system(size: 54, weight: .black, design: .rounded)).foregroundStyle(StudioTheme.ink)
        StudioSurface { VStack(spacing: 12) {
            StudioButton(title: localized("home.start", "Start New Game", language), icon: "play.fill", tint: StudioTheme.coral, outlined: false, action: onStart)
            if hasRoundInProgress { StudioButton(title: localized("home.resume", "Resume Game", language), icon: "arrow.clockwise.circle.fill", tint: StudioTheme.teal, outlined: true, action: onResume) }
            StudioButton(title: localized("home.rules", "How to Play", language), icon: "questionmark.circle", tint: StudioTheme.teal, outlined: true, action: onRules)
            Picker(localized("home.language.label", "Language", language), selection: Binding(get: { language }, set: onLanguageChange)) { Text(localized("home.language.english", "English", language)).tag(GuessWhoLanguage.english); Text(localized("home.language.ukrainian", "Ukrainian", language)).tag(GuessWhoLanguage.ukrainian) }.pickerStyle(.segmented).padding(.top, 8)
        }}
        if hasRoundInProgress { StudioSurface { VStack(alignment: .leading, spacing: 6) { Text(localized("home.live_round.title", "Game in progress", language)).font(.headline); Text("\(playerName(currentPlayer)) • \(lockedSecrets)/2").foregroundStyle(StudioTheme.muted) }}}
        Text(localized("home.footer", "© 2026 ХТО", language)).font(.caption).foregroundStyle(StudioTheme.muted).frame(maxWidth: .infinity)
    }.padding(.horizontal, 20).padding(.top, 72).padding(.bottom, 28) } }
}

struct PlayerSetupView: View {
    let language: GuessWhoLanguage; @Binding var playerOneName: String; @Binding var playerTwoName: String; let onBack: () -> Void; let onStart: () -> Void
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 20) {
        Button(action: onBack) { Label(localized("home.players.back", "Back", language), systemImage: "chevron.left") }.foregroundStyle(StudioTheme.ink)
        StudioSurface { VStack(alignment: .leading, spacing: 18) { Text(localized("home.players.title", "Name your players", language)).font(.title2.bold()); Text(localized("home.players.message", "Add names for each side, or leave them blank to keep the default labels.", language)).foregroundStyle(StudioTheme.muted); TextField(localized("home.player.one", "Player 1", language), text: $playerOneName).textFieldStyle(.roundedBorder); TextField(localized("home.player.two", "Player 2", language), text: $playerTwoName).textFieldStyle(.roundedBorder); StudioButton(title: localized("home.players.start", "Start Game", language), icon: "play.fill", tint: StudioTheme.coral, outlined: false, action: onStart) }}
    }.padding(20).padding(.top, 48) } }
}
