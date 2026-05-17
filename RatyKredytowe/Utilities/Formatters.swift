import Foundation

enum Formatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static func currency(_ value: Decimal) -> String {
        currency.string(from: value as NSDecimalNumber) ?? "\(value) zł"
    }

    static func date(_ value: Date) -> String {
        mediumDate.string(from: value)
    }
}
