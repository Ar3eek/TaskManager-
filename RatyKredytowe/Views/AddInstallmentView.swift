import SwiftData
import SwiftUI

struct AddInstallmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let loan: Loan

    @State private var dueDate = Date()
    @State private var amountText = ""
    @State private var note = ""
    @State private var markAsPaid = false

    private var parsedAmount: Decimal? {
        let normalized = amountText
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        guard !normalized.isEmpty, let value = Decimal(string: normalized) else {
            return nil
        }
        return value > 0 ? value : nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                        Text("Szczegóły raty")
                            .font(.headline)

                        FormField(title: "Termin płatności") {
                            DatePicker("", selection: $dueDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(AppTheme.primary)
                                .padding(AppTheme.spacingS)
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
                                .font(.subheadline.weight(.medium))
                        }
                        .tint(AppTheme.primary)
                    }
                    .appCard()

                    Button("Dodaj ratę") { save() }
                        .buttonStyle(PrimaryButtonStyle(isDisabled: parsedAmount == nil))
                        .disabled(parsedAmount == nil)
                }
                .padding(AppTheme.spacingM)
            }
            .scrollIndicators(.hidden)
            .appScreenBackground()
            .navigationTitle("Nowa rata")
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
        .frame(minWidth: 400, minHeight: 520)
        #endif
    }

    @ViewBuilder
    private var amountField: some View {
        #if os(iOS)
        StyledTextField(
            placeholder: "np. 2500",
            text: $amountText,
            keyboardType: .decimalPad
        )
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
        dismiss()
    }
}

#Preview {
    AddInstallmentView(loan: Loan(name: "Test"))
        .modelContainer(for: [Loan.self, Installment.self], inMemory: true)
}
