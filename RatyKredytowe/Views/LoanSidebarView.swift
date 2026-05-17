import SwiftData
import SwiftUI

/// Lewy panel: wybór kredytu. Prawy panel (LoanDetailView) pokazuje raty.
struct LoanSidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.layoutMetrics) private var metrics

    @Query(sort: \Loan.createdAt, order: .reverse) private var loans: [Loan]

    @Binding var selectedLoan: Loan?
    var usesStackNavigation: Bool

    @State private var showingAddLoan = false
    @State private var searchText = ""
    @State private var loanPendingDeletion: Loan?

    init(selectedLoan: Binding<Loan?> = .constant(nil), usesStackNavigation: Bool = false) {
        _selectedLoan = selectedLoan
        self.usesStackNavigation = usesStackNavigation
    }

    private var filteredLoans: [Loan] {
        guard !searchText.isEmpty else { return loans }
        return loans.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var stats: DashboardStats { DashboardStats(loans: loans) }

    var body: some View {
        Group {
            if usesStackNavigation {
                listContent
                    .navigationDestination(for: Loan.self) { loan in
                        LoanDetailView(loan: loan)
                    }
            } else {
                listContent
            }
        }
        .navigationTitle("Kredyty")
        .searchable(text: $searchText, prompt: "Szukaj…")
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingAddLoan) {
            AddLoanView()
                .environment(\.layoutMetrics, metrics)
        }
        .loanDeleteConfirmation(loan: $loanPendingDeletion, onConfirm: deleteLoan)
        .onChange(of: loans.count) { _, _ in
            guard let selected = selectedLoan else { return }
            if !loans.contains(where: { $0.persistentModelID == selected.persistentModelID }) {
                selectedLoan = nil
            }
        }
    }

    @ViewBuilder
    private var listContent: some View {
        if usesStackNavigation {
            List {
                summarySection
                loansSection
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.inset)
            #endif
        } else {
            List(selection: $selectedLoan) {
                summarySection
                loansSection
            }
            .listStyle(.sidebar)
        }
    }

    @ViewBuilder
    private var summarySection: some View {
        if !loans.isEmpty {
            Section {
                SidebarSummaryView(stats: stats)
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
    }

    @ViewBuilder
    private var loansSection: some View {
        Section {
            if filteredLoans.isEmpty {
                ContentUnavailableView {
                    Label(
                        loans.isEmpty ? "Brak kredytów" : "Brak wyników",
                        systemImage: "creditcard"
                    )
                } description: {
                    Text(loans.isEmpty ? "Dodaj kredyt przyciskiem +" : "Zmień frazę wyszukiwania.")
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredLoans) { loan in
                    loanRow(for: loan)
                }
                .onDelete(perform: deleteLoansAtOffsets)
            }
        } header: {
            Text("Wybierz kredyt")
        } footer: {
            if !filteredLoans.isEmpty {
                Text("Kliknij kredyt, aby zobaczyć i edytować raty.")
            }
        }
    }

    @ViewBuilder
    private func loanRow(for loan: Loan) -> some View {
        if usesStackNavigation {
            NavigationLink(value: loan) {
                SidebarLoanRow(loan: loan)
            }
        } else {
            SidebarLoanRow(loan: loan, isSelected: selectedLoan?.persistentModelID == loan.persistentModelID)
                .tag(loan)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingAddLoan = true
            } label: {
                Label("Dodaj kredyt", systemImage: "plus")
            }
        }
    }

    private func deleteLoansAtOffsets(_ offsets: IndexSet) {
        for index in offsets {
            let loan = filteredLoans[index]
            if selectedLoan?.persistentModelID == loan.persistentModelID {
                selectedLoan = nil
            }
            modelContext.delete(loan)
        }
    }

    private func deleteLoan(_ loan: Loan) {
        if selectedLoan?.persistentModelID == loan.persistentModelID {
            selectedLoan = nil
        }
        modelContext.delete(loan)
        loanPendingDeletion = nil
    }
}

// MARK: - Sidebar Row

struct SidebarLoanRow: View {
    let loan: Loan
    var isSelected: Bool = false

    private var progress: Double {
        guard loan.totalCount > 0 else { return 0 }
        return Double(loan.paidCount) / Double(loan.totalCount)
    }

    private var hasOverdue: Bool {
        loan.unpaidInstallments.contains(where: \.isOverdue)
    }

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(AppTheme.primary.opacity(0.2), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        loan.isFullyPaid ? AppTheme.success : AppTheme.primary,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(loan.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    if loan.isFullyPaid {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.success)
                    }
                }

                HStack(spacing: 4) {
                    if loan.totalCount > 0 {
                        Text("\(loan.paidCount)/\(loan.totalCount) rat")
                        Text("·")
                        Text(Formatters.currency(loan.remainingAmount))
                            .monospacedDigit()
                    } else {
                        Text("Brak rat")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer(minLength: 0)

            if hasOverdue {
                Circle()
                    .fill(AppTheme.danger)
                    .frame(width: 8, height: 8)
                    .accessibilityLabel("Zaległa rata")
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Summary

struct SidebarSummaryView: View {
    let stats: DashboardStats

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Podsumowanie")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(Formatters.currency(stats.totalRemaining))
                .font(.title3.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("pozostało do spłaty")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                summaryChip("\(stats.activeLoansCount)", label: "kredytów")
                if stats.overdueCount > 0 {
                    summaryChip("\(stats.overdueCount)", label: "zaległych", warning: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func summaryChip(_ value: String, label: String, warning: Bool = false) -> some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.caption.weight(.bold))
            Text(label)
                .font(.caption2)
        }
        .foregroundStyle(warning ? AppTheme.danger : .secondary)
    }
}

// MARK: - Placeholder

struct SelectLoanPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 52))
                .foregroundStyle(AppTheme.primary.opacity(0.5))
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 8) {
                Text("Raty kredytowe")
                    .font(.title2.weight(.bold))
                Text("Wybierz kredyt po lewej stronie,\naby zobaczyć harmonogram i oznaczać spłacone raty.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Label("Kliknij kredyt na liście", systemImage: "arrow.left")
                .font(.caption.weight(.medium))
                .foregroundStyle(.tertiary)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appScreenBackground()
    }
}

#Preview("Sidebar") {
    NavigationSplitView {
        LoanSidebarView(selectedLoan: .constant(nil))
    } detail: {
        SelectLoanPlaceholderView()
    }
    .modelContainer(for: [Loan.self, Installment.self], inMemory: true)
}
