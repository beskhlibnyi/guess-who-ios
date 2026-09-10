import SwiftUI

@MainActor
final class GameState: ObservableObject {
    struct QuestionNote: Identifiable, Equatable {
        let id: UUID
        let stepNumber: Int
        var question: String
        var answer: Bool
    }

    enum AppScreen: Equatable {
        case gamePicker
        case aliasMenu
        case aliasPreview
        case aliasGame
        case menu
        case rules
        case game
    }

    enum Game: String, CaseIterable, Hashable, Identifiable {
        case guessWho
        case alias

        var id: String {
            rawValue
        }

        var isAvailable: Bool {
            switch self {
            case .guessWho:
                return true
            case .alias:
                return true
            }
        }

        var characters: [Character] {
            switch self {
            case .guessWho:
                return Character.starterRoster
            case .alias:
                return []
            }
        }
    }

    enum Player: Hashable {
        case one
        case two

        var next: Player {
            switch self {
            case .one:
                return .two
            case .two:
                return .one
            }
        }
    }

    enum HandoffReason: Equatable {
        case secretSelected
        case turnPassed
        case wrongGuess(Character)
    }

    enum EndReason: Equatable {
        case correctGuess(Character)
    }

    enum Phase: Equatable {
        case idle
        case selectingSecret(Player)
        case handoff(from: Player, to: Player, reason: HandoffReason)
        case choosingTurnAction(Player)
        case awaitingAnswer(Player)
        case eliminating(Player, answer: Bool)
        case guessing(Player)
        case gameOver(winner: Player, reason: EndReason)

        var activePlayer: Player? {
            switch self {
            case .idle:
                return nil
            case .selectingSecret(let player),
                    .choosingTurnAction(let player),
                    .awaitingAnswer(let player),
                    .eliminating(let player, _),
                    .guessing(let player),
                    .gameOver(let player, _):
                return player
            case .handoff(_, let toPlayer, _):
                return toPlayer
            }
        }

        var hasRoundInProgress: Bool {
            switch self {
            case .idle, .gameOver:
                return false
            case .selectingSecret,
                    .handoff,
                    .choosingTurnAction,
                    .awaitingAnswer,
                    .eliminating,
                    .guessing:
                return true
            }
        }
    }

    @Published private(set) var selectedGame: Game = .guessWho
    @Published private(set) var characters: [Character] = Game.guessWho.characters
    @Published private(set) var playerOneSecret: Character?
    @Published private(set) var playerTwoSecret: Character?
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var appScreen: AppScreen = .gamePicker
    @Published private(set) var eliminatedCharacterIDsByPlayer: [Player: Set<Character.ID>] = [
        .one: [],
        .two: []
    ]
    @Published private(set) var questionNotesByPlayer: [Player: [QuestionNote]] = [
        .one: [],
        .two: []
    ]
    @Published private(set) var questionDraftsByPlayer: [Player: String] = [
        .one: "",
        .two: ""
    ]

    init() {
        #if DEBUG
        applyDebugScenarioIfNeeded()
        #endif
    }

    var currentPlayer: Player {
        phase.activePlayer ?? .one
    }

    var hasRoundInProgress: Bool {
        phase.hasRoundInProgress
    }

    func selectGame(_ game: Game) {
        guard game.isAvailable else { return }

        if selectedGame != game {
            selectedGame = game
            characters = game.characters
            clearRoundState()
        }

        switch game {
        case .guessWho:
            appScreen = .menu
        case .alias:
            appScreen = .aliasMenu
        }
    }

    func startNewGame() {
        appScreen = .game
        resetRound()
    }

    func resumeGame() {
        guard hasRoundInProgress else { return }
        appScreen = .game
    }

    func showMenu() {
        switch selectedGame {
        case .guessWho:
            appScreen = .menu
        case .alias:
            appScreen = .aliasMenu
        }
    }

    func showAliasReview() {
        guard selectedGame == .alias else { return }
        appScreen = .aliasPreview
    }

    func showAliasGame() {
        guard selectedGame == .alias else { return }
        appScreen = .aliasGame
    }

    func showGamePicker() {
        appScreen = .gamePicker
    }

    func showRules() {
        appScreen = .rules
    }

    func chooseAskQuestion() {
        guard case .choosingTurnAction(let player) = phase else { return }
        phase = .awaitingAnswer(player)
    }

