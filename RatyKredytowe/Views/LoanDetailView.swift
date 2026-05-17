import SwiftData
import SwiftUI

struct LoanDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var metrics

    @Bindable var loan: Loan
    var onDeleted: (() -> Void)?

    @State private var showingAddInstallment = false
    @State private var showDeleteConfirmation = false
    @State private var filter: InstallmentFilter = .unpaid

    enum InstallmentFilter: String, CaseIterable, Identifiable {
        case unpaid = "Do spłaty"
        case all = "Wszystkie"
        case paid = "Spłacone"

        var id: String { rawValue }
    }

    private var displayedInstallments: [Installment] {
        switch filter {
        case .all: loan.sortedInstallments
        case .unpaid: loan.unpaidInstallments
        case .paid: loan.sortedInstallments.filter(\.isPaid)
        }
    }

    private var progress: Double {
        guard loan.totalCount > 0 else { return 0 }
        return Double(loan.paidCount) / Double(loan.totalCount)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
                summaryBar
                filterBar
                installmentsList
            }
            .padding(metrics.horizontalPadding)
            .padding(.bottom, AppTheme.spacingXL)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .appScreenBackground()
        .navigationTitle("Raty kredytowe")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddInstallment = true
                } label: {
                    Label("Dodaj ratę", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Usuń kredyt", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showingAddInstallment) {
            AddInstallmentView(loan: loan)
                .environment(\.layoutMetrics, metrics)
        }
        .confirmationDialog(
            "Usunąć kredyt „\(loan.name)”?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Usuń kredyt", role: .destructive) {
                modelContext.delete(loan)
                if let onDeleted {
                    onDeleted()
                } else {
                    dismiss()
                }
            }
            Button("Anuluj", role: .cancel) {}
        } message: {
            Text("Wszystkie raty zostaną trwale usunięte.")
        }
    }

    private var summaryBar: some View {
        HStack(spacing: AppTheme.spacingM) {
            ProgressRingView(
                progress: progress,
                lineWidth: 5,
                size: 52,
                tint: loan.isFullyPaid ? AppTheme.success : AppTheme.primary
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(loan.name)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Spłacono")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(Formatters.currency(loan.paidAmount))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.success)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pozostało")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(Formatters.currency(loan.remainingAmount))
                            .font(.subheadline.weight(.semibold))
                    }
                }

                if loan.totalCount > 0 {
                    Text("\(loan.paidCount) z \(loan.totalCount) rat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .appCard()
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Kliknij kółko przy racie, aby oznaczyć spłatę")
                .font(.caption)
                .foregroundStyle(.secondary)
            FilterChipBar(selection: $filter, options: InstallmentFilter.allCases)
        }
    }

    private var installmentsList: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            if displayedInstallments.isEmpty {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .appCard()
            } else {
                ForEach(displayedInstallments) { installment in
                    InstallmentRowView(installment: installment)
                        .contextMenu {
                            Button {
                                installment.markPaid()
                            } label: {
                                Label("Oznacz spłaconą", systemImage: "checkmark.circle")
                            }
                            if installment.isPaid {
                                Button {
                                    installment.markUnpaid()
                                } label: {
                                    Label("Cofnij spłatę", systemImage: "arrow.uturn.backward")
                                }
                            }
                            Divider()
                            Button(role: .destructive) {
                                modelContext.delete(installment)
                            } label: {
                                Label("Usuń ratę", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .all: "Brak rat. Dodaj pierwszą ratę."
        case .unpaid: "Wszystkie raty są spłacone."
        case .paid: "Brak spłaconych rat."
        }
    }
}

#Preview {
    NavigationStack {
        LoanDetailView(loan: Loan(name: "Słuchawki"))
            .environment(\.layoutMetrics, .regular)
    }
    .modelContainer(for: [Loan.self, Installment.self], inMemory: true)
}
