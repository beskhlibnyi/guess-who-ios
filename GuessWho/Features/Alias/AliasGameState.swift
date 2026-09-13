import Foundation
import SwiftUI

@MainActor
final class AliasGameState: ObservableObject {
    static let targetScoreKey = "aliasTargetScore"
    static let targetScoreOptions = [10, 20, 30, 50]
    static let defaultTargetScore = 30
    static let turnDurationKey = "aliasTurnDuration"
    static let turnDurationOptions = [30, 45, 60, 90]
    static let defaultTurnDuration = 60
    static let easyWordsKey = "aliasIncludeEasyWords"
    static let mediumWordsKey = "aliasIncludeMediumWords"
    static let hardWordsKey = "aliasIncludeHardWords"
    static let expertWordsKey = "aliasIncludeExpertWords"
    static let defaultDifficultyLevels: Set<AliasVocabulary.DifficultyLevel> = [.easy, .medium, .hard]

    struct Configuration: Equatable {
        let targetScore: Int
        let turnDuration: TimeInterval
        let difficultyLevels: Set<AliasVocabulary.DifficultyLevel>
        let includeAdjectives: Bool
    }

    enum Phase: Equatable {
        case idle
        case loading
        case handoff(to: GameState.Player)
        case ready(GameState.Player)
        case playing(GameState.Player)
        case turnResult(GameState.Player)
        case matchOver(winner: GameState.Player)
        case deckUnavailable
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var configuration = Configuration(
        targetScore: defaultTargetScore,
        turnDuration: TimeInterval(defaultTurnDuration),
        difficultyLevels: defaultDifficultyLevels,
        includeAdjectives: true
    )
    @Published private(set) var scoresByPlayer: [GameState.Player: Int] = [.one: 0, .two: 0]
    @Published private(set) var currentWord: AliasVocabulary.Word?
    @Published private(set) var secondsRemaining = defaultTurnDuration
    @Published private(set) var turnScore = 0
    @Published private(set) var correctCount = 0
    @Published private(set) var skippedCount = 0
    @Published private(set) var completedTurns = 0
    @Published private(set) var isOvertime = false

    private let batchSize = 2_000
    private var words: [AliasVocabulary.Word] = []
    private var nextWordIndex = 0
    private var usedWordIDs: Set<AliasVocabulary.Word.ID> = []
    private var deadline: Date?
    private var pendingWinner: GameState.Player?
    private var startingPlayer: GameState.Player = .one
    private var nextMatchStartingPlayer: GameState.Player = .one
    private var loadID = UUID()

    var canResume: Bool {
        switch phase {
        case .idle, .matchOver, .deckUnavailable:
            return false
        case .loading, .handoff, .ready, .playing, .turnResult:
            return true
        }
    }

    var roundNumber: Int {
        max(1, (completedTurns + 1) / 2)
    }

    func score(for player: GameState.Player) -> Int {
        scoresByPlayer[player, default: 0]
    }

    func startMatch(
        targetScore: Int,
        turnDuration: Int,
        difficultyLevels: Set<AliasVocabulary.DifficultyLevel>,
        includeAdjectives: Bool
    ) {
        let validatedTarget = Self.targetScoreOptions.contains(targetScore)
            ? targetScore
            : Self.defaultTargetScore
        let validatedDuration = Self.turnDurationOptions.contains(turnDuration)
            ? turnDuration
            : Self.defaultTurnDuration
        let validatedLevels = difficultyLevels.isEmpty
            ? Self.defaultDifficultyLevels
            : difficultyLevels

        configuration = Configuration(
            targetScore: validatedTarget,
            turnDuration: TimeInterval(validatedDuration),
            difficultyLevels: validatedLevels,
            includeAdjectives: includeAdjectives
        )
        scoresByPlayer = [.one: 0, .two: 0]
        currentWord = nil
        secondsRemaining = Int(configuration.turnDuration)
        turnScore = 0
        correctCount = 0
        skippedCount = 0
        completedTurns = 0
        isOvertime = false
        words = []
        nextWordIndex = 0
        usedWordIDs = []
        deadline = nil
        pendingWinner = nil
        startingPlayer = nextMatchStartingPlayer

        let requestID = UUID()
        loadID = requestID
        phase = .loading
        let seed = Int64.random(in: 1..<2_147_483_647)
        let pageSize = batchSize

        Task {
            let loadedWords = await Task.detached(priority: .userInitiated) {
                AliasVocabulary.gameplayWords(
                    page: 0,
                    pageSize: pageSize,
                    shuffleSeed: seed,
                    difficultyLevels: validatedLevels,
                    includeAdjectives: includeAdjectives
                )
            }.value

            guard loadID == requestID, phase == .loading else { return }
            guard !loadedWords.isEmpty else {
                phase = .deckUnavailable
                return
            }
            words = loadedWords
            phase = .handoff(to: startingPlayer)
        }
    }

