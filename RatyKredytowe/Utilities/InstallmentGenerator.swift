import Foundation

enum InstallmentGenerator {
    static func makeInstallments(
        count: Int,
        amount: Decimal,
        firstDueDate: Date,
        calendar: Calendar = .current
    ) -> [(dueDate: Date, amount: Decimal)] {
        guard count > 0 else { return [] }

        return (0..<count).compactMap { index in
            guard let dueDate = calendar.date(
                byAdding: .month,
                value: index,
                to: firstDueDate
            ) else {
                return nil
            }
            return (dueDate: dueDate, amount: amount)
        }
    }
}
