import SwiftUI

struct NotesView: View {
    @AppStorage("personalNotes") private var notes = ""
    private let theme = AppTheme()
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Anota qué te ayuda a mantener tus hábitos.")
                    .foregroundStyle(theme.secondary)
                TextEditor(text: $notes)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(theme.surface, in: RoundedRectangle(cornerRadius: 20))
                    .accessibilityLabel("Notas personales")
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(theme.background.ignoresSafeArea())
            .foregroundStyle(theme.foreground)
            .navigationTitle("Notas")
        }
    }
}
