# GuessWho UX Rebuild Plan

Last updated: 2026-08-30

## Goal

Refactor the app's user experience so it feels like a polished pass-and-play game rather than a local prototype dashboard. This plan is about interaction flow and game UX, not final visual design.

## Current Problems To Fix

1. The main gameplay screen spends too much space on status and framing before the board.
2. The turn flow does not explicitly capture the core ritual of asking a question, hearing yes/no, then eliminating suspects.
3. Players can see too many competing actions at once during a turn.
4. The app locks behavior only after the first blur, which is easy to misunderstand.
5. `Pass Turn` is available too loosely and can weaken the rhythm of play.
6. Privacy handoff moments are not strong enough for a one-phone secret game.
7. Character cards expose too much always-visible trait data, which hurts scanability.
8. Menu behavior does not clearly distinguish resume vs new game.
9. Winning should happen only on an explicit correct guess, not silently from board state.

## First Step

Before any UX refactor work:

1. Resolve the unresolved merge markers in `/Users/yaroslavbeskhlibnyi/projectsv2/guess-who-ios/GuessWho/ContentView.swift`.
2. Confirm the app builds and runs in simulator.
3. Keep the existing core rules intact while restructuring the flow.

## Target UX Flow

The app should move through these states:

1. Home
2. Player 1 Secret Pick
3. Pass Phone
4. Player 2 Secret Pick
5. Turn Start
6. Ask Flow or Guess Flow
7. Pass Phone
8. Repeat turns
9. Round Result

## Required UX Changes

### 1. Home Screen

- Show `Start New Game`
- Show `Resume Game` when a round is in progress
- Show `How to Play`
- If the user starts over while a live round exists, confirm before wiping progress

### 2. Secret Selection

- Each player should pick privately
- Use a full-screen privacy-first state
- Do not expose extra gameplay information during this step

### 3. Turn Start

- At the beginning of every turn, force a single decision:
  - `Ask a Question`
  - `Make a Guess`
- Do not leave both paths active on the same screen for the whole turn

### 4. Ask Flow

- The player asks a freeform question out loud
- The opponent answers `Yes` or `No`
- Only after that does the board enter elimination mode
- In elimination mode, the player can blur or unblur suspects
- `Pass Phone` should become available only after a valid ask flow interaction

### 5. Guess Flow

- Choosing `Make a Guess` should enter a distinct final-guess mode
- Make it clear that tapping a card submits the guess
- A wrong guess ends the turn and passes the phone
- A correct guess ends the round immediately

### 6. Last Remaining Card Rule

- Do not auto-award a win when one card remains
- If one suspect remains, prompt for an explicit final guess
- Winning must always require a correct deliberate guess

### 7. Handoff UX

- Use a full-screen blocker for handoff
- Show one large CTA such as `Start My Turn`
- Do not show the board or sensitive state underneath

### 8. Active Gameplay Screen

- Prioritize:
  - current player
  - current turn mode
  - board
  - primary action
- Demote or remove verbose status cards and explanation copy
- Keep destructive actions secondary

### 9. Character Card UX

- Reduce always-visible trait density
- Optimize for fast scanning first
- Preserve full model data even if not all traits are shown by default

## Suggested State Refactor

`GameState` should be reworked around the real player journey, for example:

- `menu`
- `selectingSecret(player)`
- `handoff(from:to:reason:)`
- `choosingTurnAction(player)`
- `awaitingAnswer(player)`
- `eliminating(player, answer:)`
- `guessing(player)`
- `gameOver(winner:reason:)`

Exact naming can change, but the flow should clearly model the experience instead of using one broad "taking turn" bucket.

## Suggested File Focus

Primary files likely to change:

- `/Users/yaroslavbeskhlibnyi/projectsv2/guess-who-ios/GuessWho/ContentView.swift`
- `/Users/yaroslavbeskhlibnyi/projectsv2/guess-who-ios/GuessWho/Models/GameState.swift`

Secondary file to revisit:

- `/Users/yaroslavbeskhlibnyi/projectsv2/guess-who-ios/GuessWho/Models/Character.swift`

## Implementation Checklist

1. Fix merge markers and verify a clean build.
2. Replace the current broad gameplay shell with a flow-driven structure.
3. Add a dedicated turn-start decision state.
4. Add an ask flow with explicit yes/no answer handling before elimination.
5. Restrict elimination to ask mode only.
6. Make guess mode explicit and final.
7. Prevent empty or accidental turns.
8. Remove auto-win on last remaining card.
9. Replace soft handoff cards with full-screen privacy blockers.
10. Simplify the gameplay screen so the board becomes the primary focus.
11. Add resume/new-game semantics to the home flow.
12. Reduce card information overload.
13. Playtest the full two-player loop in simulator.

## Test Checklist

Run through all of these before calling the refactor done:

1. Player 1 selects a secret privately.
2. Player 2 selects a secret privately.
3. A normal ask turn works end to end.
4. A normal guess turn works end to end.
5. A wrong guess passes the phone correctly.
6. A correct guess ends the round correctly.
7. One remaining suspect does not auto-win.
8. Resume from home works during an unfinished match.
9. Starting a new game during a live match confirms before reset.
10. Handoff screens do not leak private information.

## Definition Of Done

The UX refactor is done when:

1. A first-time player can complete a round without outside explanation.
2. Every turn has one clear path: ask or guess.
3. No win occurs without an explicit correct guess.
4. Secret information stays protected during handoff.
5. The board feels like the main play surface, not a subordinate card inside a status-heavy app screen.

## Prompt For The Next Session

Use this prompt if continuing in a new session:

> Open `/Users/yaroslavbeskhlibnyi/projectsv2/guess-who-ios` and execute the UX rebuild plan in `UX_REBUILD_PLAN.md`. First resolve the merge markers and confirm the app builds. Then refactor the game flow so each turn starts with a forced choice between Ask and Guess, add a proper ask flow with an explicit yes/no answer before elimination, make guess mode explicit and final, remove auto-win on one remaining card, strengthen privacy handoff screens, clarify resume/new-game behavior, and simplify the active gameplay screen so it feels like a polished pass-and-play game.
