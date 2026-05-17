import Foundation
import SwiftData

@Model
final class Loan {
    var name: String
    var note: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Installment.loan)
    var installments: [Installment]

    init(
        name: String,
        note: String = "",
        createdAt: Date = .now,
        installments: [Installment] = []
    ) {
        self.name = name
        self.note = note
        self.createdAt = createdAt
        self.installments = installments
    }

    var sortedInstallments: [Installment] {
        installments.sorted { $0.dueDate < $1.dueDate }
    }

    var unpaidInstallments: [Installment] {
        sortedInstallments.filter { !$0.isPaid }
    }

    var nextDueInstallment: Installment? {
        unpaidInstallments.first
    }

    var paidCount: Int {
        installments.filter(\.isPaid).count
    }

    var totalCount: Int {
        installments.count
    }

    var totalAmount: Decimal {
        installments.reduce(0) { $0 + $1.amount }
    }

    var paidAmount: Decimal {
        installments.filter(\.isPaid).reduce(0) { $0 + $1.amount }
    }

    var remainingAmount: Decimal {
        totalAmount - paidAmount
    }

    var isFullyPaid: Bool {
        !installments.isEmpty && unpaidInstallments.isEmpty
    }
}
