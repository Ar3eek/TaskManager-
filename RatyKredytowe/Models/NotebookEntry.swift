import Foundation
import SwiftData

enum NotebookEntryType: String, CaseIterable, Identifiable, Codable {
    case note = "Notatka"
    case password = "Hasło"
    case todo = "Do zrobienia"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .note: "note.text"
        case .password: "key.fill"
        case .todo: "checklist"
        }
    }
}

@Model
final class NotebookEntry {
    var title: String
    var content: String
    var entryTypeRaw: String
    var isCompleted: Bool
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        title: String,
        content: String = "",
        entryType: NotebookEntryType = .note,
        isCompleted: Bool = false,
        isPinned: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.title = title
        self.content = content
        self.entryTypeRaw = entryType.rawValue
        self.isCompleted = isCompleted
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var entryType: NotebookEntryType {
        get { NotebookEntryType(rawValue: entryTypeRaw) ?? .note }
        set { entryTypeRaw = newValue.rawValue }
    }
}
