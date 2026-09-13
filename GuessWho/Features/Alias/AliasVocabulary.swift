import Foundation
import SQLite3

/// Reads and updates the scored Ukrainian Alias deck without loading every word into memory.
enum AliasVocabulary {
    private static let reviewShuffleSeedKey = "aliasVocabularyReviewShuffleSeed"
    static let includeAdjectivesKey = "aliasVocabularyIncludeAdjectives"

    private enum DifficultyCutoffs {
        static let easyUpper = 2.5
        static let mediumUpper = 3.5
        static let hardUpper = 4.5
    }

    enum DifficultyLevel: CaseIterable, Hashable, Sendable {
        case easy
        case medium
        case hard
        case expert

        fileprivate var predicateSQL: String {
            switch self {
            case .easy:
                return "difficulty < ?"
            case .medium:
                return "difficulty >= ? AND difficulty < ?"
            case .hard:
                return "difficulty >= ? AND difficulty < ?"
            case .expert:
                return "difficulty >= ?"
            }
        }

        fileprivate var bounds: [Double] {
            switch self {
            case .easy:
                return [DifficultyCutoffs.easyUpper]
            case .medium:
                return [DifficultyCutoffs.easyUpper, DifficultyCutoffs.mediumUpper]
            case .hard:
                return [DifficultyCutoffs.mediumUpper, DifficultyCutoffs.hardUpper]
            case .expert:
                return [DifficultyCutoffs.hardUpper]
            }
        }

        fileprivate var gameplayBucket: Int {
            switch self {
            case .easy: return 0
            case .medium: return 1
            case .hard: return 2
            case .expert: return 3
            }
        }
    }

    enum Decision: Sendable {
        case approved
        case discarded

        fileprivate var columnName: String {
            switch self {
            case .approved:
                return "approved"
            case .discarded:
                return "discarded"
            }
        }
    }

    struct Word: Identifiable, Equatable, Sendable {
        let id: Int64
        let text: String
        let isRevealed: Bool
        let decision: Decision?
    }

    struct Statistics: Equatable, Sendable {
        let total: Int
        let revealed: Int
        let approved: Int
        let discarded: Int

        static let zero = Statistics(total: 0, revealed: 0, approved: 0, discarded: 0)
    }

    static let sourceName = "mphdict Ukrainian grammatical dictionary"
    static let sourceURL = URL(string: "https://github.com/LinguisticAndInformationSystems/mphdict")!

    static func persistentReviewShuffleSeed() -> Int64 {
        let defaults = UserDefaults.standard
        if let savedSeed = defaults.object(forKey: reviewShuffleSeedKey) as? NSNumber,
           savedSeed.int64Value > 0 {
            return savedSeed.int64Value
        }

        let seed = Int64.random(in: 1..<2_147_483_647)
        defaults.set(seed, forKey: reviewShuffleSeedKey)
        return seed
    }

    static func statisticsByDifficulty(includeAdjectives: Bool) -> [DifficultyLevel: Statistics] {
        query(
            """
            SELECT
              CASE
                WHEN difficulty < \(DifficultyCutoffs.easyUpper) THEN 0
                WHEN difficulty < \(DifficultyCutoffs.mediumUpper) THEN 1
                WHEN difficulty < \(DifficultyCutoffs.hardUpper) THEN 2
                ELSE 3
              END AS difficulty_level,
              COUNT(*),
              COALESCE(SUM(revealed), 0),
              COALESCE(SUM(approved), 0),
              COALESCE(SUM(discarded), 0)
            FROM words
            WHERE enabled = 1
              AND \(playablePartOfSpeechPredicate(includeAdjectives: includeAdjectives))
            GROUP BY difficulty_level
            """
        ) { statement in
            var statistics: [DifficultyLevel: Statistics] = [:]
            while sqlite3_step(statement) == SQLITE_ROW {
                let level: DifficultyLevel
                switch sqlite3_column_int(statement, 0) {
                case 0: level = .easy
                case 1: level = .medium
                case 2: level = .hard
                default: level = .expert
                }
                statistics[level] = Statistics(
                    total: Int(sqlite3_column_int(statement, 1)),
                    revealed: Int(sqlite3_column_int(statement, 2)),
                    approved: Int(sqlite3_column_int(statement, 3)),
                    discarded: Int(sqlite3_column_int(statement, 4))
                )
            }
            return statistics
        } ?? [:]
    }

