# GuessWho

Minimal SwiftUI starter for an offline, pass-and-play Guess Who-style iPhone game.

## MVP

- Two players share one iPhone.
- The game works fully offline with no backend or database.
- Each player gets a secret character.
- Players ask yes/no questions to eliminate characters.
- The first player to make the correct guess wins.

## Project Notes

- Repository name: `guess-who-ios`
- App and Xcode project name: `GuessWho`
- Target platform: iOS 17+
- UI framework: SwiftUI

### Optional Alias word explanations

In the Alias word review popup, tap **Explain word** to request a short Ukrainian
explanation and example from OpenAI. This lookup requires internet access; the
game and word review continue to work offline. Explanations are AI-generated and
can be inaccurate, especially for rare words.

1. Copy `Secrets.example.xcconfig` to `Secrets.xcconfig` in the repository root
   if the local file does not already exist.
2. Set `OPENAI_API_KEY = your-key` in `Secrets.xcconfig`, without quotes.
3. Build and run the app again. Rebuild whenever the configuration changes.

`Config.xcconfig` optionally includes the local file for both Debug and Release.
The default model is `gpt-6-astra` with low reasoning effort; `OPENAI_MODEL` can override it. Missing
credentials produce an in-app configuration message without making a request.
Requests use the Responses API with `store: false` and a 500-token output limit.
API usage is billed to the configured OpenAI API project.

`Secrets.xcconfig` is ignored by Git, and only the empty example is committed.
The key is expanded into the built app's Info.plist, so it is recoverable from
the installed app. This setup is for personal builds. Do not distribute a build
containing your key. Avoid sharing build logs or expanded build settings, which
can include secrets. See the [OpenAI authentication guidance](https://developers.openai.com/api/reference/overview#authentication).

## Current State

This initial commit includes a runnable SwiftUI app scaffold, a small game state model, starter character data, and the Xcode project files needed to open the app in Xcode and continue building the MVP.
