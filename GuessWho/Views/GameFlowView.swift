import SwiftUI

struct GameFlowView: View {
    @EnvironmentObject private var gameState: GameState
    let language: GuessWhoLanguage; let playerName: (GameState.Player) -> String
    var body: some View {
        switch gameState.phase {
        case .idle:
            EmptyView()
        case .selectingSecret(let player): boardScreen(player, label: localized("screen.secret.label", "Choose Secret", language), title: secretTitle(player), message: localized("screen.secret.message", "Choose your character privately.", language), mode: .selectSecret, tint: StudioTheme.teal, footer: { EmptyView() })
        case .handoff(_, let player, _): handoff(player)
        case .choosingTurnAction(let player): turnChoice(player)
        case .awaitingAnswer(let player): answerStep(player)
        case .eliminating(let player, let answer): elimination(player, answer)
        case .guessing(let player): guessing(player)
        case .gameOver(let winner, let reason): ResultView(language: language, winner: winner, reason: reason, playerName: playerName, oneSecret: gameState.secretCharacter(for: .one), twoSecret: gameState.secretCharacter(for: .two), onNewGame: gameState.startNewGame)
        }
    }

    private func handoff(_ player: GameState.Player) -> some View { ZStack { Color(red: 0.12, green: 0.20, blue: 0.21).ignoresSafeArea(); StudioSurface { VStack(spacing: 22) { Image(systemName: "hand.raised.fill").font(.system(size: 40)).foregroundStyle(StudioTheme.coral); Text(handoffTitle(player)).font(.system(.title, design: .rounded).bold()).multilineTextAlignment(.center); Text(guessWhoLocalizedFormat("screen.handoff.message", fallback: "%@, tap below when you are ready.", language: language, [playerName(player) as CVarArg])).multilineTextAlignment(.center).foregroundStyle(StudioTheme.muted); StudioButton(title: guessWhoLocalizedFormat("screen.handoff.cta", fallback: "I am %@", language: language, [playerName(player) as CVarArg]), icon: "person.fill.checkmark", tint: StudioTheme.coral, outlined: false, action: gameState.continueAfterHandoff) } }.padding(24) } }

    private func turnChoice(_ player: GameState.Player) -> some View { ScrollView { VStack(alignment: .leading, spacing: 18) {
        StageHeader(label: localized("screen.turn.label", "Your Turn", language), title: playerName(player), message: localized("screen.turn.message", "Ask a question or make a final guess.", language), tint: StudioTheme.teal)
        notes(player, includesDraft: false)
        StudioSurface { VStack(alignment: .leading, spacing: 12) { Text(localized("screen.turn.ask.title", "Ask a Question", language)).font(.title3.bold()); Text(localized("screen.turn.ask.message", "Ask it out loud. Then record the answer.", language)).foregroundStyle(StudioTheme.muted); StudioButton(title: localized("screen.turn.ask.cta", "Ask a Question", language), icon: "text.bubble.fill", tint: StudioTheme.teal, outlined: false, action: gameState.chooseAskQuestion) } }
        StudioSurface { VStack(alignment: .leading, spacing: 12) { Text(localized("screen.turn.guess.title", "Make a Guess", language)).font(.title3.bold()); StudioButton(title: localized("screen.turn.guess.button", "Choose a Character", language), icon: "scope", tint: StudioTheme.coral, outlined: true, action: gameState.chooseMakeGuess) } }
    }.padding(20).padding(.top, 18) } }

    private func answerStep(_ player: GameState.Player) -> some View { ScrollView { VStack(alignment: .leading, spacing: 18) { StageHeader(label: localized("screen.answer.label", "Ask", language), title: guessWhoLocalizedFormat("screen.answer.title", fallback: "%@, ask your question", language: language, [playerName(player) as CVarArg]), message: localized("screen.answer.instruction", "Tap Yes or No after they answer.", language), tint: StudioTheme.teal); notes(player, includesDraft: true); StudioButton(title: localized("common.back", "Back", language), icon: "chevron.left", tint: StudioTheme.teal, outlined: true, action: gameState.returnToTurnChoice) }.padding(20).padding(.top, 18) } }

    private func elimination(_ player: GameState.Player, _ answer: Bool) -> some View { boardScreen(player, label: localized(answer ? "screen.elimination.yes.label" : "screen.elimination.no.label", answer ? "Yes" : "No", language), title: localized(answer ? "screen.elimination.yes.title" : "screen.elimination.no.title", "Update the board", language), message: localized(answer ? "screen.elimination.message.yes" : "screen.elimination.message.no", "Tap faces that no longer fit.", language), mode: .eliminate, tint: answer ? StudioTheme.teal : StudioTheme.coral, footer: { StudioButton(title: localized("screen.elimination.cta", "Pass the Phone", language), icon: "arrow.right.circle.fill", tint: StudioTheme.coral, outlined: false, action: gameState.passTurn) }) }

    private func guessing(_ player: GameState.Player) -> some View { boardScreen(player, label: localized("screen.guess.label", "Final Guess", language), title: localized("screen.guess.title", "Choose the secret face", language), message: localized("screen.guess.message", "Tap a character to make your guess.", language), mode: .guess, tint: StudioTheme.coral, footer: { StudioButton(title: localized("screen.guess.back", "Ask Instead", language), icon: "chevron.left", tint: StudioTheme.teal, outlined: true, action: gameState.returnToTurnChoice) }) }

    private func boardScreen<Footer: View>(_ player: GameState.Player, label: String, title: String, message: String, mode: BoardView.Mode, tint: Color, @ViewBuilder footer: () -> Footer) -> some View { ScrollView { VStack(alignment: .leading, spacing: 16) { StageHeader(label: label, title: title, message: message, tint: tint); notes(player, includesDraft: false); BoardView(characters: gameState.characters, mode: mode, player: player, isEliminated: { gameState.isEliminated($0, for: player) }, onTap: gameState.handleCharacterTap); footer() }.padding(20).padding(.top, 18).padding(.bottom, 34) } }

    private func notes(_ player: GameState.Player, includesDraft: Bool) -> some View { NotesView(language: language, player: player, notes: gameState.questionNotes(for: player), includesDraft: includesDraft, draft: Binding(get: { gameState.questionDraft(for: player) }, set: { gameState.updateQuestionDraft($0, for: player) }), updateText: { gameState.updateQuestionNoteText($0, noteID: $1, for: player) }, updateAnswer: { gameState.updateQuestionNoteAnswer($0, noteID: $1, for: player) }, recordAnswer: gameState.recordAnswer) }
    private func secretTitle(_ player: GameState.Player) -> String { guessWhoLocalizedFormat("screen.secret.title", fallback: "%@, choose your secret", language: language, [playerName(player) as CVarArg]) }
    private func handoffTitle(_ player: GameState.Player) -> String { guessWhoLocalizedFormat("screen.handoff.title", fallback: "Pass to %@", language: language, [playerName(player) as CVarArg]) }
}
