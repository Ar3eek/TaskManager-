import Foundation
import SwiftData

@Model
final class Installment {
    var dueDate: Date
    var amount: Decimal
    var isPaid: Bool
    var paidDate: Date?
    var note: String
    var loan: Loan?

    init(
        dueDate: Date,
        amount: Decimal,
        isPaid: Bool = false,
        paidDate: Date? = nil,
        note: String = "",
        loan: Loan? = nil
    ) {
        self.dueDate = dueDate
        self.amount = amount
        self.isPaid = isPaid
        self.paidDate = paidDate
        self.note = note
        self.loan = loan
    }

    var isOverdue: Bool {
        !isPaid && dueDate < Calendar.current.startOfDay(for: .now)
    }

    var isDueSoon: Bool {
        guard !isPaid else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        guard let weekFromNow = calendar.date(byAdding: .day, value: 7, to: today) else {
            return false
        }
        let due = calendar.startOfDay(for: dueDate)
        return due >= today && due <= weekFromNow
    }

    func markPaid(on date: Date = .now) {
        isPaid = true
        paidDate = date
    }

    func markUnpaid() {
        isPaid = false
        paidDate = nil
    }
}
