import SwiftUI

struct HomeView: View {
    @Environment(\.layoutMetrics) private var metrics

    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: AppTheme.spacingM),
            count: metrics.moduleColumnCount
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
                headerCard

                Text("Wybierz moduł")
                    .font(metrics.sectionTitle)
                    .foregroundStyle(.primary)

                Text("Wybierz, z czego chcesz korzystać")
                    .font(AppFont.callout())
                    .foregroundStyle(AppTheme.textSecondary)

                LazyVGrid(columns: gridColumns, spacing: AppTheme.spacingM) {
                    ForEach(AppModule.allCases) { module in
                        NavigationLink(value: module) {
                            ModuleCard(module: module)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, AppTheme.spacingL)
            .frame(maxWidth: metrics.moduleMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .appScreenBackground()
        .navigationTitle("Tasks")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    private var headerCard: some View {
        HStack(alignment: .center, spacing: AppTheme.spacingM) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(AppFont.caption(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                Text("Centrum spraw")
                    .font(metrics.screenTitle)
                    .foregroundStyle(.primary)
                Text("Finanse, notatki i zadania w jednym miejscu.")
                    .font(AppFont.caption())
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.primary.opacity(0.85))
                .frame(width: 52, height: 52)
                .background(AppTheme.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .appCard()
        .background {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .fill(AppTheme.subtleGradient)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Dzień dobry"
        case 12..<18: return "Witaj"
        default: return "Dobry wieczór"
        }
    }
}

struct ModuleCard: View {
    @Environment(\.layoutMetrics) private var metrics

    let module: AppModule

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            HStack {
                Image(systemName: module.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(module.accent)
                    )
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textTertiary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(module.rawValue)
                    .font(AppFont.body(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.9)

                Text(module.subtitle)
                    .font(AppFont.caption2())
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)
        }
        .padding(metrics.cardInset)
        .frame(maxWidth: .infinity, minHeight: metrics.moduleMinHeight, alignment: .topLeading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .strokeBorder(AppTheme.border, lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environment(\.layoutMetrics, .compact)
    }
}
