import SwiftData
import SwiftUI

struct QuickLinkFormView: View {
    @Environment(\.modelContext) private var modelContext

    var link: QuickLink?

    @State private var title = ""
    @State private var url = ""
    @State private var username = ""
    @State private var notes = ""

    var body: some View {
        ModalFormShell(
            title: link == nil ? "Nowy skrót" : "Edytuj skrót",
            saveDisabled: title.trimmingCharacters(in: .whitespaces).isEmpty,
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                FormField(title: "Nazwa") {
                    StyledTextField(placeholder: "np. Bank, Netflix, Allegro…", text: $title)
                }

                FormField(title: "Adres URL") {
                    StyledTextField(placeholder: "https://…", text: $url)
                }

                FormField(title: "Login / e-mail") {
                    StyledTextField(placeholder: "Opcjonalnie", text: $username)
                }

                FormField(title: "Notatka") {
                    FormTextEditor(placeholder: "Dodatkowe informacje…", text: $notes, minHeight: 96)
                }
            }
        }
        .onAppear(perform: loadLink)
    }

    private func loadLink() {
        guard let link else { return }
        title = link.title
        url = link.url
        username = link.username
        notes = link.notes
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let link {
            link.title = trimmedTitle
            link.url = url.trimmingCharacters(in: .whitespacesAndNewlines)
            link.username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            link.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            modelContext.insert(QuickLink(
                title: trimmedTitle,
                url: url.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
            ))
        }
    }
}
