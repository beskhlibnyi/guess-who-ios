import Foundation

let guessWhoLanguageOverrideKey = "homeLanguageOverride"
let guessWhoPlayerOneNameKey = "playerOneName"
let guessWhoPlayerTwoNameKey = "playerTwoName"

enum GuessWhoLanguage: String, CaseIterable {
    case english = "en"
    case ukrainian = "uk"

    static var active: GuessWhoLanguage {
        resolved(override: UserDefaults.standard.string(forKey: guessWhoLanguageOverrideKey))
    }

    static func resolved(
        override: String?,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> GuessWhoLanguage {
        if let override, let language = GuessWhoLanguage(rawValue: override) {
            return language
        }

        if preferredLanguages.first?.hasPrefix(GuessWhoLanguage.ukrainian.rawValue) == true {
            return .ukrainian
        }

        return .english
    }

    var bundle: Bundle {
        Bundle.guessWhoResources.localizedBundle(for: self)
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

private final class GuessWhoBundleToken {}

extension Bundle {
    static var guessWhoResources: Bundle {
        Bundle(for: GuessWhoBundleToken.self)
    }

    func localizedBundle(for language: GuessWhoLanguage) -> Bundle {
        guard
            let path = path(forResource: language.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return self
        }

        return bundle
    }
}

struct GuessWhoLocalizedString {
    let key: StaticString
    let defaultValue: String.LocalizationValue
    let comment: StaticString

    var identifier: String {
        String(describing: key)
    }

    init(
        _ key: StaticString,
        defaultValue: String.LocalizationValue,
        comment: StaticString = ""
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.comment = comment
    }

    func localized(in language: GuessWhoLanguage = .active) -> String {
        String(
            localized: key,
            defaultValue: defaultValue,
            bundle: language.bundle,
            locale: language.locale,
            comment: comment
        )
    }

    func localizedFormat(
        in language: GuessWhoLanguage = .active,
        _ arguments: [CVarArg]
    ) -> String {
        let format = localized(in: language)
        return String(format: format, locale: language.locale, arguments: arguments)
    }
}

enum GuessWhoLocalizationCatalog {
    static let stringsByKey: [String: GuessWhoLocalizedString] = [
        "home.alert.title": GuessWhoLocalizedString("home.alert.title", defaultValue: "Start over?"),
        "home.alert.cancel": GuessWhoLocalizedString("home.alert.cancel", defaultValue: "Cancel"),
        "home.alert.confirm": GuessWhoLocalizedString("home.alert.confirm", defaultValue: "New Game"),
        "home.alert.message": GuessWhoLocalizedString("home.alert.message", defaultValue: "Your current game will be cleared."),
        "home.title": GuessWhoLocalizedString("home.title", defaultValue: "НТО"),
        "home.overview": GuessWhoLocalizedString("home.overview", defaultValue: "Two players. One iPhone."),
        "home.summary": GuessWhoLocalizedString("home.summary", defaultValue: "Pick a secret. Ask yes-or-no questions. Make your guess."),
        "home.start": GuessWhoLocalizedString("home.start", defaultValue: "New Game"),
        "home.resume": GuessWhoLocalizedString("home.resume", defaultValue: "Resume Game"),
        "home.players.title": GuessWhoLocalizedString("home.players.title", defaultValue: "Name your players"),
        "home.players.message": GuessWhoLocalizedString("home.players.message", defaultValue: "Add names for each side, or leave them blank to keep the default labels."),
        "home.players.placeholder": GuessWhoLocalizedString("home.players.placeholder", defaultValue: "Enter a name"),
        "home.players.back": GuessWhoLocalizedString("home.players.back", defaultValue: "Back"),
        "home.players.start": GuessWhoLocalizedString("home.players.start", defaultValue: "Start Game"),
        "home.rules": GuessWhoLocalizedString("home.rules", defaultValue: "How to Play"),
        "home.live_round.title": GuessWhoLocalizedString("home.live_round.title", defaultValue: "Game in progress"),
        "home.live_round.message": GuessWhoLocalizedString("home.live_round.message", defaultValue: "%@ secrets picked. Jump back in."),
        "home.player.one": GuessWhoLocalizedString("home.player.one", defaultValue: "Player 1"),
        "home.player.two": GuessWhoLocalizedString("home.player.two", defaultValue: "Player 2"),
        "home.language.label": GuessWhoLocalizedString("home.language.label", defaultValue: "Language"),
        "home.language.english": GuessWhoLocalizedString("home.language.english", defaultValue: "English"),
        "home.language.ukrainian": GuessWhoLocalizedString("home.language.ukrainian", defaultValue: "Ukrainian"),
        "home.games": GuessWhoLocalizedString("home.games", defaultValue: "Games"),
        "home.footer": GuessWhoLocalizedString("home.footer", defaultValue: "© 2026 НТО"),
        "launcher.title": GuessWhoLocalizedString("launcher.title", defaultValue: "Choose a game"),
        "launcher.subtitle": GuessWhoLocalizedString("launcher.subtitle", defaultValue: "Start with the live game now and leave room for the next one."),
        "launcher.open": GuessWhoLocalizedString("launcher.open", defaultValue: "Open"),
        "launcher.available": GuessWhoLocalizedString("launcher.available", defaultValue: "Ready to play"),
        "launcher.coming_soon": GuessWhoLocalizedString("launcher.coming_soon", defaultValue: "Coming soon"),
        "launcher.in_progress": GuessWhoLocalizedString("launcher.in_progress", defaultValue: "Round in progress"),
        "game.guesswho.title": GuessWhoLocalizedString("game.guesswho.title", defaultValue: "НТО"),
        "game.guesswho.description": GuessWhoLocalizedString("game.guesswho.description", defaultValue: "Classic two-player face guessing on one iPhone."),
        "game.next.title": GuessWhoLocalizedString("game.next.title", defaultValue: "Next Game"),
        "game.next.description": GuessWhoLocalizedString("game.next.description", defaultValue: "Reserved for the next board, rules, and art set."),
        "rules.title": GuessWhoLocalizedString("rules.title", defaultValue: "How to Play"),
        "rules.subtitle": GuessWhoLocalizedString("rules.subtitle", defaultValue: "Choose in secret, pass the phone, and narrow the board with yes-or-no questions."),
        "rules.badge": GuessWhoLocalizedString("rules.badge", defaultValue: "Quick Guide"),
        "rules.home": GuessWhoLocalizedString("rules.home", defaultValue: "Home"),
        "rules.flow.title": GuessWhoLocalizedString("rules.flow.title", defaultValue: "Round flow"),
        "rules.flow.message": GuessWhoLocalizedString("rules.flow.message", defaultValue: "Both secret picks happen first. Then every turn follows the same rhythm: ask, answer, eliminate, pass."),
        "rules.quick.players.title": GuessWhoLocalizedString("rules.quick.players.title", defaultValue: "Players"),
        "rules.quick.players.value": GuessWhoLocalizedString("rules.quick.players.value", defaultValue: "2"),
        "rules.quick.setup.title": GuessWhoLocalizedString("rules.quick.setup.title", defaultValue: "Setup"),
        "rules.quick.setup.value": GuessWhoLocalizedString("rules.quick.setup.value", defaultValue: "1 iPhone"),
        "rules.quick.goal.title": GuessWhoLocalizedString("rules.quick.goal.title", defaultValue: "Goal"),
        "rules.quick.goal.value": GuessWhoLocalizedString("rules.quick.goal.value", defaultValue: "Find the secret face"),
        "rules.step1.title": GuessWhoLocalizedString("rules.step1.title", defaultValue: "Pick in private"),
        "rules.step1.message": GuessWhoLocalizedString("rules.step1.message", defaultValue: "%@ picks a secret first. Then %@ picks one without revealing it."),
        "rules.step2.title": GuessWhoLocalizedString("rules.step2.title", defaultValue: "Ask or guess"),
        "rules.step2.message": GuessWhoLocalizedString("rules.step2.message", defaultValue: "On your turn, either ask one yes-or-no question or make a guess."),
        "rules.step3.title": GuessWhoLocalizedString("rules.step3.title", defaultValue: "Answer first"),
        "rules.step3.message": GuessWhoLocalizedString("rules.step3.message", defaultValue: "Only update the board after the other player answers Yes or No."),
        "rules.step4.title": GuessWhoLocalizedString("rules.step4.title", defaultValue: "Guess to win"),
        "rules.step4.message": GuessWhoLocalizedString("rules.step4.message", defaultValue: "Even with one face left, you still need to make the final guess."),
        "rules.tip.title": GuessWhoLocalizedString("rules.tip.title", defaultValue: "Winning move"),
        "rules.tip.message": GuessWhoLocalizedString("rules.tip.message", defaultValue: "Seeing one face left is not enough. You still have to enter Guess mode and name that character."),
        "common.menu": GuessWhoLocalizedString("common.menu", defaultValue: "Menu"),
        "common.back": GuessWhoLocalizedString("common.back", defaultValue: "Back"),
        "common.yes": GuessWhoLocalizedString("common.yes", defaultValue: "Yes"),
        "common.no": GuessWhoLocalizedString("common.no", defaultValue: "No"),
        "notes.title": GuessWhoLocalizedString("notes.title", defaultValue: "Notes"),
        "notes.message": GuessWhoLocalizedString("notes.message", defaultValue: "One question per step."),
        "notes.empty": GuessWhoLocalizedString("notes.empty", defaultValue: "Your saved steps will appear here."),
        "notes.question.placeholder": GuessWhoLocalizedString("notes.question.placeholder", defaultValue: "Asked question"),
        "notes.step.title": GuessWhoLocalizedString("notes.step.title", defaultValue: "Step %d"),
        "common.player": GuessWhoLocalizedString("common.player", defaultValue: "Player"),
        "common.left": GuessWhoLocalizedString("common.left", defaultValue: "Left"),
        "common.out": GuessWhoLocalizedString("common.out", defaultValue: "Out"),
        "common.suspects_left": GuessWhoLocalizedString("common.suspects_left", defaultValue: "Left"),
        "common.eliminated": GuessWhoLocalizedString("common.eliminated", defaultValue: "Eliminated"),
        "common.unknown": GuessWhoLocalizedString("common.unknown", defaultValue: "Unknown"),
        "screen.secret.label": GuessWhoLocalizedString("screen.secret.label", defaultValue: "Private Pick"),
        "screen.secret.notice.title": GuessWhoLocalizedString("screen.secret.notice.title", defaultValue: "%@ only"),
        "screen.secret.notice.message": GuessWhoLocalizedString("screen.secret.notice.message", defaultValue: "Make your pick in private."),
        "screen.secret.title": GuessWhoLocalizedString("screen.secret.title", defaultValue: "%@, pick your secret"),
        "screen.secret.message": GuessWhoLocalizedString("screen.secret.message", defaultValue: "Tap one face."),
        "screen.handoff.title": GuessWhoLocalizedString("screen.handoff.title", defaultValue: "Pass the phone to %@"),
        "screen.handoff.message": GuessWhoLocalizedString("screen.handoff.message", defaultValue: "%@, tap below when you are ready."),
        "screen.handoff.cta": GuessWhoLocalizedString("screen.handoff.cta", defaultValue: "I am %@"),
        "screen.turn.label": GuessWhoLocalizedString("screen.turn.label", defaultValue: "Your Turn"),
        "screen.turn.title": GuessWhoLocalizedString("screen.turn.title", defaultValue: "%@, make your move"),
        "screen.turn.title.final": GuessWhoLocalizedString("screen.turn.title.final", defaultValue: "%@, your call"),
        "screen.turn.message": GuessWhoLocalizedString("screen.turn.message", defaultValue: "Ask a question or make a guess."),
        "screen.turn.message.final": GuessWhoLocalizedString("screen.turn.message.final", defaultValue: "One face left. Ask one more question or make the final guess."),
        "screen.turn.ask.title": GuessWhoLocalizedString("screen.turn.ask.title", defaultValue: "Ask a Question"),
        "screen.turn.ask.subtitle": GuessWhoLocalizedString("screen.turn.ask.subtitle", defaultValue: "Question"),
        "screen.turn.ask.message": GuessWhoLocalizedString("screen.turn.ask.message", defaultValue: "Ask it out loud. Then record the answer."),
        "screen.turn.ask.consequence": GuessWhoLocalizedString("screen.turn.ask.consequence", defaultValue: "You can cross off faces after Yes or No."),
        "screen.turn.ask.cta": GuessWhoLocalizedString("screen.turn.ask.cta", defaultValue: "Ask a Question"),
        "screen.turn.guess.title": GuessWhoLocalizedString("screen.turn.guess.title", defaultValue: "Make a Guess"),
        "screen.turn.guess.final_title": GuessWhoLocalizedString("screen.turn.guess.final_title", defaultValue: "Make the final guess"),
        "screen.turn.guess.subtitle": GuessWhoLocalizedString("screen.turn.guess.subtitle", defaultValue: "Guess"),
        "screen.turn.guess.message": GuessWhoLocalizedString("screen.turn.guess.message", defaultValue: "Open guess mode, then tap one face."),
        "screen.turn.guess.final_message": GuessWhoLocalizedString("screen.turn.guess.final_message", defaultValue: "One face left. Make the final guess."),
        "screen.turn.guess.consequence": GuessWhoLocalizedString("screen.turn.guess.consequence", defaultValue: "A wrong guess ends your turn."),
        "screen.turn.guess.cta": GuessWhoLocalizedString("screen.turn.guess.cta", defaultValue: "Make a Guess"),
        "screen.turn.guess.final_cta": GuessWhoLocalizedString("screen.turn.guess.final_cta", defaultValue: "Make Final Guess"),
        "screen.answer.notice.title": GuessWhoLocalizedString("screen.answer.notice.title", defaultValue: "Answer first"),
        "screen.answer.notice.message": GuessWhoLocalizedString("screen.answer.notice.message", defaultValue: "Wait for the answer before you touch the board."),
        "screen.answer.label": GuessWhoLocalizedString("screen.answer.label", defaultValue: "Ask"),
        "screen.answer.title": GuessWhoLocalizedString("screen.answer.title", defaultValue: "%@, ask your question"),
        "screen.answer.instruction": GuessWhoLocalizedString("screen.answer.instruction", defaultValue: "Tap Yes or No after they answer."),
        "screen.elimination.yes.label": GuessWhoLocalizedString("screen.elimination.yes.label", defaultValue: "Yes"),
        "screen.elimination.no.label": GuessWhoLocalizedString("screen.elimination.no.label", defaultValue: "No"),
        "screen.elimination.yes.title": GuessWhoLocalizedString("screen.elimination.yes.title", defaultValue: "Update the board"),
        "screen.elimination.no.title": GuessWhoLocalizedString("screen.elimination.no.title", defaultValue: "Update the board"),
        "screen.elimination.message.yes": GuessWhoLocalizedString("screen.elimination.message.yes", defaultValue: "Hide the faces that do not match Yes."),
        "screen.elimination.message.no": GuessWhoLocalizedString("screen.elimination.message.no", defaultValue: "Hide the faces that do not match No."),
        "screen.elimination.message.final": GuessWhoLocalizedString("screen.elimination.message.final", defaultValue: "One face left does not end the game."),
        "screen.elimination.reminder": GuessWhoLocalizedString("screen.elimination.reminder", defaultValue: "One face left. You still need to guess."),
        "screen.elimination.cta": GuessWhoLocalizedString("screen.elimination.cta", defaultValue: "Pass the Phone"),
        "screen.guess.label": GuessWhoLocalizedString("screen.guess.label", defaultValue: "Guess"),
        "screen.guess.title": GuessWhoLocalizedString("screen.guess.title", defaultValue: "Tap a face to guess"),
        "screen.guess.message": GuessWhoLocalizedString("screen.guess.message", defaultValue: "A wrong guess ends your turn."),
        "screen.guess.backout": GuessWhoLocalizedString("screen.guess.backout", defaultValue: "Want to ask instead?"),
        "screen.guess.back": GuessWhoLocalizedString("screen.guess.back", defaultValue: "Ask Instead"),
        "screen.result.label": GuessWhoLocalizedString("screen.result.label", defaultValue: "Round Over"),
        "screen.result.title": GuessWhoLocalizedString("screen.result.title", defaultValue: "%@ wins"),
        "screen.result.message": GuessWhoLocalizedString("screen.result.message", defaultValue: "The answer was %@."),
        "screen.result.player_secret": GuessWhoLocalizedString("screen.result.player_secret", defaultValue: "%@'s secret"),
        "screen.result.home": GuessWhoLocalizedString("screen.result.home", defaultValue: "Home"),
        "screen.result.reveal": GuessWhoLocalizedString("screen.result.reveal", defaultValue: "Secret character"),
        "screen.result.recap.title": GuessWhoLocalizedString("screen.result.recap.title", defaultValue: "Round recap"),
        "screen.result.recap.message": GuessWhoLocalizedString("screen.result.recap.message", defaultValue: "Both secrets are revealed before the next round."),
        "board.secret.title": GuessWhoLocalizedString("board.secret.title", defaultValue: "Pick a secret"),
        "board.secret.message": GuessWhoLocalizedString("board.secret.message", defaultValue: "Tap one face."),
        "board.suspect.title": GuessWhoLocalizedString("board.suspect.title", defaultValue: "Your board"),
        "board.suspect.message": GuessWhoLocalizedString("board.suspect.message", defaultValue: "Tap faces to cross them off or bring them back."),
        "board.guess.title": GuessWhoLocalizedString("board.guess.title", defaultValue: "Make your guess"),
        "board.guess.message": GuessWhoLocalizedString("board.guess.message", defaultValue: "Tap one face."),
        "board.default.title": GuessWhoLocalizedString("board.default.title", defaultValue: "Board"),
        "board.default.message": GuessWhoLocalizedString("board.default.message", defaultValue: "%@'s board."),
        "board.result.title": GuessWhoLocalizedString("board.result.title", defaultValue: "Final board"),
        "board.result.message": GuessWhoLocalizedString("board.result.message", defaultValue: "The winning board at the end of the round."),
        "board.count": GuessWhoLocalizedString("board.count", defaultValue: "%d left"),
        "card.accessibility.eliminated": GuessWhoLocalizedString("card.accessibility.eliminated", defaultValue: "Eliminated."),
        "card.accessibility.in_play": GuessWhoLocalizedString("card.accessibility.in_play", defaultValue: "Still in play."),
        "card.hint.pick": GuessWhoLocalizedString("card.hint.pick", defaultValue: "Double tap to choose this secret character."),
        "card.hint.restore": GuessWhoLocalizedString("card.hint.restore", defaultValue: "Double tap to restore this suspect."),
        "card.hint.eliminate": GuessWhoLocalizedString("card.hint.eliminate", defaultValue: "Double tap to eliminate this suspect."),
        "card.hint.guess": GuessWhoLocalizedString("card.hint.guess", defaultValue: "Double tap to submit this as your guess."),
        "card.hint.default": GuessWhoLocalizedString("card.hint.default", defaultValue: "Character card."),
        "character.trait.glasses": GuessWhoLocalizedString("character.trait.glasses", defaultValue: "Glasses"),
        "character.trait.no_glasses": GuessWhoLocalizedString("character.trait.no_glasses", defaultValue: "No Glasses"),
        "character.trait.facial_hair": GuessWhoLocalizedString("character.trait.facial_hair", defaultValue: "Facial Hair"),
        "character.trait.clean_shaven": GuessWhoLocalizedString("character.trait.clean_shaven", defaultValue: "Clean Shaven"),
        "character.board.hair": GuessWhoLocalizedString("character.board.hair", defaultValue: "%@ %@ hair"),
        "character.board.texture": GuessWhoLocalizedString("character.board.texture", defaultValue: "%@ texture"),
        "character.board.summary": GuessWhoLocalizedString("character.board.summary", defaultValue: "%@ • %@ build"),
        "character.accessibility.hair": GuessWhoLocalizedString("character.accessibility.hair", defaultValue: "%@ %@ %@ hair"),
        "character.hair_color.brown": GuessWhoLocalizedString("character.hair_color.brown", defaultValue: "Brown"),
        "character.hair_color.black": GuessWhoLocalizedString("character.hair_color.black", defaultValue: "Black"),
        "character.hair_color.blonde": GuessWhoLocalizedString("character.hair_color.blonde", defaultValue: "Blonde"),
        "character.hair_color.red": GuessWhoLocalizedString("character.hair_color.red", defaultValue: "Red"),
        "character.accessory.beanie": GuessWhoLocalizedString("character.accessory.beanie", defaultValue: "Beanie"),
        "character.accessory.scarf": GuessWhoLocalizedString("character.accessory.scarf", defaultValue: "Scarf"),
        "character.accessory.cap": GuessWhoLocalizedString("character.accessory.cap", defaultValue: "Cap"),
        "character.accessory.earrings": GuessWhoLocalizedString("character.accessory.earrings", defaultValue: "Earrings"),
        "character.accessory.tie": GuessWhoLocalizedString("character.accessory.tie", defaultValue: "Tie"),
        "character.accessory.bow": GuessWhoLocalizedString("character.accessory.bow", defaultValue: "Bow"),
        "character.accessory.headband": GuessWhoLocalizedString("character.accessory.headband", defaultValue: "Headband"),
        "character.accessory.jacket": GuessWhoLocalizedString("character.accessory.jacket", defaultValue: "Jacket"),
        "character.accessory.watch": GuessWhoLocalizedString("character.accessory.watch", defaultValue: "Watch"),
        "character.accessory.hoodie": GuessWhoLocalizedString("character.accessory.hoodie", defaultValue: "Hoodie"),
        "character.accessory.hat": GuessWhoLocalizedString("character.accessory.hat", defaultValue: "Hat"),
        "character.accessory.vest": GuessWhoLocalizedString("character.accessory.vest", defaultValue: "Vest"),
        "character.accessory.necklace": GuessWhoLocalizedString("character.accessory.necklace", defaultValue: "Necklace"),
        "character.accessory.pins": GuessWhoLocalizedString("character.accessory.pins", defaultValue: "Pins"),
        "character.accessory.suspenders": GuessWhoLocalizedString("character.accessory.suspenders", defaultValue: "Suspenders"),
        "character.accessory.backpack": GuessWhoLocalizedString("character.accessory.backpack", defaultValue: "Backpack"),
        "character.accessory.tie_clip": GuessWhoLocalizedString("character.accessory.tie_clip", defaultValue: "Tie Clip"),
        "character.accessory.bracelet": GuessWhoLocalizedString("character.accessory.bracelet", defaultValue: "Bracelet"),
        "character.accessory.sweater": GuessWhoLocalizedString("character.accessory.sweater", defaultValue: "Sweater"),
        "character.accessory.bandana": GuessWhoLocalizedString("character.accessory.bandana", defaultValue: "Bandana"),
        "character.accessory.blazer": GuessWhoLocalizedString("character.accessory.blazer", defaultValue: "Blazer"),
        "character.accessory.collar": GuessWhoLocalizedString("character.accessory.collar", defaultValue: "Collar"),
        "character.accessory.brooch": GuessWhoLocalizedString("character.accessory.brooch", defaultValue: "Brooch"),
        "character.accessory.bow_tie": GuessWhoLocalizedString("character.accessory.bow_tie", defaultValue: "Bow Tie"),
        "character.build.slim": GuessWhoLocalizedString("character.build.slim", defaultValue: "Slim"),
        "character.build.medium": GuessWhoLocalizedString("character.build.medium", defaultValue: "Medium"),
        "character.build.broad": GuessWhoLocalizedString("character.build.broad", defaultValue: "Broad"),
        "character.skin.fair": GuessWhoLocalizedString("character.skin.fair", defaultValue: "Fair Skin"),
        "character.skin.light": GuessWhoLocalizedString("character.skin.light", defaultValue: "Light Skin"),
        "character.skin.medium": GuessWhoLocalizedString("character.skin.medium", defaultValue: "Medium Skin"),
        "character.skin.tan": GuessWhoLocalizedString("character.skin.tan", defaultValue: "Tan Skin"),
        "character.skin.deep": GuessWhoLocalizedString("character.skin.deep", defaultValue: "Deep Skin"),
        "character.texture.straight": GuessWhoLocalizedString("character.texture.straight", defaultValue: "Straight"),
        "character.texture.wavy": GuessWhoLocalizedString("character.texture.wavy", defaultValue: "Wavy"),
        "character.texture.curly": GuessWhoLocalizedString("character.texture.curly", defaultValue: "Curly"),
        "character.texture.coily": GuessWhoLocalizedString("character.texture.coily", defaultValue: "Coily"),
        "character.length.short": GuessWhoLocalizedString("character.length.short", defaultValue: "Short"),
        "character.length.medium": GuessWhoLocalizedString("character.length.medium", defaultValue: "Medium"),
        "character.length.long": GuessWhoLocalizedString("character.length.long", defaultValue: "Long")
    ]

    static var registeredKeys: Set<String> {
        Set(stringsByKey.keys)
    }
}

func guessWhoLocalized(_ key: String, fallback: String) -> String {
    guessWhoLocalized(key, fallback: fallback, language: GuessWhoLanguage.active)
}

func guessWhoLocalized(_ key: String, fallback: String, language: GuessWhoLanguage) -> String {
    guard let localizedString = GuessWhoLocalizationCatalog.stringsByKey[key] else {
        assertionFailure("Missing localized resource registration for \(key)")
        return language.bundle.localizedString(forKey: key, value: fallback, table: nil)
    }

    return localizedString.localized(in: language)
}

func guessWhoLocalizedFormat(_ key: String, fallback: String, _ arguments: CVarArg...) -> String {
    guessWhoLocalizedFormat(key, fallback: fallback, language: GuessWhoLanguage.active, arguments)
}

func guessWhoLocalizedFormat(
    _ key: String,
    fallback: String,
    language: GuessWhoLanguage,
    _ arguments: CVarArg...
) -> String {
    guessWhoLocalizedFormat(key, fallback: fallback, language: language, arguments)
}

func guessWhoLocalizedFormat(
    _ key: String,
    fallback: String,
    language: GuessWhoLanguage,
    _ arguments: [CVarArg]
) -> String {
    guard let localizedString = GuessWhoLocalizationCatalog.stringsByKey[key] else {
        assertionFailure("Missing localized resource registration for \(key)")
        let format = language.bundle.localizedString(forKey: key, value: fallback, table: nil)
        return String(format: format, locale: language.locale, arguments: arguments)
    }

    return localizedString.localizedFormat(in: language, arguments)
}