    func chooseMakeGuess() {
        guard case .choosingTurnAction(let player) = phase else { return }
        phase = .guessing(player)
    }

    func returnToTurnChoice() {
        switch phase {
        case .awaitingAnswer(let player), .guessing(let player):
            phase = .choosingTurnAction(player)
        case .idle,
                .selectingSecret,
                .handoff,
                .choosingTurnAction,
                .eliminating,
                .gameOver:
            break
        }
    }

    func recordAnswer(_ answer: Bool) {
        guard case .awaitingAnswer(let player) = phase else { return }
        saveQuestionNoteIfNeeded(for: player, answer: answer)
        phase = .eliminating(player, answer: answer)
    }

    func passTurn() {
        guard case .eliminating(let player, _) = phase else { return }
        showHandoff(from: player, reason: .turnPassed)
    }

    func continueAfterHandoff() {
        guard case .handoff(_, let nextPlayer, _) = phase else { return }
        showNextStep(for: nextPlayer)
    }

    func handleCharacterTap(_ character: Character) {
        switch phase {
        case .idle:
            break
        case .selectingSecret(let player):
            selectSecret(character, for: player)
        case .eliminating(let player, _):
            toggleEliminated(character, for: player)
        case .guessing(let player):
            submitGuess(character, by: player)
        case .handoff,
                .choosingTurnAction,
                .awaitingAnswer,
                .gameOver:
            break
        }
    }

    func secretCharacter(for player: Player) -> Character? {
        player == .one ? playerOneSecret : playerTwoSecret
    }

    func isEliminated(_ character: Character, for player: Player) -> Bool {
        eliminatedIDs(for: player).contains(character.id)
    }

    func remainingCharacters(for player: Player) -> [Character] {
        let hiddenIDs = eliminatedIDs(for: player)
        return characters.filter { !hiddenIDs.contains($0.id) }
    }

    func eliminatedCount(for player: Player) -> Int {
        eliminatedIDs(for: player).count
    }

    func questionNotes(for player: Player) -> [QuestionNote] {
        questionNotesByPlayer[player, default: []]
    }

    func questionDraft(for player: Player) -> String {
        questionDraftsByPlayer[player, default: ""]
    }

    func nextQuestionStep(for player: Player) -> Int {
        questionNotes(for: player).count + 1
    }

    func updateQuestionDraft(_ question: String, for player: Player) {
        var updatedDrafts = questionDraftsByPlayer
        updatedDrafts[player] = question
        questionDraftsByPlayer = updatedDrafts
    }

    func updateQuestionNoteText(
        _ question: String,
        noteID: QuestionNote.ID,
        for player: Player
    ) {
        updateQuestionNote(for: player, noteID: noteID) { note in
            note.question = question
        }
    }

    func updateQuestionNoteAnswer(
        _ answer: Bool,
        noteID: QuestionNote.ID,
        for player: Player
    ) {
        updateQuestionNote(for: player, noteID: noteID) { note in
            note.answer = answer
        }
    }

    private func resetRound() {
        phase = .selectingSecret(.one)
        playerOneSecret = nil
        playerTwoSecret = nil
        eliminatedCharacterIDsByPlayer = [.one: [], .two: []]
        questionNotesByPlayer = [.one: [], .two: []]
        questionDraftsByPlayer = [.one: "", .two: ""]
    }

    private func clearRoundState() {
        phase = .idle
        playerOneSecret = nil
        playerTwoSecret = nil
        eliminatedCharacterIDsByPlayer = [.one: [], .two: []]
        questionNotesByPlayer = [.one: [], .two: []]
        questionDraftsByPlayer = [.one: "", .two: ""]
    }

    private func selectSecret(_ character: Character, for player: Player) {
        setSecret(character, for: player)
        showHandoff(from: player, reason: .secretSelected)
    }

    private func toggleEliminated(_ character: Character, for player: Player) {
        var updatedIDs = eliminatedIDs(for: player)

        if updatedIDs.contains(character.id) {
            updatedIDs.remove(character.id)
        } else {
            updatedIDs.insert(character.id)
        }

        eliminatedCharacterIDsByPlayer[player] = updatedIDs
    }

    private func submitGuess(_ character: Character, by player: Player) {
        let opponent = player.next
        guard let opponentSecret = secretCharacter(for: opponent) else { return }

        if character.id == opponentSecret.id {
            phase = .gameOver(winner: player, reason: .correctGuess(character))
        } else {
            showHandoff(from: player, reason: .wrongGuess(character))
        }
    }

