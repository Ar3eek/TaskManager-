import SwiftData
import SwiftUI

struct GoalsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.layoutMetrics) private var metrics

    @Query(sort: \SavingsGoal.createdAt, order: .reverse) private var goals: [SavingsGoal]

    @State private var showingAdd = false
    @State private var goalToEdit: SavingsGoal?

    var body: some View {
        ScrollView {
            VStack(spacing: metrics.sectionSpacing) {
                if goals.isEmpty {
                    EmptyStateView(
                        icon: "target",
                        title: "Brak celów",
                        message: "Ustal cel oszczędnościowy — wakacje, poduszka finansowa, zakup.",
                        buttonTitle: "Dodaj cel",
                        action: { showingAdd = true }
                    )
                    .appCard()
                } else {
                    ForEach(goals) { goal in
                        GoalCardView(goal: goal)
                            .onTapGesture { goalToEdit = goal }
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(goal)
                                } label: {
                                    Label("Usuń", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(metrics.horizontalPadding)
            .responsiveContentWidth()
        }
        .scrollIndicators(.hidden)
        .appScreenBackground()
        .navigationTitle("Cele oszczędnościowe")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAdd = true } label: {
                    Label("Dodaj", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            GoalFormView()
        }
        .sheet(item: $goalToEdit) { goal in
            GoalFormView(goal: goal)
        }
    }
}

struct GoalCardView: View {
    let goal: SavingsGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.name)
                    .font(AppFont.headline())
                Spacer()
                if goal.isComplete {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(AppTheme.success)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Zebrano")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(Formatters.currency(goal.currentAmount))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.success)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Cel")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(Formatters.currency(goal.targetAmount))
                        .font(.subheadline.weight(.bold))
                }
            }

            ProgressView(value: goal.progress)
                .tint(goal.isComplete ? AppTheme.success : AppTheme.primary)

            HStack {
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Brakuje: \(Formatters.currency(goal.remaining))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let date = goal.targetDate {
                Label("Termin: \(Formatters.date(date))", systemImage: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .appCard()
    }
}

#Preview {
    NavigationStack {
        GoalsListView()
    }
    .modelContainer(for: SavingsGoal.self, inMemory: true)
}
