import SwiftUI

// MARK: - Colors

enum AppTheme {
    static let cornerRadius: CGFloat = 10
    static let cardCornerRadius: CGFloat = 14
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32

    static let primary = Color("BrandPrimary")
    static let primaryMuted = Color("BrandPrimaryMuted")
    static let primarySoft = Color("BrandPrimarySoft")
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let danger = Color("Danger")
    static let appBackground = Color("AppBackground")
    static let cardBackground = Color("CardBackground")
    static let elevatedBackground = Color("ElevatedBackground")
    static let border = Color("Border")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")

    static let accentLoans = Color("AccentLoans")
    static let accentNotebook = Color("AccentNotebook")
    static let accentGoals = Color("AccentGoals")
    static let accentLinks = Color("AccentLinks")

    static let heroGradient = LinearGradient(
        colors: [Color("BrandGradientStart"), Color("BrandGradientEnd")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtleGradient = LinearGradient(
        colors: [primary.opacity(0.08), primary.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

}

// MARK: - Typography

enum AppFont {
    static func largeTitle(_ weight: Font.Weight = .bold) -> Font {
        .system(.title2, design: .rounded, weight: weight)
    }

    static func title(_ weight: Font.Weight = .semibold) -> Font {
        .system(.title3, design: .default, weight: weight)
    }

    static func headline(_ weight: Font.Weight = .semibold) -> Font {
        .system(.headline, design: .default, weight: weight)
    }

    static func body(_ weight: Font.Weight = .regular) -> Font {
        .system(.subheadline, design: .default, weight: weight)
    }

    static func callout(_ weight: Font.Weight = .medium) -> Font {
        .system(.footnote, design: .default, weight: weight)
    }

    static func caption(_ weight: Font.Weight = .regular) -> Font {
        .system(.caption, design: .default, weight: weight)
    }

    static func caption2(_ weight: Font.Weight = .medium) -> Font {
        .system(.caption2, design: .default, weight: weight)
    }

    static func metric(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static let labelUppercase = Font.caption2.weight(.semibold)
}

// MARK: - Layout

enum LayoutSize {
    case compact, regular, expanded
}

struct LayoutMetrics {
    let size: LayoutSize
    let containerWidth: CGFloat

    var isCompact: Bool { size == .compact }

    var contentMaxWidth: CGFloat? {
        switch size {
        case .compact: nil
        case .regular: 560
        case .expanded: 720
        }
    }

    var moduleMaxWidth: CGFloat {
        switch size {
        case .compact: .infinity
        case .regular: 680
        case .expanded: 900
        }
    }

    var horizontalPadding: CGFloat {
        switch size {
        case .compact: 16
        case .regular: 24
        case .expanded: 32
        }
    }

    var cardInset: CGFloat { size == .compact ? 14 : 16 }
    var sectionSpacing: CGFloat { size == .compact ? 16 : 20 }
    var progressRingSize: CGFloat { size == .compact ? 38 : 44 }
    var heroProgressRingSize: CGFloat { size == .compact ? 48 : 56 }
    var moduleMinHeight: CGFloat { size == .compact ? 128 : 140 }

    var moduleColumnCount: Int {
        switch size {
        case .compact: containerWidth < 340 ? 1 : 2
        case .regular: 2
        case .expanded: containerWidth > 900 ? 4 : 2
        }
    }

    var screenTitle: Font { size == .compact ? AppFont.title(.bold) : AppFont.largeTitle() }
    var sectionTitle: Font { AppFont.headline() }
    var cardTitle: Font { AppFont.body(.semibold) }
    var bodyStrong: Font { AppFont.callout(.semibold) }
    var captionStrong: Font { AppFont.caption(.medium) }
    var metricValue: Font { AppFont.body(.bold) }
    var heroAmountSize: CGFloat { size == .compact ? 20 : 24 }

    static let compact = LayoutMetrics(size: .compact, containerWidth: 390)
    static let regular = LayoutMetrics(size: .regular, containerWidth: 600)
    static let expanded = LayoutMetrics(size: .expanded, containerWidth: 1000)

    static func resolve(width: CGFloat, horizontalSizeClass: UserInterfaceSizeClass?) -> LayoutMetrics {
        let size: LayoutSize
        if width >= 900 || horizontalSizeClass == .regular && width >= 700 {
            size = .expanded
        } else if width >= 500 {
            size = .regular
        } else {
            size = .compact
        }
        return LayoutMetrics(size: size, containerWidth: width)
    }

    static func from(horizontalSizeClass: UserInterfaceSizeClass?) -> LayoutMetrics {
        horizontalSizeClass == .compact ? .compact : .regular
    }
}

private struct LayoutMetricsKey: EnvironmentKey {
    static let defaultValue = LayoutMetrics.compact
}

extension EnvironmentValues {
    var layoutMetrics: LayoutMetrics {
        get { self[LayoutMetricsKey.self] }
        set { self[LayoutMetricsKey.self] = newValue }
    }
}

// MARK: - Dashboard stats

struct DashboardStats {
    let totalRemaining: Decimal
    let totalPaid: Decimal
    let overdueCount: Int
    let dueSoonCount: Int
    let activeLoansCount: Int

    init(loans: [Loan]) {
        activeLoansCount = loans.count
        totalRemaining = loans.reduce(0) { $0 + $1.remainingAmount }
        totalPaid = loans.reduce(0) { $0 + $1.paidAmount }
        let unpaid = loans.flatMap(\.unpaidInstallments)
        overdueCount = unpaid.filter(\.isOverdue).count
        dueSoonCount = unpaid.filter(\.isDueSoon).count
    }
}

// MARK: - View modifiers

extension View {
    func appScreenBackground() -> some View {
        background(AppTheme.appBackground.ignoresSafeArea())
    }

    func appCard(inset: CGFloat? = nil, bordered: Bool = true) -> some View {
        modifier(AppCardModifier(inset: inset, bordered: bordered))
    }

    func responsiveContentWidth(_ maxWidth: CGFloat? = nil) -> some View {
        modifier(ResponsiveWidthModifier(maxWidth: maxWidth))
    }

    func proSectionLabel(_ text: String) -> some View {
        padding(.top, 4)
            .overlay(alignment: .topLeading) {
                Text(text.uppercased())
                    .font(AppFont.labelUppercase)
                    .foregroundStyle(AppTheme.textTertiary)
                    .tracking(0.6)
            }
            .padding(.top, 20)
    }
}

private struct AppCardModifier: ViewModifier {
    @Environment(\.layoutMetrics) private var metrics
    @Environment(\.colorScheme) private var colorScheme

    var inset: CGFloat?
    var bordered: Bool

    func body(content: Content) -> some View {
        content
            .padding(inset ?? metrics.cardInset)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
            .overlay {
                if bordered {
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                        .strokeBorder(AppTheme.border, lineWidth: 1)
                }
            }
            .shadow(
                color: colorScheme == .dark ? .clear : .black.opacity(0.04),
                radius: 12,
                y: 4
            )
    }
}

private struct ResponsiveWidthModifier: ViewModifier {
    @Environment(\.layoutMetrics) private var metrics
    var maxWidth: CGFloat?

    func body(content: Content) -> some View {
        let limit = maxWidth ?? metrics.contentMaxWidth
        if let limit {
            content
                .frame(maxWidth: limit)
                .frame(maxWidth: .infinity)
        } else {
            content
                .frame(maxWidth: .infinity)
        }
    }
}

struct LayoutReader<Content: View>: View {
    @ViewBuilder let content: (LayoutMetrics) -> Content

    var body: some View {
        GeometryReader { geo in
            content(LayoutMetrics.resolve(
                width: geo.size.width,
                horizontalSizeClass: nil
            ))
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.body(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(isDisabled ? AppTheme.textTertiary.opacity(0.4) : AppTheme.primary)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.body(.medium))
            .foregroundStyle(AppTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.primarySoft.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .strokeBorder(AppTheme.border, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct DeleteConfirmationModifier: ViewModifier {
    @Binding var loan: Loan?
    let onConfirm: (Loan) -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                "Usunąć kredyt?",
                isPresented: Binding(
                    get: { loan != nil },
                    set: { if !$0 { loan = nil } }
                ),
                presenting: loan
            ) { loan in
                Button("Usuń", role: .destructive) { onConfirm(loan) }
                Button("Anuluj", role: .cancel) { self.loan = nil }
            } message: { loan in
                Text("„\(loan.name)” i wszystkie raty zostaną trwale usunięte.")
            }
    }
}

extension View {
    func loanDeleteConfirmation(
        loan: Binding<Loan?>,
        onConfirm: @escaping (Loan) -> Void
    ) -> some View {
        modifier(DeleteConfirmationModifier(loan: loan, onConfirm: onConfirm))
    }
}
