import SwiftUI

/// Alias-only app router. The menu is the root experience.
struct ContentView: View {
    @EnvironmentObject private var navigationState: AliasNavigationState
    @AppStorage(aliasLanguageOverrideKey) private var languageOverride = ""

    var body: some View {
        NavigationStack {
            ZStack {
                StudioBackgroundView()

                switch navigationState.screen {
                case .menu:
                    AliasHomeScreen()
                case .review:
                    AliasVocabularyReviewScreen()
                case .game:
                    AliasGameplayScreen()
                }
            }
            .id(AliasLanguage.resolved(override: languageOverride).rawValue)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

@MainActor
final class AliasNavigationState: ObservableObject {
    enum Screen {
        case menu
        case review
        case game
    }

    @Published private(set) var screen: Screen = .menu

    func showMenu() {
        screen = .menu
    }

    func showReview() {
        screen = .review
    }

    func showGame() {
        screen = .game
    }
}
