import SwiftUI

struct ResultView: View {
    let language: GuessWhoLanguage; let winner: GameState.Player; let reason: GameState.EndReason; let playerName: (GameState.Player) -> String; let oneSecret: Character?; let twoSecret: Character?; let onNewGame: () -> Void
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 18) {
        StageHeader(label: localized("screen.result.label", "Round Result", language), title: guessWhoLocalizedFormat("screen.result.title", fallback: "%@ wins!", language: language, [playerName(winner) as CVarArg]), message: guessWhoLocalizedFormat("screen.result.message", fallback: "The answer was %@.", language: language, [revealed.name as CVarArg]), tint: StudioTheme.coral)
        StudioSurface { VStack(spacing: 12) { Text(localized("screen.result.reveal", "Revealed Character", language)).font(.caption.weight(.bold)).foregroundStyle(StudioTheme.coral); PortraitView(character: revealed).frame(height: 220); Text(revealed.name).font(.title.bold()); Text(revealed.boardSummary).foregroundStyle(StudioTheme.muted) } }
        StudioSurface { HStack { SecretSummary(title: playerName(.one), character: oneSecret, tint: StudioTheme.teal); SecretSummary(title: playerName(.two), character: twoSecret, tint: StudioTheme.coral) } }
        StudioButton(title: localized("home.start", "Start New Game", language), icon: "arrow.clockwise", tint: StudioTheme.coral, outlined: false, action: onNewGame)
    }.padding(20).padding(.top, 18) } }
    private var revealed: Character { if case .correctGuess(let character) = reason { return character }; return oneSecret ?? twoSecret ?? Character.starterRoster[0] }
}

private struct SecretSummary: View {
    let title: String; let character: Character?; let tint: Color
    var body: some View { VStack(alignment: .leading, spacing: 4) { Text(title).font(.caption.weight(.bold)).foregroundStyle(tint); Text(character?.name ?? "?").font(.headline).lineLimit(1) }.frame(maxWidth: .infinity, alignment: .leading) }
}
