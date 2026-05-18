import Foundation
import SwiftData

@Model
final class QuickLink {
    var title: String
    var url: String
    var username: String
    var notes: String
    var createdAt: Date

    init(
        title: String,
        url: String = "",
        username: String = "",
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.title = title
        self.url = url
        self.username = username
        self.notes = notes
        self.createdAt = createdAt
    }
}