    func acknowledgeHandoff() {
        guard case .handoff(let player) = phase else { return }
        phase = .ready(player)
    }

    func startTurn(now: Date = Date()) {
        guard case .ready(let player) = phase else { return }
        turnScore = 0
        correctCount = 0
        skippedCount = 0
        secondsRemaining = Int(configuration.turnDuration)
        deadline = now.addingTimeInterval(configuration.turnDuration)
        guard takeNextWord() else {
            phase = .deckUnavailable
            return
        }
        phase = .playing(player)
    }

    func markCorrect(now: Date = Date()) {
        guard case .playing(let player) = phase else { return }
        guard isBeforeDeadline(now) else {
            finishTurn(for: player)
            return
        }

        scoresByPlayer[player, default: 0] += 1
        turnScore += 1
        correctCount += 1
        advanceOrFinish(for: player)
    }

    func skipWord(now: Date = Date()) {
        guard case .playing(let player) = phase else { return }
        guard isBeforeDeadline(now) else {
            finishTurn(for: player)
            return
        }

        scoresByPlayer[player, default: 0] -= 1
        turnScore -= 1
        skippedCount += 1
        advanceOrFinish(for: player)
    }

    @discardableResult
    func excludeCurrentWord(now: Date = Date()) -> Bool {
        guard case .playing(let player) = phase,
              let currentWord else { return false }
        guard isBeforeDeadline(now) else {
            finishTurn(for: player)
            return false
        }
        guard AliasVocabulary.reviewWord(id: currentWord.id, decision: .discarded) else {
            return false
        }

        advanceOrFinish(for: player)
        return true
    }

    func tick(now: Date = Date()) {
        guard case .playing(let player) = phase, let deadline else { return }
        let remaining = max(0, Int(ceil(deadline.timeIntervalSince(now))))
        if remaining != secondsRemaining {
            secondsRemaining = remaining
        }
        if remaining == 0 {
            finishTurn(for: player)
        }
    }

    func continueAfterTurn() {
        guard case .turnResult(let player) = phase else { return }

        if let pendingWinner {
            nextMatchStartingPlayer = pendingWinner.next
            phase = .matchOver(winner: pendingWinner)
            return
        }

        phase = .handoff(to: player.next)
    }

    func returnToMenu() {
        deadline = nil
    }

    private func advanceOrFinish(for player: GameState.Player) {
        guard takeNextWord() else {
            finishTurn(for: player)
            return
        }
    }

    private func takeNextWord() -> Bool {
        while nextWordIndex < words.count {
            let candidate = words[nextWordIndex]
            nextWordIndex += 1
            if usedWordIDs.insert(candidate.id).inserted {
                currentWord = candidate
                return true
            }
        }
        currentWord = nil
        return false
    }

    private func isBeforeDeadline(_ now: Date) -> Bool {
        guard let deadline else { return false }
        return now < deadline
    }

    private func finishTurn(for player: GameState.Player) {
        guard case .playing(player) = phase else { return }
        deadline = nil
        secondsRemaining = 0
        currentWord = nil
        completedTurns += 1
        pendingWinner = nil

        if completedTurns.isMultiple(of: 2) {
            evaluateMatchAfterCompletedRound()
        }
        phase = .turnResult(player)
    }

    private func evaluateMatchAfterCompletedRound() {
        let playerOneScore = score(for: .one)
        let playerTwoScore = score(for: .two)
        let targetReached = max(playerOneScore, playerTwoScore) >= configuration.targetScore
        guard targetReached else { return }

        if playerOneScore == playerTwoScore {
            isOvertime = true
        } else {
            pendingWinner = playerOneScore > playerTwoScore ? .one : .two
        }
    }
}
