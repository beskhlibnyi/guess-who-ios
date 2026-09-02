import Foundation
import SQLite3

/// Reads the scored Ukrainian Alias deck without loading every word into memory.
enum AliasVocabulary {
    enum DifficultyLevel: CaseIterable, Hashable {
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
                return [2]
            case .medium:
                return [2, 3]
            case .hard:
                return [3, 4]
            case .expert:
                return [4]
            }
        }
    }

    static let sourceName = "mphdict Ukrainian grammatical dictionary"
    static let sourceURL = URL(string: "https://github.com/LinguisticAndInformationSystems/mphdict")!

    static func wordCount() -> Int {
        query("SELECT COUNT(*) FROM words WHERE enabled = 1") { statement in
            guard sqlite3_step(statement) == SQLITE_ROW else { return 0 }
            return Int(sqlite3_column_int(statement, 0))
        } ?? 0
    }

    static func wordCount(in level: DifficultyLevel) -> Int {
        query(
            "SELECT COUNT(*) FROM words WHERE enabled = 1 AND \(level.predicateSQL)",
            bindings: level.bounds
        ) { statement in
            guard sqlite3_step(statement) == SQLITE_ROW else { return 0 }
            return Int(sqlite3_column_int(statement, 0))
        } ?? 0
    }

    static func words(page: Int, pageSize: Int) -> [String] {
        words(
            matching: "enabled = 1",
            bindings: [],
            page: page,
            pageSize: pageSize
        )
    }

    static func words(in level: DifficultyLevel, page: Int, pageSize: Int) -> [String] {
        words(
            matching: "enabled = 1 AND \(level.predicateSQL)",
            bindings: level.bounds,
            page: page,
            pageSize: pageSize
        )
    }

    private static func words(
        matching predicateSQL: String,
        bindings: [Double],
        page: Int,
        pageSize: Int
    ) -> [String] {
        let offset = max(0, page * pageSize)
        guard let resourceURL = databaseURL else {
            return []
        }

        guard let database = openDatabase(at: resourceURL) else {
            return []
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        let sql = "SELECT word FROM words WHERE \(predicateSQL) ORDER BY word LIMIT ? OFFSET ?"
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }

        for (index, bound) in bindings.enumerated() {
            sqlite3_bind_double(statement, Int32(index + 1), bound)
        }
        let paginationIndex = Int32(bindings.count + 1)
        sqlite3_bind_int(statement, paginationIndex, Int32(pageSize))
        sqlite3_bind_int(statement, paginationIndex + 1, Int32(offset))

        var words: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW,
              let value = sqlite3_column_text(statement, 0) {
            words.append(String(cString: value))
        }
        return words
    }

    private static func query<T>(
        _ sql: String,
        bindings: [Double] = [],
        transform: (OpaquePointer) -> T
    ) -> T? {
        guard let resourceURL = databaseURL else {
            return nil
        }

        guard let database = openDatabase(at: resourceURL) else {
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

    /// Canvas runs in a host process, so its main bundle may not be the app bundle.
    private static var databaseURL: URL? {
        let bundles = [
            Bundle.main,
            Bundle(for: AliasVocabularyBundleLocator.self)
        ] + Bundle.allBundles + Bundle.allFrameworks

        return bundles.lazy
            .compactMap { $0.url(forResource: "alias_uk_words", withExtension: "sqlite") }
            .first
    }

    private static func openDatabase(at resourceURL: URL) -> OpaquePointer? {
        var database: OpaquePointer?
        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_URI
        let uri = resourceURL.absoluteString + "?immutable=1"

        guard sqlite3_open_v2(uri, &database, flags, nil) == SQLITE_OK,
              let database else {
            if let database {
                sqlite3_close(database)
            }
            return nil
        }

        return database
    }
}

private final class AliasVocabularyBundleLocator: NSObject {}
