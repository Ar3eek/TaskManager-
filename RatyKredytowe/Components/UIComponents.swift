import SwiftUI

// MARK: - Dashboard Hero

struct DashboardHeroView: View {
    @Environment(\.layoutMetrics) private var metrics
    let stats: DashboardStats

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Pozostało do spłaty")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))

                Text(Formatters.currency(stats.totalRemaining))
                    .font(.system(size: metrics.heroAmountSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.65)
                    .lineLimit(1)
            }

            HStack(spacing: AppTheme.spacingS) {
                HeroStatPill(value: "\(stats.activeLoansCount)", label: "Kredyty", icon: "building.columns")
                HeroStatPill(
                    value: "\(stats.overdueCount)",
                    label: "Zaległe",
                    icon: "exclamationmark.triangle",
                    highlight: stats.overdueCount > 0
                )
                HeroStatPill(
                    value: "\(stats.dueSoonCount)",
                    label: "W 7 dni",
                    icon: "clock",
                    highlight: stats.dueSoonCount > 0
                )
            }
        }
        .padding(metrics.cardInset + 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .shadow(color: AppTheme.primary.opacity(0.2), radius: 12, y: 6)
    }
}

struct HeroStatPill: View {
    let value: String
    let label: String
    let icon: String
    var highlight: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(highlight ? Color.yellow : .white.opacity(0.9))
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Section Header

struct SectionHeaderView: View {
    @Environment(\.layoutMetrics) private var metrics

    let title: String
    var action: (() -> Void)?
    var actionLabel: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(metrics.sectionTitle)
                .foregroundStyle(.primary)
            Spacer()
            if let action, let actionLabel {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}

// MARK: - Progress Ring

struct ProgressRingView: View {
    let progress: Double
    var lineWidth: CGFloat = 6
    var size: CGFloat = 48
    var tint: Color = AppTheme.primary

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.4), value: progress)

            Text("\(Int(progress * 100))%")
                .font(.system(size: max(size * 0.2, 9), weight: .bold, design: .rounded))
                .foregroundStyle(tint)
                .minimumScaleFactor(0.7)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    enum Style {
        case overdue, dueSoon, paid, neutral

        var label: String {
            switch self {
            case .overdue: "Zaległa"
            case .dueSoon: "Wkrótce"
            case .paid: "Spłacona"
            case .neutral: ""
            }
        }

        var foreground: Color {
            switch self {
            case .overdue: AppTheme.danger
            case .dueSoon: AppTheme.warning
            case .paid: AppTheme.success
            case .neutral: .secondary
            }
        }

        var background: Color { foreground.opacity(0.12) }
    }

    let style: Style

    var body: some View {
        Text(style.label)
            .font(.caption2.weight(.bold))
            .foregroundStyle(style.foreground)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(style.background)
            .clipShape(Capsule())
    }
}

// MARK: - Filter Chips

struct FilterChipBar<T: Hashable & Identifiable>: View where T: RawRepresentable, T.RawValue == String {
    @Binding var selection: T
    let options: [T]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingS) {
                ForEach(options) { option in
                    Button {
                        withAnimation(.snappy) { selection = option }
                    } label: {
                        Text(option.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(selection == option ? .white : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selection == option
                                    ? AnyShapeStyle(AppTheme.heroGradient)
                                    : AnyShapeStyle(AppTheme.cardBackground)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(AppTheme.primary.opacity(0.6))
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, AppTheme.spacingL)
            }
        }
        .padding(AppTheme.spacingL)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Form Field

struct FormField<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            content
        }
    }
}

struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    #if os(iOS)
    var keyboardType: UIKeyboardType = .default
    #endif

    var body: some View {
        Group {
            #if os(iOS)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
            #else
            TextField(placeholder, text: $text)
            #endif
        }
        .font(.subheadline)
        .padding(AppTheme.spacingM)
        .background(AppTheme.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
    }
}

// MARK: - Upcoming Row Card

struct UpcomingPaymentCard: View {
    @Environment(\.layoutMetrics) private var metrics

    let installment: Installment

    private var status: StatusBadge.Style {
        if installment.isOverdue { return .overdue }
        if installment.isDueSoon { return .dueSoon }
        return .neutral
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingS) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.primarySoft.opacity(0.6))
                    .frame(width: 36, height: 36)
                Image(systemName: "calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(installment.loan?.name ?? "Kredyt")
                    .font(metrics.bodyStrong)
                    .lineLimit(1)
                Text(Formatters.date(installment.dueDate))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 2) {
                Text(Formatters.currency(installment.amount))
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
                if status != .neutral {
                    StatusBadge(style: status)
                }
            }
        }
        .padding(metrics.cardInset)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 4, y: 1)
    }
}
