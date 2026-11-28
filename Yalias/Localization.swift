import Foundation

let aliasLanguageOverrideKey = "homeLanguageOverride"
let aliasPlayerOneNameKey = "playerOneName"
let aliasPlayerTwoNameKey = "playerTwoName"

enum AliasLanguage: String {
    case english = "en"
    case ukrainian = "uk"

    static var active: AliasLanguage {
        resolved(override: UserDefaults.standard.string(forKey: aliasLanguageOverrideKey))
    }

    static func resolved(
        override: String?,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> AliasLanguage {
        if let override, let language = AliasLanguage(rawValue: override) {
            return language
        }

        if preferredLanguages.first?.hasPrefix(AliasLanguage.ukrainian.rawValue) == true {
            return .ukrainian
        }

        return .english
    }

    var bundle: Bundle {
        Bundle.aliasResources.localizedBundle(for: self)
    }

    var localeIdentifier: String {
        switch self {
        case .english:
            return "en_US"
        case .ukrainian:
            return "uk_UA"
        }
    }

    var locale: Locale {
        Locale(identifier: localeIdentifier)
    }
}

private final class AliasBundleToken {}

extension Bundle {
    static var aliasResources: Bundle {
        Bundle(for: AliasBundleToken.self)
    }

    func localizedBundle(for language: AliasLanguage) -> Bundle {
        guard
            let path = path(forResource: language.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return self
        }

        return bundle
    }
}

struct AliasLocalizedString {
    let key: StaticString
    let defaultValue: String.LocalizationValue
    let comment: StaticString

    init(
        _ key: StaticString,
        defaultValue: String.LocalizationValue,
        comment: StaticString = ""
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.comment = comment
    }

    func localized(in language: AliasLanguage = .active) -> String {
        String(
            localized: key,
            defaultValue: defaultValue,
            bundle: language.bundle,
            locale: language.locale,
            comment: comment
        )
    }

