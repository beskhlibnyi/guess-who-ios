import Combine
import Foundation

enum AliasPlayer: Hashable {
    case one
    case two

    var next: AliasPlayer {
        switch self {
        case .one: .two
        case .two: .one
        }
    }
}

@MainActor
final class AliasGameState: ObservableObject {
    static let gameModeKey = "aliasGameMode"
    static let targetScoreKey = "aliasTargetScore"
    static let targetScoreRange = 1...50
    static let defaultTargetScore = 30
    static let turnDurationKey = "aliasTurnDuration"
    static let turnDurationRange = 30...90
    static let defaultTurnDuration = 60
    static let easyWordsKey = "aliasIncludeEasyWords"
    static let mediumWordsKey = "aliasIncludeMediumWords"
    static let hardWordsKey = "aliasIncludeHardWords"
    static let expertWordsKey = "aliasIncludeExpertWords"
    static let defaultDifficultyLevels: Set<AliasVocabulary.DifficultyLevel> = [.medium]

    enum GameMode: String, CaseIterable, Identifiable {
        case classic
        case fastest

        var id: String { rawValue }
    }

    struct Configuration: Equatable {
        let mode: GameMode
        let targetScore: Int
        let turnDuration: TimeInterval
        let difficultyLevels: Set<AliasVocabulary.DifficultyLevel>
        let includeAdjectives: Bool
    }

    enum Phase: Equatable {
        case idle
        case loading
        case handoff(to: AliasPlayer)
        case playing(AliasPlayer)
        case turnResult(AliasPlayer)
        case matchOver(winner: AliasPlayer)
        case deckUnavailable
    }

    enum WordOutcome: String, CaseIterable, Identifiable {
        case guessed
        case skipped
        case declined

        var id: String { rawValue }

        fileprivate var scoreDelta: Int {
            switch self {
            case .guessed: return 1
            case .skipped: return -1
            case .declined: return 0
            }
        }
    }

    struct TurnWord: Identifiable, Equatable {
        let word: AliasVocabulary.Word
        var outcome: WordOutcome

        var id: AliasVocabulary.Word.ID { word.id }
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var configuration = Configuration(
        mode: .classic,
        targetScore: defaultTargetScore,
        turnDuration: TimeInterval(defaultTurnDuration),
        difficultyLevels: defaultDifficultyLevels,
        includeAdjectives: true
    )
    @Published private(set) var scoresByPlayer: [AliasPlayer: Int] = [.one: 0, .two: 0]
    @Published private(set) var currentWord: AliasVocabulary.Word?
    @Published private(set) var secondsRemaining = defaultTurnDuration
    @Published private(set) var turnWords: [TurnWord] = []
    @Published private(set) var completedTurns = 0
    @Published private(set) var isPaused = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var elapsedTimesByPlayer: [AliasPlayer: TimeInterval] = [:]

    private let batchSize = 2_000
    private var words: [AliasVocabulary.Word] = []
    private var nextWordIndex = 0
    private var usedWordIDs: Set<AliasVocabulary.Word.ID> = []
    private var deadline: Date?
    private var runStartedAt: Date?
    private var pendingWinner: AliasPlayer?
    private var startingPlayer: AliasPlayer = .one
    private var nextMatchStartingPlayer: AliasPlayer = .one
    private var loadID = UUID()

    var canResume: Bool {
        switch phase {
        case .idle, .matchOver, .deckUnavailable:
            return false
        case .loading, .handoff, .playing, .turnResult:
            return true
        }
    }

    var turnScore: Int {
        turnWords.reduce(0) { $0 + $1.outcome.scoreDelta }
    }

    func score(for player: AliasPlayer) -> Int {
        scoresByPlayer[player, default: 0]
    }

    func elapsedTime(for player: AliasPlayer) -> TimeInterval? {
        elapsedTimesByPlayer[player]
    }

