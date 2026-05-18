import SwiftUI

// MARK: - Dashboard Hero

struct DashboardHeroView: View {
    @Environment(\.layoutMetrics) private var metrics
    let stats: DashboardStats

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Text("Pozostało do spłaty")
                .font(AppFont.caption(.medium))
                .foregroundStyle(.white.opacity(0.8))

            Text(Formatters.currency(stats.totalRemaining))
                .font(AppFont.metric(metrics.heroAmountSize))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.65)
                .lineLimit(1)

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
        .padding(metrics.cardInset + 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
    }
}

struct HeroStatPill: View {
    let value: String
    let label: String
    let icon: String
    var highlight: Bool = false

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(highlight ? Color.yellow.opacity(0.95) : .white.opacity(0.9))
            Text(value)
                .font(AppFont.callout(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(AppFont.caption2())
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - Section Header

struct SectionHeaderView: View {
    let title: String
    var action: (() -> Void)?
    var actionLabel: String?

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(AppFont.headline())
                .foregroundStyle(.primary)
            Spacer()
            if let action, let actionLabel {
                Button(action: action) {
                    Text(actionLabel)
                        .font(AppFont.caption(.semibold))
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}

// MARK: - Progress Ring

struct ProgressRingView: View {
    let progress: Double
    var lineWidth: CGFloat = 5
    var size: CGFloat = 44
    var tint: Color = AppTheme.primary

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.12), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.4), value: progress)

            Text("\(Int(progress * 100))%")
                .font(.system(size: max(size * 0.19, 8), weight: .semibold, design: .rounded))
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
            case .neutral: AppTheme.textTertiary
            }
        }

        var background: Color { foreground.opacity(0.1) }
    }

    let style: Style

    var body: some View {
        Text(style.label)
            .font(AppFont.caption2(.semibold))
            .foregroundStyle(style.foreground)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 8)
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
                            .font(AppFont.caption(.semibold))
                            .foregroundStyle(selection == option ? .white : AppTheme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selection == option
                                    ? AnyShapeStyle(AppTheme.primary)
                                    : AnyShapeStyle(AppTheme.cardBackground)
                            )
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .strokeBorder(
                                        selection == option ? Color.clear : AppTheme.border,
                                        lineWidth: 1
                                    )
                            }
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
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(AppTheme.primary.opacity(0.5))
                .symbolRenderingMode(.hierarchical)
                .frame(width: 56, height: 56)
                .background(AppTheme.primarySoft)
                .clipShape(Circle())

            VStack(spacing: 6) {
                Text(title)
                    .font(AppFont.body(.semibold))
                Text(message)
                    .font(AppFont.caption())
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 240)
            }
        }
        .padding(AppTheme.spacingXL)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Form Field

struct FormField<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(AppFont.labelUppercase)
                .foregroundStyle(AppTheme.textTertiary)
                .tracking(0.5)
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
        .font(AppFont.body())
        .padding(AppTheme.spacingM)
        .background(AppTheme.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .strokeBorder(AppTheme.border, lineWidth: 1)
        }
    }
}

// MARK: - List row container

struct ProListRow<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(AppTheme.spacingM)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .strokeBorder(AppTheme.border, lineWidth: 1)
            }
    }
}
