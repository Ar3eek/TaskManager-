import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geometry in
            let metrics = LayoutMetrics.resolve(
                width: geometry.size.width,
                horizontalSizeClass: horizontalSizeClass
            )

            NavigationStack {
                HomeView()
                    .navigationDestination(for: AppModule.self) { module in
                        moduleDestination(for: module)
                    }
            }
            .environment(\.layoutMetrics, metrics)
            .tint(AppTheme.primary)
            .appScreenBackground()
        }
    }

    @ViewBuilder
    private func moduleDestination(for module: AppModule) -> some View {
        switch module {
        case .loans:
            LoansRootView()
        case .notebook:
            NotebookListView()
        case .goals:
            GoalsListView()
        case .quickLinks:
            QuickLinksListView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Loan.self,
            Installment.self,
            NotebookEntry.self,
            SavingsGoal.self,
            QuickLink.self
        ], inMemory: true)
}
