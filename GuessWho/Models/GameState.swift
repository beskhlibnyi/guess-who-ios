import Foundation

@MainActor
final class GameState: ObservableObject {
    enum Phase {
        case setup
        case inProgress

        var label: String {
            switch self {
            case .setup:
                return "Setup"
            case .inProgress:
                return "In Progress"
            }
        }
    }

    enum Player: String {
        case one = "Player 1"
        case two = "Player 2"

        var next: Player {
            switch self {
            case .one:
                return .two
            case .two:
                return .one
            }
        }
    }

    @Published private(set) var characters: [Character] = Character.starterRoster
    @Published private(set) var playerOneSecret: Character?
    @Published private(set) var playerTwoSecret: Character?
    @Published private(set) var currentPlayer: Player = .one
    @Published private(set) var phase: Phase = .setup

    let mvpGoals: [String] = [
        "Two players on one iPhone",
        "Fully offline play",
        "Secret character for each player",
        "Yes or no questions",
        "Character elimination",
        "First correct guess wins"
    ]

    func startNewGame() {
        guard characters.count >= 2 else { return }

        let shuffledCharacters = characters.shuffled()
        playerOneSecret = shuffledCharacters[0]
        playerTwoSecret = shuffledCharacters[1]
        currentPlayer = .one
        phase = .inProgress
    }

    func advanceTurn() {
        guard phase == .inProgress else { return }
        currentPlayer = currentPlayer.next
    }
}

