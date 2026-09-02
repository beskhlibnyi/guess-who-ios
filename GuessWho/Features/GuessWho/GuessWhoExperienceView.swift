import SwiftUI

/// Coordinates the screens belonging to the Guess Who feature.
struct GuessWhoExperienceView: View {
    @EnvironmentObject private var gameState: GameState
    @AppStorage(guessWhoLanguageOverrideKey) private var languageOverride = ""

    var body: some View {
        NavigationStack {
            ZStack {
                StudioBackgroundView()

                switch gameState.appScreen {
                case .gamePicker:
                    GamePickerScreen()
                case .aliasPreview:
                    AliasVocabularyPreviewScreen()
                case .menu:
                    GuessWhoHomeScreen()
                case .rules:
                    RulesScreen()
                case .game:
                    GuessWhoGameplayFlowView()
                }
            }
            .id(GuessWhoLanguage.resolved(override: languageOverride).rawValue)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct StudioBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [StudioTheme.canvasTop, StudioTheme.canvasBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Circle().fill(StudioTheme.gold.opacity(0.16)).frame(width: 260, height: 260).blur(radius: 10).offset(x: 150, y: -280)
            Circle().fill(StudioTheme.coral.opacity(0.12)).frame(width: 220, height: 220).blur(radius: 18).offset(x: -150, y: 290)
            Circle().fill(StudioTheme.teal.opacity(0.11)).frame(width: 240, height: 240).blur(radius: 18).offset(x: 170, y: 360)
        }
    }
}
