import Foundation
import SwiftData

@Model
final class SavingsGoal {
    var name: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var targetDate: Date?
    var note: String
    var createdAt: Date

    init(
        name: String,
        targetAmount: Decimal,
        currentAmount: Decimal = 0,
        targetDate: Date? = nil,
        note: String = "",
        createdAt: Date = .now
    ) {
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.note = note
        self.createdAt = createdAt
    }

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(Double(truncating: (currentAmount / targetAmount) as NSDecimalNumber), 1)
    }

    var isComplete: Bool {
        currentAmount >= targetAmount && targetAmount > 0
    }

    var remaining: Decimal {
        max(targetAmount - currentAmount, 0)
    }
}