    func localizedFormat(
        in language: AliasLanguage = .active,
        _ arguments: [CVarArg]
    ) -> String {
        let format = localized(in: language)
        return String(format: format, locale: language.locale, arguments: arguments)
    }
}

enum AliasLocalizationCatalog {
    static let stringsByKey: [String: AliasLocalizedString] = [
        "alias.explanation.action": AliasLocalizedString("alias.explanation.action", defaultValue: "Explain word"),
        "alias.explanation.title": AliasLocalizedString("alias.explanation.title", defaultValue: "Word meaning"),
        "alias.explanation.loading": AliasLocalizedString("alias.explanation.loading", defaultValue: "Finding an explanation…"),
        "alias.explanation.resume_countdown": AliasLocalizedString("alias.explanation.resume_countdown", defaultValue: "Game resumes in %d sec"),
        "alias.explanation.retry": AliasLocalizedString("alias.explanation.retry", defaultValue: "Try again"),
        "alias.explanation.note": AliasLocalizedString("alias.explanation.note", defaultValue: "AI-generated explanation in Ukrainian. It may contain mistakes."),
        "alias.explanation.missing_key": AliasLocalizedString("alias.explanation.missing_key", defaultValue: "Word explanations are not configured for this app build."),
        "alias.explanation.unauthorized": AliasLocalizedString("alias.explanation.unauthorized", defaultValue: "The API key was rejected or does not have access. Check the app’s API configuration."),
        "alias.explanation.rate_limited": AliasLocalizedString("alias.explanation.rate_limited", defaultValue: "The API limit was reached. Try later or check your API balance."),
        "alias.explanation.unavailable": AliasLocalizedString("alias.explanation.unavailable", defaultValue: "Explanations are unavailable right now. Please try again later."),
        "alias.explanation.invalid_response": AliasLocalizedString("alias.explanation.invalid_response", defaultValue: "No complete explanation was returned. Please try again."),
        "alias.explanation.network_error": AliasLocalizedString("alias.explanation.network_error", defaultValue: "Could not connect. Check your internet connection and try again."),
        "common.cancel": AliasLocalizedString("common.cancel", defaultValue: "Cancel"),
        "common.done": AliasLocalizedString("common.done", defaultValue: "Done"),
        "player.one": AliasLocalizedString("player.one", defaultValue: "Player 1"),
        "player.two": AliasLocalizedString("player.two", defaultValue: "Player 2"),
        "settings.language.label": AliasLocalizedString("settings.language.label", defaultValue: "Language"),
        "settings.language.english": AliasLocalizedString("settings.language.english", defaultValue: "English"),
        "settings.language.ukrainian": AliasLocalizedString("settings.language.ukrainian", defaultValue: "Ukrainian"),
        "settings.title": AliasLocalizedString("settings.title", defaultValue: "Settings"),
        "settings.open": AliasLocalizedString("settings.open", defaultValue: "Open settings"),
        "settings.close": AliasLocalizedString("settings.close", defaultValue: "Close settings"),
        "settings.players.title": AliasLocalizedString("settings.players.title", defaultValue: "Players"),
        "settings.player.placeholder": AliasLocalizedString("settings.player.placeholder", defaultValue: "Enter a name"),
        "app.title": AliasLocalizedString("app.title", defaultValue: "YALIAS"),
        "alias.vocabulary_review.title": AliasLocalizedString("alias.vocabulary_review.title", defaultValue: "Review words"),
        "alias.menu.mode": AliasLocalizedString("alias.menu.mode", defaultValue: "Game mode"),
        "alias.menu.mode.classic": AliasLocalizedString("alias.menu.mode.classic", defaultValue: "Classic"),
        "alias.menu.mode.fastest": AliasLocalizedString("alias.menu.mode.fastest", defaultValue: "Fast"),
        "alias.menu.goal": AliasLocalizedString("alias.menu.goal", defaultValue: "Goal"),
        "alias.menu.goal.option": AliasLocalizedString("alias.menu.goal.option", defaultValue: "%d points"),
        "alias.menu.time": AliasLocalizedString("alias.menu.time", defaultValue: "Turn time"),
        "alias.menu.time.option": AliasLocalizedString("alias.menu.time.option", defaultValue: "%d sec"),
        "alias.menu.groups": AliasLocalizedString("alias.menu.groups", defaultValue: "Word groups"),
        "alias.menu.new_match": AliasLocalizedString("alias.menu.new_match", defaultValue: "New Match"),
        "alias.menu.start_game": AliasLocalizedString("alias.menu.start_game", defaultValue: "Start game"),
        "alias.menu.resume": AliasLocalizedString("alias.menu.resume", defaultValue: "Resume Match"),
        "alias.menu.alert.title": AliasLocalizedString("alias.menu.alert.title", defaultValue: "Start a new match?"),
        "alias.menu.alert.message": AliasLocalizedString("alias.menu.alert.message", defaultValue: "The current YALIAS match will be cleared."),
        "alias.game.empty.title": AliasLocalizedString("alias.game.empty.title", defaultValue: "No active match"),
        "alias.game.empty.message": AliasLocalizedString("alias.game.empty.message", defaultValue: "Return to the YALIAS menu to start one."),
        "alias.game.loading.title": AliasLocalizedString("alias.game.loading.title", defaultValue: "Shuffling words"),
        "alias.game.handoff.title": AliasLocalizedString("alias.game.handoff.title", defaultValue: "Pass the phone to %@"),
        "alias.game.handoff.message": AliasLocalizedString("alias.game.handoff.message", defaultValue: "Only %@ should see the next word."),
        "alias.game.handoff.cta": AliasLocalizedString("alias.game.handoff.cta", defaultValue: "I’m %@, start"),
        "alias.game.handoff.rules.title": AliasLocalizedString("alias.game.handoff.rules.title", defaultValue: "%@, explain the word and follow these rules:"),
        "alias.game.handoff.rules.no_word": AliasLocalizedString("alias.game.handoff.rules.no_word", defaultValue: "Do not say the word itself."),
        "alias.game.handoff.rules.guessed": AliasLocalizedString("alias.game.handoff.rules.guessed", defaultValue: "Swipe up when the word is guessed."),
        "alias.game.handoff.rules.skipped": AliasLocalizedString("alias.game.handoff.rules.skipped", defaultValue: "Swipe down to skip it."),
        "alias.game.timer.accessibility": AliasLocalizedString("alias.game.timer.accessibility", defaultValue: "%d seconds remaining"),
        "alias.game.timer.elapsed.accessibility": AliasLocalizedString("alias.game.timer.elapsed.accessibility", defaultValue: "%d seconds elapsed"),
        "alias.game.pause": AliasLocalizedString("alias.game.pause", defaultValue: "Pause"),
        "alias.game.paused": AliasLocalizedString("alias.game.paused", defaultValue: "Paused"),
        "alias.game.resume": AliasLocalizedString("alias.game.resume", defaultValue: "Resume"),
        "alias.game.skip": AliasLocalizedString("alias.game.skip", defaultValue: "Skip −1"),
        "alias.game.correct": AliasLocalizedString("alias.game.correct", defaultValue: "Correct +1"),
        "alias.game.swipe.hint": AliasLocalizedString("alias.game.swipe.hint", defaultValue: "Swipe up if guessed or down to skip."),
        "alias.game.stack.guessed": AliasLocalizedString("alias.game.stack.guessed", defaultValue: "Guessed!"),
        "alias.game.stack.skip": AliasLocalizedString("alias.game.stack.skip", defaultValue: "Skip"),
        "alias.game.exclude": AliasLocalizedString("alias.game.exclude", defaultValue: "Exclude word"),
        "alias.game.exclude.error.title": AliasLocalizedString("alias.game.exclude.error.title", defaultValue: "Couldn’t update word"),
        "alias.game.exclude.error.message": AliasLocalizedString("alias.game.exclude.error.message", defaultValue: "The word was not updated. Please try again."),
        "alias.game.result.completed": AliasLocalizedString("alias.game.result.completed", defaultValue: "Turn complete"),
        "alias.game.result.summary_score": AliasLocalizedString("alias.game.result.summary_score", defaultValue: "Result %@"),
        "alias.game.result.summary_time": AliasLocalizedString("alias.game.result.summary_time", defaultValue: "Time %@"),
        "alias.game.result.continue": AliasLocalizedString("alias.game.result.continue", defaultValue: "Continue"),
        "alias.game.review.title": AliasLocalizedString("alias.game.review.title", defaultValue: "Review words"),
        "alias.game.review.empty": AliasLocalizedString("alias.game.review.empty", defaultValue: "No words were completed this turn."),
        "alias.game.review.guessed": AliasLocalizedString("alias.game.review.guessed", defaultValue: "Guessed"),
        "alias.game.review.skipped": AliasLocalizedString("alias.game.review.skipped", defaultValue: "Skipped"),
        "alias.game.review.declined": AliasLocalizedString("alias.game.review.declined", defaultValue: "Excluded"),
        "alias.game.review.resume": AliasLocalizedString("alias.game.review.resume", defaultValue: "Resume turn"),
        "alias.game.over.title": AliasLocalizedString("alias.game.over.title", defaultValue: "%@ wins"),
        "alias.game.over.final_score": AliasLocalizedString("alias.game.over.final_score", defaultValue: "Final score"),
        "alias.game.over.final_time": AliasLocalizedString("alias.game.over.final_time", defaultValue: "Final time"),
        "alias.game.over.rematch": AliasLocalizedString("alias.game.over.rematch", defaultValue: "Play again"),
        "alias.game.over.main_menu": AliasLocalizedString("alias.game.over.main_menu", defaultValue: "Main menu"),
        "alias.game.deck_error.title": AliasLocalizedString("alias.game.deck_error.title", defaultValue: "Words unavailable"),
        "alias.game.deck_error.message": AliasLocalizedString("alias.game.deck_error.message", defaultValue: "The offline word deck could not be loaded."),
        "alias.game.goal": AliasLocalizedString("alias.game.goal", defaultValue: "Goal"),
        "alias.statistics.of_total": AliasLocalizedString("alias.statistics.of_total", defaultValue: "%@ of total"),
        "alias.statistics.of_revealed": AliasLocalizedString("alias.statistics.of_revealed", defaultValue: "%@ of revealed"),
        "alias.statistics.unavailable": AliasLocalizedString("alias.statistics.unavailable", defaultValue: "No words in the previous stage"),
        "alias.statistics.title": AliasLocalizedString("alias.statistics.title", defaultValue: "Deck statistics"),
        "alias.statistics.other_difficulties": AliasLocalizedString("alias.statistics.other_difficulties", defaultValue: "Other difficulty levels"),
        "alias.statistics.total": AliasLocalizedString("alias.statistics.total", defaultValue: "Total"),
        "alias.statistics.revealed": AliasLocalizedString("alias.statistics.revealed", defaultValue: "Revealed"),
        "alias.statistics.approved": AliasLocalizedString("alias.statistics.approved", defaultValue: "Approved"),
        "alias.statistics.discarded": AliasLocalizedString("alias.statistics.discarded", defaultValue: "Discarded"),
        "alias.filter.adjectives": AliasLocalizedString("alias.filter.adjectives", defaultValue: "Include adjectives"),
        "alias.filter.adjectives.message": AliasLocalizedString("alias.filter.adjectives.message", defaultValue: "Nouns are always included."),
        "alias.vocabulary_review.approved": AliasLocalizedString("alias.vocabulary_review.approved", defaultValue: "%d approved"),
        "alias.vocabulary_review.discarded": AliasLocalizedString("alias.vocabulary_review.discarded", defaultValue: "%d discarded"),
        "alias.vocabulary_review.basket.empty": AliasLocalizedString("alias.vocabulary_review.basket.empty", defaultValue: "No words here yet."),
        "alias.vocabulary_review.move_to_approved": AliasLocalizedString("alias.vocabulary_review.move_to_approved", defaultValue: "Move to approved"),
        "alias.vocabulary_review.move_to_discarded": AliasLocalizedString("alias.vocabulary_review.move_to_discarded", defaultValue: "Move to discarded"),
        "alias.vocabulary_review.return_to_review": AliasLocalizedString("alias.vocabulary_review.return_to_review", defaultValue: "Return to review"),
        "alias.vocabulary_review.review_complete": AliasLocalizedString("alias.vocabulary_review.review_complete", defaultValue: "All words in this level have been reviewed."),
        "alias.vocabulary_review.reveal": AliasLocalizedString("alias.vocabulary_review.reveal", defaultValue: "Tap to reveal"),
        "alias.vocabulary_review.hide": AliasLocalizedString("alias.vocabulary_review.hide", defaultValue: "Tap to hide"),
        "alias.vocabulary_review.hidden": AliasLocalizedString("alias.vocabulary_review.hidden", defaultValue: "Hidden word"),
        "alias.vocabulary_review.modal_hint": AliasLocalizedString("alias.vocabulary_review.modal_hint", defaultValue: "Swipe up to approve or down to discard."),
        "alias.vocabulary_review.close": AliasLocalizedString("alias.vocabulary_review.close", defaultValue: "Close"),
        "alias.vocabulary_review.approve": AliasLocalizedString("alias.vocabulary_review.approve", defaultValue: "Approve"),
        "alias.vocabulary_review.discard": AliasLocalizedString("alias.vocabulary_review.discard", defaultValue: "Discard"),
        "alias.vocabulary_review.level.easy": AliasLocalizedString("alias.vocabulary_review.level.easy", defaultValue: "Easy"),
        "alias.vocabulary_review.level.medium": AliasLocalizedString("alias.vocabulary_review.level.medium", defaultValue: "Medium"),
        "alias.vocabulary_review.level.hard": AliasLocalizedString("alias.vocabulary_review.level.hard", defaultValue: "Hard"),
        "alias.vocabulary_review.level.expert": AliasLocalizedString("alias.vocabulary_review.level.expert", defaultValue: "Expert"),
        "alias.vocabulary_review.previous": AliasLocalizedString("alias.vocabulary_review.previous", defaultValue: "Previous"),
        "alias.vocabulary_review.next": AliasLocalizedString("alias.vocabulary_review.next", defaultValue: "Next"),
        "common.menu": AliasLocalizedString("common.menu", defaultValue: "Menu"),
        "common.back": AliasLocalizedString("common.back", defaultValue: "Back"),
        "common.ok": AliasLocalizedString("common.ok", defaultValue: "OK")
    ]
}

func aliasLocalized(_ key: String, fallback: String) -> String {
    aliasLocalized(key, fallback: fallback, language: AliasLanguage.active)
}

func aliasLocalized(_ key: String, fallback: String, language: AliasLanguage) -> String {
    guard let localizedString = AliasLocalizationCatalog.stringsByKey[key] else {
        assertionFailure("Missing localized resource registration for \(key)")
        return language.bundle.localizedString(forKey: key, value: fallback, table: nil)
    }

    return localizedString.localized(in: language)
}

func aliasLocalizedFormat(_ key: String, fallback: String, _ arguments: CVarArg...) -> String {
    aliasLocalizedFormat(key, fallback: fallback, language: AliasLanguage.active, arguments)
}

func aliasLocalizedFormat(
    _ key: String,
    fallback: String,
    language: AliasLanguage,
    _ arguments: CVarArg...
) -> String {
    aliasLocalizedFormat(key, fallback: fallback, language: language, arguments)
}

func aliasLocalizedFormat(
    _ key: String,
    fallback: String,
    language: AliasLanguage,
    _ arguments: [CVarArg]
) -> String {
    guard let localizedString = AliasLocalizationCatalog.stringsByKey[key] else {
        assertionFailure("Missing localized resource registration for \(key)")
        let format = language.bundle.localizedString(forKey: key, value: fallback, table: nil)
        return String(format: format, locale: language.locale, arguments: arguments)
    }

    return localizedString.localizedFormat(in: language, arguments)
}
