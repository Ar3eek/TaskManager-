import SwiftUI

struct LoanCardView: View {
    @Environment(\.layoutMetrics) private var metrics

    let loan: Loan

    private var progress: Double {
        guard loan.totalCount > 0 else { return 0 }
        return Double(loan.paidCount) / Double(loan.totalCount)
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingS) {
            ProgressRingView(
                progress: progress,
                lineWidth: 5,
                size: metrics.progressRingSize,
                tint: loan.isFullyPaid ? AppTheme.success : AppTheme.primary
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(loan.name)
                        .font(metrics.cardTitle)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if loan.isFullyPaid {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(AppTheme.success)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }

                if loan.totalCount > 0 {
                    HStack {
                        Text("\(loan.paidCount)/\(loan.totalCount) rat")
                        Spacer()
                        Text(Formatters.currency(loan.remainingAmount))
                            .font(metrics.captionStrong)
                            .foregroundStyle(AppTheme.primary)
                            .monospacedDigit()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    Text("Brak harmonogramu")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let next = loan.nextDueInstallment {
                    HStack(spacing: 4) {
                        Image(systemName: next.isOverdue ? "exclamationmark.circle.fill" : "clock")
                            .font(.caption2)
                        Text("Następna: \(Formatters.date(next.dueDate))")
                            .font(.caption2)
                    }
                    .foregroundStyle(next.isOverdue ? AppTheme.danger : .secondary)
                }
            }
        }
        .padding(metrics.cardInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .strokeBorder(AppTheme.border, lineWidth: 1)
        }
    }
}
