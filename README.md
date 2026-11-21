# YALIAS

YALIAS is a SwiftUI pass-and-play Alias game for iPhone. It supports classic timed turns and a fastest-to-the-goal mode, configurable word difficulties, persistent player and language settings, and an offline Ukrainian word deck.

## Project notes

- Repository: `guess-who-ios`
- App name: `YALIAS`
- Xcode project and scheme: `Yalias`
- Bundle identifier: `com.beskhlibnyi.guesswho` (retained to preserve the existing app identity and stored settings)
- Target platform: iOS 17+
- UI framework: SwiftUI
- Gameplay: offline and local, with no account or backend required

### Optional word explanations

In the word review popup, tap **Explain word** to request a short Ukrainian explanation and example from OpenAI. This lookup requires internet access; gameplay and word review continue to work offline. Explanations are AI-generated and can be inaccurate, especially for rare words.

1. Copy `Secrets.example.xcconfig` to `Secrets.xcconfig` in the repository root if the local file does not already exist.
2. Set `OPENAI_API_KEY = your-key` in `Secrets.xcconfig`, without quotes.
3. Build and run the app again. Rebuild whenever the configuration changes.

`Config.xcconfig` optionally includes the local file for both Debug and Release. The default model is `gpt-6-astra` with low reasoning effort; `OPENAI_MODEL` can override it. Missing credentials produce an in-app configuration message without making a request. Requests use the Responses API with `store: false` and a 500-token output limit. API usage is billed to the configured OpenAI API project.

`Secrets.xcconfig` is ignored by Git, and only the empty example is committed. The key is expanded into the built app's Info.plist, so it is recoverable from the installed app. This setup is for personal builds. Do not distribute a build containing your key or share expanded build settings.