    func startMatch(
        mode: GameMode = .classic,
        targetScore: Int,
        turnDuration: Int,
        difficultyLevels: Set<AliasVocabulary.DifficultyLevel>,
        includeAdjectives: Bool
    ) {
        let validatedTarget = Self.targetScoreRange.contains(targetScore)
            ? targetScore
            : Self.defaultTargetScore
        let validatedDuration = Self.turnDurationRange.contains(turnDuration)
            ? turnDuration
            : Self.defaultTurnDuration
        let validatedLevels = difficultyLevels.isEmpty
            ? Self.defaultDifficultyLevels
            : difficultyLevels

        configuration = Configuration(
            mode: mode,
            targetScore: validatedTarget,
            turnDuration: TimeInterval(validatedDuration),
            difficultyLevels: validatedLevels,
            includeAdjectives: includeAdjectives
        )
        scoresByPlayer = [.one: 0, .two: 0]
        currentWord = nil
        secondsRemaining = Int(configuration.turnDuration)
        turnWords = []
        completedTurns = 0
        isPaused = false
        elapsedTime = 0
        elapsedTimesByPlayer = [:]
        words = []
        nextWordIndex = 0
        usedWordIDs = []
        deadline = nil
        runStartedAt = nil
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

    func startTurn(now: Date = Date()) {
        guard case .handoff(let player) = phase else { return }
        turnWords = []
        secondsRemaining = Int(configuration.turnDuration)
        elapsedTime = 0
        isPaused = false
        switch configuration.mode {
        case .classic:
            deadline = now.addingTimeInterval(configuration.turnDuration)
            runStartedAt = nil
        case .fastest:
            deadline = nil
            runStartedAt = now
        }
        guard takeNextWord() else {
            phase = .deckUnavailable
            return
        }
        phase = .playing(player)
    }

    func markCorrect(now: Date = Date()) {
        guard case .playing(let player) = phase else { return }
        guard canRecordResult(for: player, now: now) else {
            return
        }

        recordCurrentWord(as: .guessed, for: player)
        if configuration.mode == .fastest,
           score(for: player) >= configuration.targetScore {
            finishTurn(for: player, now: now)
        } else {
            advanceOrFinish(for: player, now: now)
        }
    }

    func skipWord(now: Date = Date()) {
        guard case .playing(let player) = phase else { return }
        guard canRecordResult(for: player, now: now) else {
            return
        }

        recordCurrentWord(as: .skipped, for: player)
        advanceOrFinish(for: player, now: now)
    }

    @discardableResult
    func excludeCurrentWord(now: Date = Date()) -> Bool {
        guard case .playing(let player) = phase,
              let currentWord else { return false }
        guard canRecordResult(for: player, now: now) else {
            return false
        }
        guard AliasVocabulary.reviewWord(id: currentWord.id, decision: .discarded) else {
            return false
        }

        recordCurrentWord(as: .declined, for: player)
        advanceOrFinish(for: player, now: now)
        return true
    }

    func tick(now: Date = Date()) {
        guard case .playing(let player) = phase, !isPaused else { return }
        switch configuration.mode {
        case .classic:
            guard let deadline else { return }
            let remaining = max(0, Int(ceil(deadline.timeIntervalSince(now))))
            if remaining != secondsRemaining {
                secondsRemaining = remaining
            }
            if remaining == 0 {
                finishTurn(for: player, now: now, markCurrentWordSkipped: true)
            }
        case .fastest:
            guard let runStartedAt else { return }
            elapsedTime = max(0, now.timeIntervalSince(runStartedAt))
        }
    }

    func continueAfterTurn() {
        guard case .turnResult(let player) = phase else { return }

        if configuration.mode == .fastest,
           score(for: player) < configuration.targetScore {
            guard takeNextWord() else {
                phase = .deckUnavailable
                return
            }
            elapsedTimesByPlayer[player] = nil
            restartClock()
            phase = .playing(player)
            return
        }

        completedTurns += 1
        if configuration.mode == .classic, completedTurns.isMultiple(of: 2) {
            evaluateMatchAfterCompletedRound()
        } else if configuration.mode == .fastest, completedTurns == 2 {
            evaluateFastestMatch()
        }

        if let pendingWinner {
            nextMatchStartingPlayer = pendingWinner.next
            phase = .matchOver(winner: pendingWinner)
            return
        }

        phase = .handoff(to: player.next)
    }

    @discardableResult
    func updateTurnWord(_ wordID: AliasVocabulary.Word.ID, to outcome: WordOutcome) -> Bool {
        guard case .turnResult(let player) = phase,
              let index = turnWords.firstIndex(where: { $0.id == wordID }) else { return false }
        let previousOutcome = turnWords[index].outcome
        guard previousOutcome != outcome else { return true }

        let word = turnWords[index].word
        if outcome == .declined {
            guard AliasVocabulary.reviewWord(id: wordID, decision: .discarded) else { return false }
        } else if previousOutcome == .declined {
            let didRestore: Bool
            if word.decision == .approved {
                didRestore = AliasVocabulary.reviewWord(id: wordID, decision: .approved)
            } else {
                didRestore = AliasVocabulary.returnWordToReview(id: wordID)
            }
            guard didRestore else { return false }
        }

        turnWords[index].outcome = outcome
        scoresByPlayer[player, default: 0] += outcome.scoreDelta - previousOutcome.scoreDelta
        return true
    }

    func pause(now: Date = Date()) {
        guard case .playing = phase, !isPaused else { return }
        freezeClock(now: now)
        isPaused = true
    }

    func resumeTurn(now: Date = Date()) {
        guard case .playing = phase, isPaused else { return }
        restartClock(now: now)
        isPaused = false
    }

    func resumeMatch(now: Date = Date()) {
        guard case .playing = phase else { return }
        restartClock(now: now)
        isPaused = false
    }

    func returnToMenu(now: Date = Date()) {
        if case .playing = phase {
            freezeClock(now: now)
        }
    }

    private func advanceOrFinish(for player: AliasPlayer, now: Date) {
        guard takeNextWord() else {
            finishTurn(for: player, now: now)
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

    private func recordCurrentWord(as outcome: WordOutcome, for player: AliasPlayer) {
        guard let currentWord else { return }
        turnWords.append(TurnWord(word: currentWord, outcome: outcome))
        scoresByPlayer[player, default: 0] += outcome.scoreDelta
    }

    private func canRecordResult(for player: AliasPlayer, now: Date) -> Bool {
        guard !isPaused else { return false }
        guard configuration.mode == .classic else { return true }
        guard let deadline, now < deadline else {
            finishTurn(for: player, now: now, markCurrentWordSkipped: true)
            return false
        }
        return true
    }

    private func finishTurn(
        for player: AliasPlayer,
        now: Date,
        markCurrentWordSkipped: Bool = false
    ) {
        guard case .playing(player) = phase else { return }
        if markCurrentWordSkipped, currentWord != nil {
            recordCurrentWord(as: .skipped, for: player)
        }
        if configuration.mode == .fastest, let runStartedAt {
            elapsedTime = max(0, now.timeIntervalSince(runStartedAt))
            elapsedTimesByPlayer[player] = elapsedTime
        }
        deadline = nil
        runStartedAt = nil
        isPaused = false
        if configuration.mode == .classic {
            secondsRemaining = 0
        }
        currentWord = nil
        pendingWinner = nil
        phase = .turnResult(player)
    }

    private func freezeClock(now: Date) {
        switch configuration.mode {
        case .classic:
            if let deadline {
                secondsRemaining = max(0, Int(ceil(deadline.timeIntervalSince(now))))
            }
        case .fastest:
            if let runStartedAt {
                elapsedTime = max(0, now.timeIntervalSince(runStartedAt))
            }
        }
        deadline = nil
        runStartedAt = nil
    }

    private func restartClock(now: Date) {
        switch configuration.mode {
        case .classic:
            if deadline == nil {
                deadline = now.addingTimeInterval(TimeInterval(secondsRemaining))
            }
        case .fastest:
            if runStartedAt == nil {
                runStartedAt = now.addingTimeInterval(-elapsedTime)
            }
        }
    }

    private func restartClock() {
        restartClock(now: Date())
        isPaused = false
    }

    private func evaluateMatchAfterCompletedRound() {
        let playerOneScore = score(for: .one)
        let playerTwoScore = score(for: .two)
        let targetReached = max(playerOneScore, playerTwoScore) >= configuration.targetScore
        guard targetReached else { return }

        if playerOneScore != playerTwoScore {
            pendingWinner = playerOneScore > playerTwoScore ? .one : .two
        }
    }

    private func evaluateFastestMatch() {
        guard
            let playerOneTime = elapsedTime(for: .one),
            let playerTwoTime = elapsedTime(for: .two)
        else { return }

        pendingWinner = playerOneTime <= playerTwoTime ? .one : .two
    }
}
