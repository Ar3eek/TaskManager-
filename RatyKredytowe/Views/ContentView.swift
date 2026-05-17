import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var selectedLoan: Loan?

    private var layoutMetrics: LayoutMetrics {
        LayoutMetrics.from(horizontalSizeClass: horizontalSizeClass)
    }

    private var usesSplitLayout: Bool {
        #if os(macOS)
        true
        #else
        horizontalSizeClass == .regular
        #endif
    }

    var body: some View {
        Group {
            if usesSplitLayout {
                splitLayout
            } else {
                phoneLayout
            }
        }
        .environment(\.layoutMetrics, layoutMetrics)
    }

    private var splitLayout: some View {
        NavigationSplitView {
            LoanSidebarView(selectedLoan: $selectedLoan)
                .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 340)
        } detail: {
            detailPane
        }
    }

    private var phoneLayout: some View {
        NavigationStack {
            LoanSidebarView(usesStackNavigation: true)
        }
    }

    @ViewBuilder
    private var detailPane: some View {
        if let loan = selectedLoan {
            LoanDetailView(loan: loan, onDeleted: { selectedLoan = nil })
                .id(loan.persistentModelID)
        } else {
            SelectLoanPlaceholderView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Loan.self, Installment.self], inMemory: true)
}
