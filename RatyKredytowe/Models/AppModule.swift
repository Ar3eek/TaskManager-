import SwiftUI

enum AppModule: String, CaseIterable, Identifiable, Hashable {
    case loans = "Raty kredytowe"
    case notebook = "Notatnik"
    case goals = "Cele oszczędnościowe"
    case quickLinks = "Skróty i linki"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .loans: "Harmonogram rat i spłaty"
        case .notebook: "Notatki, hasła, zadania"
        case .goals: "Oszczędzaj na cele"
        case .quickLinks: "Ulubione strony i konta"
        }
    }

    var icon: String {
        switch self {
        case .loans: "creditcard.fill"
        case .notebook: "book.closed.fill"
        case .goals: "target"
        case .quickLinks: "link.circle.fill"
        }
    }

    var accent: Color {
        switch self {
        case .loans: AppTheme.accentLoans
        case .notebook: AppTheme.accentNotebook
        case .goals: AppTheme.accentGoals
        case .quickLinks: AppTheme.accentLinks
        }
    }
}
