import SwiftData
import SwiftUI

struct AddInstallmentView: View {
    @Environment(\.modelContext) private var modelContext

    let loan: Loan

    @State private var dueDate = Date()
    @State private var amountText = ""
    @State private var note = ""
    @State private var markAsPaid = false

    private var parsedAmount: Decimal? {
        let normalized = amountText
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        guard !normalized.isEmpty, let value = Decimal(string: normalized) else { return nil }
        return value > 0 ? value : nil
    }

    var body: some View {
        ModalFormShell(
            title: "Nowa rata",
            saveDisabled: parsedAmount == nil,
            saveLabel: "Dodaj",
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                FormSectionCard(title: "Szczegóły raty") {
                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                        FormField(title: "Termin płatności") {
                            DatePicker("", selection: $dueDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(AppTheme.primary)
                                .padding(AppTheme.spacingM)
                                .background(AppTheme.appBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                        }

                        FormField(title: "Kwota") {
                            amountField
                        }

                        FormField(title: "Notatka") {
                            StyledTextField(placeholder: "Opcjonalnie", text: $note)
                        }

                        Toggle(isOn: $markAsPaid) {
                            Label("Już spłacona", systemImage: "checkmark.circle")
                                .font(AppFont.body())
                        }
                        .tint(AppTheme.primary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var amountField: some View {
        #if os(iOS)
        StyledTextField(placeholder: "np. 2500", text: $amountText, keyboardType: .decimalPad)
        #else
        StyledTextField(placeholder: "np. 2500", text: $amountText)
        #endif
    }

    private func save() {
        guard let amount = parsedAmount else { return }

        let installment = Installment(
            dueDate: dueDate,
            amount: amount,
            isPaid: markAsPaid,
            paidDate: markAsPaid ? .now : nil,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            loan: loan
        )
        modelContext.insert(installment)
        loan.installments.append(installment)
    }
}