    static func words(
        in level: DifficultyLevel,
        page: Int,
        pageSize: Int,
        shuffleSeed: Int64,
        includeAdjectives: Bool
    ) -> [Word] {
        let offset = max(0, page * pageSize)
        guard let database = openDatabase() else {
            return []
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        let sql = """
            SELECT id, word, revealed, approved, discarded
            FROM words
            WHERE enabled = 1
              AND \(playablePartOfSpeechPredicate(includeAdjectives: includeAdjectives))
              AND approved = 0
              AND discarded = 0
              AND \(level.predicateSQL)
            ORDER BY ((id * ?) % 2147483647), id
            LIMIT ? OFFSET ?
            """
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }

        for (index, bound) in level.bounds.enumerated() {
            sqlite3_bind_double(statement, Int32(index + 1), bound)
        }
        let shuffleIndex = Int32(level.bounds.count + 1)
        sqlite3_bind_int64(statement, shuffleIndex, shuffleSeed)
        let paginationIndex = shuffleIndex + 1
        sqlite3_bind_int(statement, paginationIndex, Int32(pageSize))
        sqlite3_bind_int(statement, paginationIndex + 1, Int32(offset))

        var words: [Word] = []
        while sqlite3_step(statement) == SQLITE_ROW,
              let value = sqlite3_column_text(statement, 1) {
            let approved = sqlite3_column_int(statement, 3) == 1
            let discarded = sqlite3_column_int(statement, 4) == 1
            words.append(
                Word(
                    id: sqlite3_column_int64(statement, 0),
                    text: String(cString: value),
                    isRevealed: sqlite3_column_int(statement, 2) == 1,
                    decision: approved ? .approved : (discarded ? .discarded : nil)
                )
            )
        }
        return words
    }

    static func reviewedWords(
        in level: DifficultyLevel,
        decision: Decision,
        page: Int,
        pageSize: Int,
        includeAdjectives: Bool
    ) -> [Word] {
        let offset = max(0, page * pageSize)
        guard let database = openDatabase() else {
            return []
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        let sql = """
            SELECT id, word, revealed, approved, discarded
            FROM words
            WHERE enabled = 1
              AND \(playablePartOfSpeechPredicate(includeAdjectives: includeAdjectives))
              AND \(decision.columnName) = 1
              AND \(level.predicateSQL)
            ORDER BY word
            LIMIT ? OFFSET ?
            """
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }

        for (index, bound) in level.bounds.enumerated() {
            sqlite3_bind_double(statement, Int32(index + 1), bound)
        }
        let paginationIndex = Int32(level.bounds.count + 1)
        sqlite3_bind_int(statement, paginationIndex, Int32(pageSize))
        sqlite3_bind_int(statement, paginationIndex + 1, Int32(offset))

        var words: [Word] = []
        while sqlite3_step(statement) == SQLITE_ROW,
              let value = sqlite3_column_text(statement, 1) {
            words.append(
                Word(
                    id: sqlite3_column_int64(statement, 0),
                    text: String(cString: value),
                    isRevealed: sqlite3_column_int(statement, 2) == 1,
                    decision: sqlite3_column_int(statement, 3) == 1 ? .approved : .discarded
                )
            )
        }
        return words
    }

    /// Returns a deterministic shuffled page for the selected live-play groups.
    static func gameplayWords(
        page: Int,
        pageSize: Int,
        shuffleSeed: Int64,
        difficultyLevels: Set<DifficultyLevel>,
        includeAdjectives: Bool
    ) -> [Word] {
        let orderedLevels = DifficultyLevel.allCases.filter(difficultyLevels.contains)
        guard !orderedLevels.isEmpty else { return [] }

        let offset = max(0, page * pageSize)
        guard let database = openDatabase() else {
            return []
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        let difficultyPlaceholders = Array(repeating: "?", count: orderedLevels.count).joined(separator: ", ")
        let sql = """
            SELECT id, word, revealed, approved, discarded
            FROM words
            WHERE enabled = 1
              AND \(playablePartOfSpeechPredicate(includeAdjectives: includeAdjectives))
              AND discarded = 0
              AND CASE
                    WHEN difficulty < \(DifficultyCutoffs.easyUpper) THEN 0
                    WHEN difficulty < \(DifficultyCutoffs.mediumUpper) THEN 1
                    WHEN difficulty < \(DifficultyCutoffs.hardUpper) THEN 2
                    ELSE 3
                  END IN (\(difficultyPlaceholders))
            ORDER BY ((id * ?) % 2147483647), id
            LIMIT ? OFFSET ?
            """
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }

        for (index, level) in orderedLevels.enumerated() {
            sqlite3_bind_int(statement, Int32(index + 1), Int32(level.gameplayBucket))
        }
        let shuffleIndex = Int32(orderedLevels.count + 1)
        sqlite3_bind_int64(statement, shuffleIndex, shuffleSeed)
        sqlite3_bind_int(statement, shuffleIndex + 1, Int32(pageSize))
        sqlite3_bind_int(statement, shuffleIndex + 2, Int32(offset))

        var words: [Word] = []
        while sqlite3_step(statement) == SQLITE_ROW,
              let value = sqlite3_column_text(statement, 1) {
            let approved = sqlite3_column_int(statement, 3) == 1
            words.append(
                Word(
                    id: sqlite3_column_int64(statement, 0),
                    text: String(cString: value),
                    isRevealed: sqlite3_column_int(statement, 2) == 1,
                    decision: approved ? .approved : nil
                )
            )
        }
        return words
    }

