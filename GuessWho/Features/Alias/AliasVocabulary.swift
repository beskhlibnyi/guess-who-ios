import Foundation
import SQLite3

/// Reads the scored Ukrainian Alias deck without loading every word into memory.
enum AliasVocabulary {
    static let sourceName = "mphdict Ukrainian grammatical dictionary"
    static let sourceURL = URL(string: "https://github.com/LinguisticAndInformationSystems/mphdict")!

    static func wordCount() -> Int {
        query("SELECT COUNT(*) FROM words WHERE enabled = 1") { statement in
            guard sqlite3_step(statement) == SQLITE_ROW else { return 0 }
            return Int(sqlite3_column_int(statement, 0))
        } ?? 0
    }

    static func words(page: Int, pageSize: Int) -> [String] {
        let offset = max(0, page * pageSize)
        guard let resourceURL = Bundle.main.url(
            forResource: "alias_uk_words",
            withExtension: "sqlite"
        ) else {
            return []
        }

        var database: OpaquePointer?
        guard sqlite3_open_v2(resourceURL.path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK,
              let database else {
            return []
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        let sql = "SELECT word FROM words WHERE enabled = 1 ORDER BY word LIMIT ? OFFSET ?"
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return []
        }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_int(statement, 1, Int32(pageSize))
        sqlite3_bind_int(statement, 2, Int32(offset))

        var words: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW,
              let value = sqlite3_column_text(statement, 0) {
            words.append(String(cString: value))
        }
        return words
    }

    private static func query<T>(
        _ sql: String,
        transform: (OpaquePointer) -> T
    ) -> T? {
        guard let resourceURL = Bundle.main.url(forResource: "alias_uk_words", withExtension: "sqlite") else {
            return nil
        }

        var database: OpaquePointer?
        guard sqlite3_open_v2(resourceURL.path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK,
              let database else {
            return nil
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return nil
        }
        defer { sqlite3_finalize(statement) }

        return transform(statement)
    }
}
