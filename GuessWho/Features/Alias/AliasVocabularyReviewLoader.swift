import Foundation

/// Serializes deck reads and writes away from the UI and its presentation animations.
enum AliasVocabularyReviewLoader {
    struct Request: Equatable, Sendable {
        let level: AliasVocabulary.DifficultyLevel
        let approvedPage: Int
        let discardedPage: Int
        let pageSize: Int
        let basketPageSize: Int
        let shuffleSeed: Int64
        let includeAdjectives: Bool
    }

    struct Snapshot: Sendable {
        let statistics: [AliasVocabulary.DifficultyLevel: AliasVocabulary.Statistics]
        let approvedPage: Int
        let discardedPage: Int
        let words: [AliasVocabulary.Word]
        let approvedWords: [AliasVocabulary.Word]
        let discardedWords: [AliasVocabulary.Word]
    }

    enum Change: Sendable {
        case reveal(Int64, Bool)
        case review(Int64, AliasVocabulary.Decision)
        case returnToReview(Int64)

        fileprivate func apply() {
            switch self {
            case let .reveal(id, isRevealed):
                AliasVocabulary.setWordRevealed(id: id, isRevealed: isRevealed)
            case let .review(id, decision):
                AliasVocabulary.reviewWord(id: id, decision: decision)
            case let .returnToReview(id):
                AliasVocabulary.returnWordToReview(id: id)
            }
        }
    }

    private static let queue = DispatchQueue(label: "AliasVocabulary.review", qos: .userInitiated)

    static func load(
        _ request: Request,
        applying change: Change? = nil,
        completion: @escaping @MainActor @Sendable (Snapshot) -> Void
    ) {
        // Enqueue synchronously so rapid reveal/review gestures retain their order.
        queue.async {
            change?.apply()
            let snapshot = snapshot(for: request)
            DispatchQueue.main.async { completion(snapshot) }
        }
    }

    private static func snapshot(for request: Request) -> Snapshot {
        let statistics = AliasVocabulary.statisticsByDifficulty(includeAdjectives: request.includeAdjectives)
        let selected = statistics[request.level] ?? .zero
        let approvedPage = min(request.approvedPage, max(0, (selected.approved - 1) / request.basketPageSize))
        let discardedPage = min(request.discardedPage, max(0, (selected.discarded - 1) / request.basketPageSize))

        return Snapshot(
            statistics: statistics,
            approvedPage: approvedPage,
            discardedPage: discardedPage,
            words: AliasVocabulary.words(
                in: request.level, page: 0, pageSize: request.pageSize,
                shuffleSeed: request.shuffleSeed, includeAdjectives: request.includeAdjectives
            ),
            approvedWords: AliasVocabulary.reviewedWords(
                in: request.level, decision: .approved, page: approvedPage,
                pageSize: request.basketPageSize, includeAdjectives: request.includeAdjectives
            ),
            discardedWords: AliasVocabulary.reviewedWords(
                in: request.level, decision: .discarded, page: discardedPage,
                pageSize: request.basketPageSize, includeAdjectives: request.includeAdjectives
            )
        )
    }
}
