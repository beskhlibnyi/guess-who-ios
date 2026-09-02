import SwiftUI

struct BoardView: View {
    enum Mode { case selectSecret, eliminate, guess }
    let characters: [Character]; let mode: Mode; let player: GameState.Player; let isEliminated: (Character) -> Bool; let onTap: (Character) -> Void
    private let columns = [GridItem(.adaptive(minimum: 145), spacing: 14, alignment: .top)]
    var body: some View { LazyVGrid(columns: columns, spacing: 14) { ForEach(characters) { character in CharacterCard(character: character, mode: mode, eliminated: isEliminated(character), action: { onTap(character) }) } } }
}

private struct CharacterCard: View {
    let character: Character; let mode: BoardView.Mode; let eliminated: Bool; let action: () -> Void
    var body: some View { Button(action: action) { VStack(alignment: .leading, spacing: 8) {
        PortraitView(character: character).frame(height: 132).frame(maxWidth: .infinity).background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        Text(character.name).font(.headline).foregroundStyle(StudioTheme.ink).lineLimit(1)
        Text(character.boardSummary).font(.caption).foregroundStyle(StudioTheme.muted).lineLimit(2)
    }.padding(10).frame(maxWidth: .infinity, alignment: .leading).background(eliminated ? StudioTheme.coral.opacity(0.12) : StudioTheme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(eliminated ? StudioTheme.coral : StudioTheme.line, lineWidth: eliminated ? 2 : 1)).opacity(eliminated ? 0.5 : 1) }.buttonStyle(.plain).accessibilityLabel(character.name).accessibilityHint(mode == .eliminate ? "Toggle eliminated" : "Select character") }
}

struct PortraitView: View {
    let character: Character
    @EnvironmentObject private var portraitRepository: PortraitImageRepository

    var body: some View {
        Group {
            if let image = portraitRepository.image(for: character) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "person.crop.square")
                    .resizable()
                    .scaledToFit()
                    .padding(28)
                    .foregroundStyle(StudioTheme.muted)
            }
        }
    }
}
