import SwiftUI

struct NotesView: View {
    let language: GuessWhoLanguage; let player: GameState.Player; let notes: [GameState.QuestionNote]; let includesDraft: Bool
    @Binding var draft: String
    let updateText: (String, GameState.QuestionNote.ID) -> Void; let updateAnswer: (Bool, GameState.QuestionNote.ID) -> Void; let recordAnswer: (Bool) -> Void
    var body: some View { StudioSurface { VStack(alignment: .leading, spacing: 12) {
        Text(localized("notes.title", "Notes", language)).font(.headline)
        if notes.isEmpty && !includesDraft { Text(localized("notes.empty", "Your saved steps will appear here.", language)).font(.subheadline).foregroundStyle(StudioTheme.muted) }
        ForEach(notes) { note in NoteRow(question: Binding(get: { note.question }, set: { updateText($0, note.id) }), answer: note.answer, onAnswer: { updateAnswer($0, note.id) }) }
        if includesDraft { VStack(alignment: .leading, spacing: 8) { TextField(localized("notes.question.placeholder", "Asked question", language), text: $draft).textFieldStyle(.roundedBorder); HStack { Button(localized("common.yes", "Yes", language)) { recordAnswer(true) }; Spacer(); Button(localized("common.no", "No", language)) { recordAnswer(false) } }.buttonStyle(.borderedProminent).tint(StudioTheme.teal) } }
    }} }
}

private struct NoteRow: View {
    @Binding var question: String; let answer: Bool; let onAnswer: (Bool) -> Void
    var body: some View { HStack { TextField("Question", text: $question).textFieldStyle(.roundedBorder); Button(answer ? "Yes" : "No") { onAnswer(!answer) }.buttonStyle(.bordered).tint(answer ? StudioTheme.teal : StudioTheme.coral) } }
}
