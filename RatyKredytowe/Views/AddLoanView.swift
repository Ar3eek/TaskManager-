import SwiftData
import SwiftUI

struct AddLoanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var note = ""
    @State private var generateSchedule = true
    @State private var installmentAmount = ""
    @State private var installmentCount = 12
    @State private var firstDueDate = Date()

    private var parsedAmount: Decimal? {
        let normalized = installmentAmount
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        guard !normalized.isEmpty, let value = Decimal(string: normalized) else {
            return nil
        }
        return value > 0 ? value : nil
    }

    private var canSave: Bool {
        let hasName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        guard hasName else { return false }
        if generateSchedule {
            return parsedAmount != nil && installmentCount > 0
        }
        return true
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                    formCard(title: "Kredyt") {
                        FormField(title: "Nazwa") {
                            StyledTextField(
                                placeholder: "np. Hipoteka, samochód…",
                                text: $name
                            )
                        }
                        FormField(title: "Notatka") {
                            StyledTextField(
                                placeholder: "Opcjonalnie",
                                text: $note
                            )
                        }
                    }

                    formCard(title: "Harmonogram") {
                        Toggle(isOn: $generateSchedule) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Wygeneruj raty")
                                    .font(.subheadline.weight(.semibold))
                                Text("Miesięczne raty od wybranej daty")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(AppTheme.primary)

                        if generateSchedule {
                            Divider().padding(.vertical, 4)

                            FormField(title: "Kwota raty") {
                                amountField
                            }

                            FormField(title: "Liczba rat") {
                                HStack {
                                    Button {
                                        if installmentCount > 1 { installmentCount -= 1 }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(AppTheme.primary)
                                    }
                                    Text("\(installmentCount)")
                                        .font(.title2.weight(.bold))
                                        .frame(maxWidth: .infinity)
                                        .monospacedDigit()
                                    Button {
                                        if installmentCount < 600 { installmentCount += 1 }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(AppTheme.primary)
                                    }
                                }
                                .padding(.vertical, 8)
                            }

                            FormField(title: "Pierwsza rata") {
                                DatePicker("", selection: $firstDueDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .padding(AppTheme.spacingM)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppTheme.appBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                            }

                            if let amount = parsedAmount {
                                summaryBox(amount: amount)
                            }
                        }
                    }

                    Button("Zapisz kredyt") { save() }
                        .buttonStyle(PrimaryButtonStyle(isDisabled: !canSave))
                        .disabled(!canSave)
                }
                .padding(AppTheme.spacingM)
                .padding(.bottom, AppTheme.spacingXL)
            }
            .scrollIndicators(.hidden)
            .appScreenBackground()
            .navigationTitle("Nowy kredyt")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 440, minHeight: 560)
        #endif
    }

    @ViewBuilder
    private var amountField: some View {
        #if os(iOS)
        StyledTextField(
            placeholder: "np. 2500",
            text: $installmentAmount,
            keyboardType: .decimalPad
        )
        #else
        StyledTextField(
            placeholder: "np. 2500",
            text: $installmentAmount
        )
        #endif
    }

    private func formCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Text(title)
                .font(.headline)
            content()
        }
        .appCard()
    }

    private func summaryBox(amount: Decimal) -> some View {
        VStack(spacing: AppTheme.spacingS) {
            HStack {
                Text("Łącznie do spłaty")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Formatters.currency(amount * Decimal(installmentCount)))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.primary)
            }
            if let lastDate = Calendar.current.date(
                byAdding: .month,
                value: installmentCount - 1,
                to: firstDueDate
            ) {
                HStack {
                    Text("Ostatnia rata")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(Formatters.date(lastDate))
                        .font(.subheadline.weight(.medium))
                }
            }
        }
        .padding(AppTheme.spacingM)
        .background(AppTheme.primarySoft.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
    }

    private func save() {
        let loan = Loan(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(loan)

        if generateSchedule, let amount = parsedAmount {
            let schedule = InstallmentGenerator.makeInstallments(
                count: installmentCount,
                amount: amount,
                firstDueDate: firstDueDate
            )
            for item in schedule {
                let installment = Installment(
                    dueDate: item.dueDate,
                    amount: item.amount,
                    loan: loan
                )
                modelContext.insert(installment)
                loan.installments.append(installment)
            }
        }

        dismiss()
    }
}

#Preview {
    AddLoanView()
        .modelContainer(for: [Loan.self, Installment.self], inMemory: true)
}
