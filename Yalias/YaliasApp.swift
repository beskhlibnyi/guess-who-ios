import SwiftUI

@main
struct YaliasApp: App {
    @StateObject private var navigationState = AliasNavigationState()
    @StateObject private var aliasGameState = AliasGameState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationState)
                .environmentObject(aliasGameState)
        }
    }
}
