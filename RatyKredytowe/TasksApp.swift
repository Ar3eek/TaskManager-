import SwiftData
import SwiftUI

@main
struct TasksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .defaultSize(width: 1100, height: 720)
        #endif
        .modelContainer(for: [
            Loan.self,
            Installment.self,
            NotebookEntry.self,
            SavingsGoal.self,
            QuickLink.self
        ])
    }
}
