# Project Guidelines

## Project snapshot

- YALIAS is an offline, pass-and-play SwiftUI game for iOS 17+.
- `Yalias/ContentView.swift` owns Alias-only navigation between menu, word review, and gameplay.
- `AliasGameState` owns both classic and fastest-mode match state.
- `AliasVocabulary.swift` reads the bundled Ukrainian deck from `alias_uk_words.sqlite`.
- `Localization.swift` supports English and Ukrainian UI while playable words remain Ukrainian.
- Player names, language, match setup, and vocabulary filters use `@AppStorage`.

## Engineering practices

- Preserve both game modes and offline gameplay.
- Keep game transitions inside `AliasGameState`; views render state and send intents.
- Keep feature code in `Features/Alias` and feature-agnostic UI in `Shared/UI`.
- Register every user-facing string in `AliasLocalizationCatalog` and translate it in both `en.lproj` and `uk.lproj`.
- Reuse `StudioTheme`, `StudioTypography`, and `ActionButtonStyle` for visual consistency.
- Do not add accounts, analytics, or gameplay network dependencies.
- Preserve unrelated user changes in a dirty worktree.
- Before handoff, run the simulator build, search for stale references, and run `git diff --check`.

## Alias vocabulary

- `alias_uk_words.sqlite` is the offline source of truth; do not add a second flat word resource.
- The deck contains nouns and optionally adjectives. Verbs are not playable.
- Keep `AliasVocabularyAttribution.md` bundled with the deck.
- Rebuild the database with `bin/build_alias_words` only when intentionally changing vocabulary data.
