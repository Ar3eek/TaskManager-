import SwiftData
import SwiftUI

struct GoalFormView: View {
    @Environment(\.modelContext) private var modelContext

    var goal: SavingsGoal?

    @State private var name = ""
    @State private var targetText = ""
    @State private var currentText = ""
    @State private var hasTargetDate = false
    @State private var targetDate = Date()
    @State private var note = ""

    private var parsedTarget: Decimal? { parseDecimal(targetText) }
    private var parsedCurrent: Decimal? { parseDecimal(currentText) ?? 0 }

    var body: some View {
        ModalFormShell(
            title: goal == nil ? "Nowy cel" : "Edytuj cel",
            saveDisabled: name.trimmingCharacters(in: .whitespaces).isEmpty || parsedTarget == nil,
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                FormField(title: "Nazwa") {
                    StyledTextField(placeholder: "np. Wakacje, poduszka finansowa…", text: $name)
                }

                FormField(title: "Kwota docelowa") {
                    StyledTextField(placeholder: "np. 10000", text: $targetText)
                }

                FormField(title: "Już zebrane") {
                    StyledTextField(placeholder: "np. 2500", text: $currentText)
                }

                FormSectionCard(title: "Termin") {
                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                        Toggle("Ustaw termin", isOn: $hasTargetDate)
                            .tint(AppTheme.primary)

                        if hasTargetDate {
                            DatePicker(
                                "Data",
                                selection: $targetDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(AppTheme.spacingM)
                            .background(AppTheme.appBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                        } else {
                            Color.clear.frame(height: 44)
                        }
                    }
                    .frame(minHeight: 88, alignment: .top)
                    .animation(.easeInOut(duration: 0.2), value: hasTargetDate)
                }

                FormField(title: "Notatka") {
                    FormTextEditor(placeholder: "Opcjonalna notatka…", text: $note, minHeight: 88)
                }
            }
        }
        .onAppear(perform: loadGoal)
    }

    private func loadGoal() {
        guard let goal else { return }
        name = goal.name
        targetText = "\(goal.targetAmount)"
        currentText = "\(goal.currentAmount)"
        if let date = goal.targetDate {
            hasTargetDate = true
            targetDate = date
        }
        note = goal.note
    }

    private func save() {
        guard let target = parsedTarget else { return }
        let current = parsedCurrent ?? 0

        if let goal {
            goal.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            goal.targetAmount = target
            goal.currentAmount = current
            goal.targetDate = hasTargetDate ? targetDate : nil
            goal.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            modelContext.insert(SavingsGoal(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                targetAmount: target,
                currentAmount: current,
                targetDate: hasTargetDate ? targetDate : nil,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
            ))
        }
    }

    private func parseDecimal(_ text: String) -> Decimal? {
        let n = text.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty, let v = Decimal(string: n), v > 0 else { return nil }
        return v
    }
}