    @discardableResult
    static func setWordRevealed(id: Int64, isRevealed: Bool) -> Bool {
        update(
            "UPDATE words SET revealed = \(isRevealed ? 1 : 0) WHERE id = ? AND enabled = 1",
            id: id
        )
    }

    @discardableResult
    static func reviewWord(id: Int64, decision: Decision) -> Bool {
        let values = decision == .approved ? (approved: 1, discarded: 0) : (approved: 0, discarded: 1)
        return update(
            """
            UPDATE words
            SET revealed = 1, approved = \(values.approved), discarded = \(values.discarded)
            WHERE id = ? AND enabled = 1
            """,
            id: id
        )
    }

    @discardableResult
    static func returnWordToReview(id: Int64) -> Bool {
        update(
            "UPDATE words SET approved = 0, discarded = 0 WHERE id = ? AND enabled = 1",
            id: id
        )
    }

    private static func update(_ sql: String, id: Int64) -> Bool {
        guard let database = openDatabase() else {
            return false
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return false
        }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_int64(statement, 1, id)
        return sqlite3_step(statement) == SQLITE_DONE && sqlite3_changes(database) > 0
    }

    private static func query<T>(
        _ sql: String,
        bindings: [Double] = [],
        transform: (OpaquePointer) -> T
    ) -> T? {
        guard let database = openDatabase() else {
            return nil
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return nil
        }
        defer { sqlite3_finalize(statement) }

        for (index, bound) in bindings.enumerated() {
            sqlite3_bind_double(statement, Int32(index + 1), bound)
        }

        return transform(statement)
    }

    private static func playablePartOfSpeechPredicate(includeAdjectives: Bool) -> String {
        includeAdjectives
            ? "part_of_speech IN ('noun', 'adjective')"
            : "part_of_speech = 'noun'"
    }

    private static func openDatabase() -> OpaquePointer? {
        guard let databaseURL = writableDatabaseURL else {
            return nil
        }

        var database: OpaquePointer?
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(databaseURL.path, &database, flags, nil) == SQLITE_OK,
              let database else {
            if let database {
                sqlite3_close(database)
            }
            return nil
        }

        guard migrateReviewColumns(in: database) else {
            sqlite3_close(database)
            return nil
        }
        return database
    }

    private static func migrateReviewColumns(in database: OpaquePointer) -> Bool {
        let existingColumns = columnNames(in: database)
        let migrations = [
            ("revealed", "ALTER TABLE words ADD COLUMN revealed INTEGER NOT NULL DEFAULT 0"),
            ("approved", "ALTER TABLE words ADD COLUMN approved INTEGER NOT NULL DEFAULT 0"),
            ("discarded", "ALTER TABLE words ADD COLUMN discarded INTEGER NOT NULL DEFAULT 0")
        ]

        for (column, sql) in migrations where !existingColumns.contains(column) {
            guard sqlite3_exec(database, sql, nil, nil, nil) == SQLITE_OK else {
                return false
            }
        }
        return true
    }

    private static func columnNames(in database: OpaquePointer) -> Set<String> {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, "PRAGMA table_info(words)", -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }

        var names: Set<String> = []
        while sqlite3_step(statement) == SQLITE_ROW,
              let value = sqlite3_column_text(statement, 1) {
            names.insert(String(cString: value))
        }
        return names
    }

    private static var writableDatabaseURL: URL? {
        guard let sourceURL = bundledDatabaseURL else {
            return nil
        }

        let fileManager = FileManager.default
        guard let applicationSupportURL = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return nil
        }

        let directoryURL = applicationSupportURL.appendingPathComponent("AliasVocabulary", isDirectory: true)
        let destinationURL = directoryURL.appendingPathComponent("alias_uk_words.sqlite")
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            if !fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
            }
            return destinationURL
        } catch {
            return nil
        }
    }

    /// Canvas runs in a host process, so its main bundle may not be the app bundle.
    private static var bundledDatabaseURL: URL? {
        let bundles = [
            Bundle.main,
            Bundle(for: AliasVocabularyBundleLocator.self)
        ] + Bundle.allBundles + Bundle.allFrameworks

        return bundles.lazy
            .compactMap { $0.url(forResource: "alias_uk_words", withExtension: "sqlite") }
            .first
    }
}

private final class AliasVocabularyBundleLocator: NSObject {}
