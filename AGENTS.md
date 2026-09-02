# Project Guidelines

## Project Snapshot

- App: `GuessWho` is an offline, pass-and-play iPhone game built with SwiftUI for iOS 17+.
- Current product shape: there is a small game catalog, but only `guessWho` is playable right now; `nextGame` is a placeholder.
- Entry point: `GuessWho/GuessWhoApp.swift` creates a single shared `GameState` as an `@StateObject`.
- App routing: `GuessWho/ContentView.swift` forwards into `GuessWhoExperienceView`, which switches between the catalog, home, rules, and gameplay screens from `gameState.appScreen`.
- Main state owner: `GuessWho/Features/GuessWho/Models/GameState.swift` is the source of truth for navigation, selected game, turn flow, secrets, eliminated cards, and question notes.
- Gameplay UI: `GuessWho/Features/GuessWho/GuessWhoGameplayFlowView.swift` contains the main round experience and also defines the shared visual system used across the app (`StudioTheme`, `StudioTypography`, button styling, card surfaces).
- Home/setup UI: `GuessWho/Features/GuessWho/GuessWhoHomeScreen.swift` owns the menu, player naming flow, resume/new game actions, and rules entry.
- Catalog UI: `GuessWho/Features/GameCatalog/GamePickerScreen.swift` owns game selection and exposes language switching from the launcher.
- Game data: `GuessWho/Features/GuessWho/Models/Character.swift` contains the starter roster and character presentation helpers; `PortraitImageRepository.swift` handles portrait image loading.
- Localization: `GuessWho/Localization.swift` centralizes string lookup and language selection. The app currently supports English (`en`) and Ukrainian (`uk`).
- Persisted user settings: language override and both player names are stored with `@AppStorage` keys defined in `Localization.swift`.
- When starting a task, prefer this snapshot plus targeted file reads over rescanning the whole repo. Re-scan broadly only if the task suggests architecture changed.

## Working Map

- Xcode project and shared scheme: `GuessWho.xcodeproj`, scheme `GuessWho`; bundle identifier is `com.beskhlibnyi.guesswho`. There is currently no XCTest target or automated test suite.
- Build command: `xcodebuild -project GuessWho.xcodeproj -scheme GuessWho -sdk iphonesimulator -configuration Debug build`. Use a locally available simulator destination when a destination-specific build is needed.
- Navigation is state-driven, not `NavigationLink`-driven. Add or change top-level screens through `GameState.AppScreen`, its navigation methods, and the switch in `GuessWhoExperienceView`.
- Round lifecycle: `idle` -> secret selection for each player -> handoff -> turn action -> question/answer/elimination or guess -> handoff or game over. Keep transition validation inside `GameState`; views should call its intent methods rather than mutate round state.
- Each player has an independent eliminated-character set, question-note list, and question draft. A character is only eliminated for the active player, so do not replace these per-player collections with a shared board without intentionally changing game rules.
- `GameState` is `@MainActor` and exposes most mutable state as `private(set)`. New gameplay behavior generally belongs in an intent method there, then gets rendered from the published state.
- To add a playable catalog game, extend `GameState.Game` with availability and character data, add its catalog/localization presentation, and add a dedicated experience route. Do not mark `nextGame` available without a corresponding flow.
- Portrait files live at `GuessWho/Features/GuessWho/Resources/CharacterPortraits/<CharacterName>.png`; character image references must continue to match those filenames. Portraits are bundled as ordinary project resources, not asset-catalog images.
- Localization source of truth is `GuessWhoLocalizationCatalog` in `Localization.swift`; translations live in `GuessWho/en.lproj/Localizable.strings` and `GuessWho/uk.lproj/Localizable.strings`. When adding a UI string, add the catalog entry and both translations, then use the catalog lookup rather than a raw user-facing literal.
- The active language is selected by a persisted override, otherwise device preferences. `GuessWhoExperienceView` is keyed by the resolved language so language changes rebuild the visible UI.
- Visual consistency: reuse `StudioTheme`, `StudioTypography`, and existing studio button/card styles from `GuessWhoGameplayFlowView.swift`. They are intentionally shared despite being declared in the gameplay file.
- Useful targeted reads by task: state/rules -> `Models/GameState.swift`; turn and board UI -> `GuessWhoGameplayFlowView.swift`; setup/menu -> `GuessWhoHomeScreen.swift`; catalog -> `GamePickerScreen.swift`; strings/language -> `Localization.swift`; portraits/roster -> `Character.swift` and `PortraitImageRepository.swift`.

## Engineering Practices

- Work as an experienced iOS/SwiftUI engineer: inspect relevant code first, make the smallest maintainable change, consider user flow/accessibility/localization, surface material tradeoffs, validate affected behavior, and report evidence plus remaining risks.
- Keep files focused. Do not turn a large screen or model into the default home for unrelated code; extract a new view, model, or helper when it has a clear independent responsibility.
- Keep feature code within its feature directory. Put reusable, feature-agnostic UI in `Shared/UI`; avoid creating a generic shared abstraction until at least two consumers genuinely need it.
- Preserve `GameState` as the single source of truth for game rules and navigation. Views render state and send user intents; they should not duplicate transition logic, mutate state indirectly, or infer rules that belong in the model.
- Keep SwiftUI view bodies readable: compose named subviews for meaningful screen sections, pass only the data and actions each child needs, and keep layout-only helpers near their owning view.
- Prefer small, explicit types and methods over flag combinations or untyped string state. Extend existing enums such as `AppScreen`, `Phase`, `Game`, and `Player` when they model the domain.
- Keep the visual language consistent by reusing existing tokens and controls before adding new colors, fonts, shadows, or button variants. If a style becomes broadly useful, move it deliberately into a focused shared UI file.
- Do not hard-code user-facing text in views. Add localized keys and translations for both English and Ukrainian, and use the localization catalog.
- Preserve offline, pass-and-play behavior. Do not add network dependencies, accounts, analytics, or persistence of round state unless the task explicitly calls for them.
- Avoid broad refactors during a scoped feature or bug fix. Change the smallest coherent boundary, retain unrelated user changes, and clean up only code made obsolete by the work.
- Before handoff, run the narrowest useful validation: build for compilation or manually exercise affected flow when available, run a focused `rg` search for stale references after renames/removals, and run `git diff --check`.

## Cleanup After Changes

After a feature or UI refactor, remove code and resources made obsolete by the change. Check for unused helpers, views, state, assets, localization catalog entries, and localized string keys. Keep entries that are still referenced elsewhere, and run a focused search plus `git diff --check` before handoff.
