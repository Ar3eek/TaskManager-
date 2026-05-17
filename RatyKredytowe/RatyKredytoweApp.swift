import SwiftData
import SwiftUI

@main
struct RatyKredytoweApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(AppTheme.primary)
        }
        .modelContainer(for: [Loan.self, Installment.self])
    }
}