    private func setSecret(_ character: Character, for player: Player) {
        if player == .one {
            playerOneSecret = character
        } else {
            playerTwoSecret = character
        }
    }

    private func showHandoff(from player: Player, reason: HandoffReason) {
        let nextPlayer = player.next
        phase = .handoff(from: player, to: nextPlayer, reason: reason)
    }

    private func showNextStep(for player: Player) {
        phase = secretCharacter(for: player) == nil ? .selectingSecret(player) : .choosingTurnAction(player)
    }

    private func eliminatedIDs(for player: Player) -> Set<Character.ID> {
        eliminatedCharacterIDsByPlayer[player, default: []]
    }

    private func saveQuestionNoteIfNeeded(for player: Player, answer: Bool) {
        let trimmedQuestion = questionDraft(for: player)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        clearQuestionDraft(for: player)

        guard !trimmedQuestion.isEmpty else { return }

        var updatedNotes = questionNotes(for: player)
        updatedNotes.append(
            QuestionNote(
                id: UUID(),
                stepNumber: updatedNotes.count + 1,
                question: trimmedQuestion,
                answer: answer
            )
        )
        questionNotesByPlayer[player] = updatedNotes
    }

    private func clearQuestionDraft(for player: Player) {
        var updatedDrafts = questionDraftsByPlayer
        updatedDrafts[player] = ""
        questionDraftsByPlayer = updatedDrafts
    }

    private func updateQuestionNote(
        for player: Player,
        noteID: QuestionNote.ID,
        update: (inout QuestionNote) -> Void
    ) {
        var updatedNotes = questionNotes(for: player)

        guard let noteIndex = updatedNotes.firstIndex(where: { $0.id == noteID }) else {
            return
        }

        update(&updatedNotes[noteIndex])
        questionNotesByPlayer[player] = updatedNotes
    }

    #if DEBUG
    private func applyDebugScenarioIfNeeded() {
        guard let scenario = ProcessInfo.processInfo.environment["GUESSWHO_DEBUG_SCENARIO"] else {
            return
        }

        switch scenario {
        case "rules":
            appScreen = .rules
        case "home_resume":
            seedLiveRound()
            appScreen = .menu
        case "secret_1":
            appScreen = .game
            phase = .selectingSecret(.one)
        case "secret_2":
            seedPlayerOneSecretOnly()
            phase = .selectingSecret(.two)
        case "handoff_secret":
            seedPlayerOneSecretOnly()
            phase = .handoff(from: .one, to: .two, reason: .secretSelected)
        case "turn_choice":
            seedLiveRound()
            phase = .choosingTurnAction(.one)
        case "awaiting_answer":
            seedLiveRound()
            phase = .awaitingAnswer(.one)
        case "eliminating_yes":
            seedLiveRound()
            eliminatedCharacterIDsByPlayer[.one] = Set(characters.prefix(9).map(\.id))
            phase = .eliminating(.one, answer: true)
        case "guessing":
            seedLiveRound()
            eliminatedCharacterIDsByPlayer[.one] = Set(characters.prefix(18).map(\.id))
            phase = .guessing(.one)
        case "handoff_turn":
            seedLiveRound()
            phase = .handoff(from: .one, to: .two, reason: .turnPassed)
        case "handoff_wrong_guess":
            seedLiveRound()
            phase = .handoff(from: .one, to: .two, reason: .wrongGuess(characters[7]))
        case "game_over":
            seedLiveRound()
            phase = .gameOver(winner: .one, reason: .correctGuess(playerTwoSecret ?? characters[6]))
        default:
            break
        }
    }

    private func seedPlayerOneSecretOnly() {
        appScreen = .game
        playerOneSecret = characters[0]
        playerTwoSecret = nil
        eliminatedCharacterIDsByPlayer = [.one: [], .two: []]
    }

    private func seedLiveRound() {
        appScreen = .game
        playerOneSecret = characters[0]
        playerTwoSecret = characters[6]
        eliminatedCharacterIDsByPlayer = [
            .one: Set([characters[1].id, characters[4].id, characters[6].id, characters[10].id]),
            .two: Set([characters[0].id, characters[3].id, characters[5].id, characters[11].id])
        ]
        phase = .choosingTurnAction(.one)
    }
    #endif
}
