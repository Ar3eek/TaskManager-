import SwiftData
import SwiftUI

struct AddLoanView: View {
    @Environment(\.modelContext) private var modelContext

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
        guard !normalized.isEmpty, let value = Decimal(string: normalized) else { return nil }
        return value > 0 ? value : nil
    }

    private var canSave: Bool {
        let hasName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        guard hasName else { return false }
        if generateSchedule { return parsedAmount != nil && installmentCount > 0 }
        return true
    }

    var body: some View {
        ModalFormShell(
            title: "Nowy kredyt",
            saveDisabled: !canSave,
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                FormSectionCard(title: "Kredyt") {
                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                        FormField(title: "Nazwa") {
                            StyledTextField(placeholder: "np. Hipoteka, samochód…", text: $name)
                        }
                        FormField(title: "Notatka") {
                            StyledTextField(placeholder: "Opcjonalnie", text: $note)
                        }
                    }
                }

                FormSectionCard(title: "Harmonogram") {
                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                        Toggle(isOn: $generateSchedule) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Wygeneruj raty")
                                    .font(AppFont.body(.semibold))
                                Text("Miesięczne raty od wybranej daty")
                                    .font(AppFont.caption())
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        .tint(AppTheme.primary)

                        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                            FormField(title: "Kwota raty") {
                                amountField
                            }

                            FormField(title: "Liczba rat") {
                                HStack {
                                    stepButton(systemName: "minus") {
                                        if installmentCount > 1 { installmentCount -= 1 }
                                    }
                                    Text("\(installmentCount)")
                                        .font(AppFont.title(.bold))
                                        .frame(maxWidth: .infinity)
                                        .monospacedDigit()
                                    stepButton(systemName: "plus") {
                                        if installmentCount < 600 { installmentCount += 1 }
                                    }
                                }
                                .padding(.vertical, 4)
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
                        .opacity(generateSchedule ? 1 : 0)
                        .disabled(!generateSchedule)
                        .frame(minHeight: generateSchedule ? nil : 280)
                        .accessibilityHidden(!generateSchedule)
                    }
                    .animation(.easeInOut(duration: 0.2), value: generateSchedule)
                }
            }
        }
    }

    @ViewBuilder
    private var amountField: some View {
        #if os(iOS)
        StyledTextField(placeholder: "np. 2500", text: $installmentAmount, keyboardType: .decimalPad)
        #else
        StyledTextField(placeholder: "np. 2500", text: $installmentAmount)
        #endif
    }

    private func stepButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "\(systemName).circle.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.primary)
        }
        .buttonStyle(.plain)
    }

    private func summaryBox(amount: Decimal) -> some View {
        VStack(spacing: AppTheme.spacingS) {
            HStack {
                Text("Łącznie do spłaty")
                    .font(AppFont.caption())
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Text(Formatters.currency(amount * Decimal(installmentCount)))
                    .font(AppFont.body(.bold))
                    .foregroundStyle(AppTheme.primary)
            }
            if let lastDate = Calendar.current.date(byAdding: .month, value: installmentCount - 1, to: firstDueDate) {
                HStack {
                    Text("Ostatnia rata")
                        .font(AppFont.caption())
                        .foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text(Formatters.date(lastDate))
                        .font(AppFont.caption(.medium))
                }
            }
        }
        .padding(AppTheme.spacingM)
        .background(AppTheme.primarySoft.opacity(0.5))
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
                let installment = Installment(dueDate: item.dueDate, amount: item.amount, loan: loan)
                modelContext.insert(installment)
                loan.installments.append(installment)
            }
        }
    }
}
