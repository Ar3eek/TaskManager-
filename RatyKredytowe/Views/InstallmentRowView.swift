import SwiftData
import SwiftUI

struct InstallmentRowView: View {
    @Bindable var installment: Installment

    private var badgeStyle: StatusBadge.Style? {
        if installment.isPaid { return .paid }
        if installment.isOverdue { return .overdue }
        if installment.isDueSoon { return .dueSoon }
        return nil
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            payButton

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(Formatters.date(installment.dueDate))
                        .font(AppFont.body(.semibold))
                        .foregroundStyle(installment.isPaid ? AppTheme.textSecondary : .primary)
                        .strikethrough(installment.isPaid, color: AppTheme.textTertiary)
                        .lineLimit(1)

                    if let badgeStyle = badgeStyle {
                        StatusBadge(style: badgeStyle)
                    }
                }

                if installment.isPaid, let paidDate = installment.paidDate {
                    Text("Spłacono \(Formatters.date(paidDate))")
                        .font(AppFont.caption2())
                        .foregroundStyle(AppTheme.success)
                }

                if !installment.note.isEmpty {
                    Text(installment.note)
                        .font(AppFont.caption2())
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 4)

            Text(Formatters.currency(installment.amount))
                .font(AppFont.callout(.bold))
                .monospacedDigit()
                .foregroundStyle(installment.isPaid ? AppTheme.textSecondary : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .appCard(bordered: installment.isOverdue && !installment.isPaid)
        .opacity(installment.isPaid ? 0.88 : 1)
        .animation(.snappy, value: installment.isPaid)
        #if os(iOS)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button { togglePaid() } label: {
                Label(
                    installment.isPaid ? "Cofnij" : "Spłacono",
                    systemImage: installment.isPaid ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(installment.isPaid ? AppTheme.warning : AppTheme.success)
        }
        #endif
    }

    private var payButton: some View {
        Button { togglePaid() } label: {
            ZStack {
                Circle()
                    .fill(
                        installment.isPaid
                            ? AppTheme.success.opacity(0.12)
                            : AppTheme.primarySoft
                    )
                    .frame(width: 34, height: 34)

                Image(systemName: installment.isPaid ? "checkmark" : "circle")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(installment.isPaid ? AppTheme.success : payButtonColor)
            }
        }
        .buttonStyle(.plain)
    }

    private var payButtonColor: Color {
        if installment.isOverdue { return AppTheme.danger }
        if installment.isDueSoon { return AppTheme.warning }
        return AppTheme.primary
    }

    private func togglePaid() {
        withAnimation(.snappy) {
            if installment.isPaid { installment.markUnpaid() }
            else { installment.markPaid() }
        }
    }
}
