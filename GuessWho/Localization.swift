import Foundation

let guessWhoLanguageOverrideKey = "homeLanguageOverride"
let guessWhoPlayerOneNameKey = "playerOneName"
let guessWhoPlayerTwoNameKey = "playerTwoName"

enum GuessWhoLanguage: String {
    case english = "en"
    case ukrainian = "uk"

    static var active: GuessWhoLanguage {
        resolved(override: UserDefaults.standard.string(forKey: guessWhoLanguageOverrideKey))
    }

    static func resolved(override: String?) -> GuessWhoLanguage {
        if let override, let language = GuessWhoLanguage(rawValue: override) {
            return language
        }

        if Locale.preferredLanguages.first?.hasPrefix(GuessWhoLanguage.ukrainian.rawValue) == true {
            return .ukrainian
        }

        return .english
    }

    var bundle: Bundle {
        guard
            let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }

        return bundle
    }

    var localeIdentifier: String {
        switch self {
        case .english:
            return "en_US"
        case .ukrainian:
            return "uk_UA"
        }
    }
}

func guessWhoLocalized(_ key: String, fallback: String) -> String {
    guessWhoLocalized(key, fallback: fallback, language: GuessWhoLanguage.active)
}

func guessWhoLocalized(_ key: String, fallback: String, language: GuessWhoLanguage) -> String {
    NSLocalizedString(key, bundle: language.bundle, value: fallback, comment: "")
}

func guessWhoLocalizedFormat(_ key: String, fallback: String, _ arguments: CVarArg...) -> String {
    guessWhoLocalizedFormat(key, fallback: fallback, language: GuessWhoLanguage.active, arguments)
}

func guessWhoLocalizedFormat(
    _ key: String,
    fallback: String,
    language: GuessWhoLanguage,
    _ arguments: [CVarArg]
) -> String {
    let format = guessWhoLocalized(key, fallback: fallback, language: language)
    return String(format: format, locale: Locale(identifier: language.localeIdentifier), arguments: arguments)
}
