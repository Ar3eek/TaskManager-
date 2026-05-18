import SwiftUI

/// Moduł rat kredytowych — poprzedni układ split / stack.
struct LoansRootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var selectedLoan: Loan?

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
                NavigationSplitView {
                    LoanSidebarView(selectedLoan: $selectedLoan)
                        .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 340)
                } detail: {
                    if let loan = selectedLoan {
                        LoanDetailView(loan: loan, onDeleted: { selectedLoan = nil })
                            .id(loan.persistentModelID)
                    } else {
                        SelectLoanPlaceholderView()
                    }
                }
            } else {
                LoanSidebarView(usesStackNavigation: true)
            }
        }
        .navigationTitle("Raty kredytowe")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
