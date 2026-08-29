import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var gameState: GameState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    statusCard
                    goalsCard
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("GuessWho")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Offline Guess Who")
                .font(.largeTitle.bold())

            Text("A small SwiftUI scaffold for a two-player pass-and-play iPhone game.")
                .font(.body)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Deal Secret Characters") {
                    gameState.startNewGame()
                }
                .buttonStyle(.borderedProminent)

                if gameState.phase == .inProgress {
                    Button("Pass Turn") {
                        gameState.advanceTurn()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Status")
                .font(.headline)

            statusRow(title: "Roster size", value: "\(gameState.characters.count) characters")
            statusRow(title: "Phase", value: gameState.phase.label)
            statusRow(title: "Current turn", value: gameState.currentPlayer.rawValue)
            statusRow(title: "Player 1 secret", value: gameState.playerOneSecret == nil ? "Not dealt" : "Assigned")
            statusRow(title: "Player 2 secret", value: gameState.playerTwoSecret == nil ? "Not dealt" : "Assigned")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var goalsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MVP Goals")
                .font(.headline)

            ForEach(gameState.mvpGoals, id: \.self) { goal in
                Label(goal, systemImage: "checkmark.circle")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func statusRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState())
}

