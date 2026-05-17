import SwiftUI

enum AppTheme {
    static let cornerRadius: CGFloat = 12
    static let cardCornerRadius: CGFloat = 14
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24

    static let primary = Color("BrandPrimary")
    static let primarySoft = Color("BrandPrimarySoft")
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let danger = Color("Danger")
    static let appBackground = Color("AppBackground")
    static let cardBackground = Color("CardBackground")
    static let elevatedBackground = Color("ElevatedBackground")

    static let heroGradient = LinearGradient(
        colors: [Color("BrandGradientStart"), Color("BrandGradientEnd")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardShadow = Color.black.opacity(0.05)
}

struct LayoutMetrics {
    let isCompact: Bool

    var contentMaxWidth: CGFloat? { isCompact ? nil : 520 }
    var horizontalPadding: CGFloat { isCompact ? 12 : 20 }
    var cardInset: CGFloat { isCompact ? 12 : 14 }
    var sectionSpacing: CGFloat { isCompact ? 12 : 16 }
    var progressRingSize: CGFloat { isCompact ? 40 : 48 }
    var heroProgressRingSize: CGFloat { isCompact ? 52 : 60 }
    var fabSize: CGFloat { isCompact ? 48 : 52 }
    var heroAmountSize: CGFloat { isCompact ? 22 : 26 }

    var screenTitle: Font { isCompact ? .title3.weight(.bold) : .title2.weight(.bold) }
    var sectionTitle: Font { isCompact ? .subheadline.weight(.semibold) : .headline.weight(.semibold) }
    var cardTitle: Font { isCompact ? .subheadline.weight(.semibold) : .headline }
    var bodyStrong: Font { isCompact ? .footnote.weight(.semibold) : .subheadline.weight(.semibold) }
    var captionStrong: Font { .caption.weight(.medium) }
    var metricValue: Font { isCompact ? .subheadline.weight(.bold) : .headline.weight(.bold) }

    static let compact = LayoutMetrics(isCompact: true)
    static let regular = LayoutMetrics(isCompact: false)

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

extension View {
    func appScreenBackground() -> some View {
        background(AppTheme.appBackground.ignoresSafeArea())
    }

    func appCard(inset: CGFloat? = nil) -> some View {
        modifier(AppCardModifier(inset: inset))
    }

    @ViewBuilder
    func responsiveContentWidth() -> some View {
        modifier(ResponsiveWidthModifier())
    }
}

private struct AppCardModifier: ViewModifier {
    @Environment(\.layoutMetrics) private var metrics
    var inset: CGFloat?

    func body(content: Content) -> some View {
        content
            .padding(inset ?? metrics.cardInset)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
            .shadow(color: AppTheme.cardShadow, radius: 8, y: 2)
    }
}

private struct ResponsiveWidthModifier: ViewModifier {
    @Environment(\.layoutMetrics) private var metrics

    func body(content: Content) -> some View {
        if let maxWidth = metrics.contentMaxWidth {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isDisabled {
                        Color.gray.opacity(0.35)
                    } else {
                        AppTheme.heroGradient
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(AppTheme.primarySoft.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
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
                Button("Usuń", role: .destructive) {
                    onConfirm(loan)
                }
                Button("Anuluj", role: .cancel) {
                    self.loan = nil
                }
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
