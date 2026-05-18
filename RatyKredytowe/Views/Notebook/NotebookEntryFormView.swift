import SwiftData
import SwiftUI

struct NotebookEntryFormView: View {
    @Environment(\.modelContext) private var modelContext

    var entry: NotebookEntry?

    @State private var title = ""
    @State private var content = ""
    @State private var entryType: NotebookEntryType = .note
    @State private var isPinned = false
    @State private var isCompleted = false

    private var isEditing: Bool { entry != nil }

    private var contentLabel: String {
        switch entryType {
        case .note: "Treść"
        case .password: "Hasło / dane logowania"
        case .todo: "Opis zadania"
        }
    }

    private var contentPlaceholder: String {
        switch entryType {
        case .note: "Wpisz notatkę…"
        case .password: "Hasło, login, PIN…"
        case .todo: "Co trzeba zrobić?"
        }
    }

    var body: some View {
        ModalFormShell(
            title: isEditing ? "Edytuj wpis" : "Nowy wpis",
            saveDisabled: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                FormSegmentedPicker(
                    label: "Typ wpisu",
                    selection: $entryType
                )

                FormField(title: "Tytuł") {
                    StyledTextField(
                        placeholder: "np. Wakacje, Netflix, lista zakupów…",
                        text: $title
                    )
                }

                FormField(title: contentLabel) {
                    FormTextEditor(
                        placeholder: contentPlaceholder,
                        text: $content,
                        minHeight: 128
                    )
                }
                .animation(.easeInOut(duration: 0.2), value: entryType)

                FormSectionCard(title: "Opcje") {
                    VStack(alignment: .leading, spacing: 0) {
                        FormToggleRow(title: "Przypnij na górze", isOn: $isPinned)

                        FormToggleRow(
                            title: "Wykonane",
                            isOn: $isCompleted,
                            isVisible: entryType == .todo
                        )

                        FormInfoRow(
                            icon: "lock.shield",
                            text: "Dane przechowywane lokalnie na tym urządzeniu.",
                            isVisible: entryType == .password
                        )
                    }
                    .frame(minHeight: 132, alignment: .top)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: entryType)
        }
        .onAppear(perform: loadEntry)
    }

    private func loadEntry() {
        guard let entry else { return }
        title = entry.title
        content = entry.content
        entryType = entry.entryType
        isPinned = entry.isPinned
        isCompleted = entry.isCompleted
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if let entry {
            entry.title = trimmedTitle
            entry.content = trimmedContent
            entry.entryType = entryType
            entry.isPinned = isPinned
            entry.isCompleted = entryType == .todo ? isCompleted : false
            entry.updatedAt = .now
        } else {
            modelContext.insert(NotebookEntry(
                title: trimmedTitle,
                content: trimmedContent,
                entryType: entryType,
                isCompleted: entryType == .todo ? isCompleted : false,
                isPinned: isPinned
            ))
        }
    }
}
