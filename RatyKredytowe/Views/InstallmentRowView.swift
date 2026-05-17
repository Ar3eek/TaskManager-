import SwiftData
import SwiftUI

struct InstallmentRowView: View {
    @Environment(\.layoutMetrics) private var metrics
    @Bindable var installment: Installment

    private var badgeStyle: StatusBadge.Style? {
        if installment.isPaid { return .paid }
        if installment.isOverdue { return .overdue }
        if installment.isDueSoon { return .dueSoon }
        return nil
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingS) {
            payButton

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(Formatters.date(installment.dueDate))
                        .font(metrics.bodyStrong)
                        .foregroundStyle(installment.isPaid ? .secondary : .primary)
                        .strikethrough(installment.isPaid, color: .secondary)
                        .lineLimit(1)

                    if let badgeStyle = badgeStyle {
                        StatusBadge(style: badgeStyle)
                    }
                }

                if installment.isPaid, let paidDate = installment.paidDate {
                    Text("Spłacono \(Formatters.date(paidDate))")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.success)
                }

                if !installment.note.isEmpty {
                    Text(installment.note)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 4)

            Text(Formatters.currency(installment.amount))
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(installment.isPaid ? .secondary : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(metrics.cardInset)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .strokeBorder(
                    installment.isOverdue && !installment.isPaid
                        ? AppTheme.danger.opacity(0.3)
                        : Color.clear,
                    lineWidth: 1
                )
        }
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
                            ? AppTheme.success.opacity(0.15)
                            : AppTheme.primarySoft.opacity(0.5)
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: installment.isPaid ? "checkmark" : "circle")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(installment.isPaid ? AppTheme.success : payButtonColor)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(installment.isPaid ? "Oznacz jako niespłacone" : "Oznacz jako spłacone")
    }

    private var payButtonColor: Color {
        if installment.isOverdue { return AppTheme.danger }
        if installment.isDueSoon { return AppTheme.warning }
        return AppTheme.primary
    }

    private func togglePaid() {
        withAnimation(.snappy) {
            if installment.isPaid {
                installment.markUnpaid()
            } else {
                installment.markPaid()
            }
        }
    }
}
