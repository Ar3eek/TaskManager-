import SwiftData
import SwiftUI

struct NotebookListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.layoutMetrics) private var metrics

    @Query(sort: \NotebookEntry.updatedAt, order: .reverse) private var entries: [NotebookEntry]

    @State private var searchText = ""
    @State private var filterType: NotebookEntryType?
    @State private var showingAdd = false
    @State private var entryToEdit: NotebookEntry?

    private var filtered: [NotebookEntry] {
        entries.filter { entry in
            let matchesSearch = searchText.isEmpty
                || entry.title.localizedCaseInsensitiveContains(searchText)
                || entry.content.localizedCaseInsensitiveContains(searchText)
            let matchesType = filterType == nil || entry.entryType == filterType
            return matchesSearch && matchesType
        }
        .sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned && !rhs.isPinned }
            return lhs.updatedAt > rhs.updatedAt
        }
    }

    var body: some View {
        List {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "Wszystkie", isSelected: filterType == nil) {
                            filterType = nil
                        }
                        ForEach(NotebookEntryType.allCases) { type in
                            FilterChip(title: type.rawValue, isSelected: filterType == type) {
                                filterType = type
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }

            if filtered.isEmpty {
                ContentUnavailableView {
                    Label("Brak wpisów", systemImage: "book.closed")
                } description: {
                    Text("Zapisuj notatki, hasła i rzeczy do zrobienia.")
                }
            } else {
                ForEach(filtered) { entry in
                    NotebookRowView(entry: entry)
                        .contentShape(Rectangle())
                        .onTapGesture { entryToEdit = entry }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                modelContext.delete(entry)
                            } label: {
                                Label("Usuń", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Szukaj w notatniku…")
        .navigationTitle("Notatnik")
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
            NotebookEntryFormView()
        }
        .sheet(item: $entryToEdit) { entry in
            NotebookEntryFormView(entry: entry)
        }
    }
}

struct NotebookRowView: View {
    @Bindable var entry: NotebookEntry
    @State private var isRevealed = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if entry.entryType == .todo {
                Button {
                    entry.isCompleted.toggle()
                    entry.updatedAt = .now
                } label: {
                    Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(entry.isCompleted ? AppTheme.success : .secondary)
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: entry.entryType.icon)
                    .font(.body)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 28)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.title)
                        .font(.subheadline.weight(.semibold))
                        .strikethrough(entry.isCompleted && entry.entryType == .todo)
                        .lineLimit(1)
                    if entry.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.warning)
                    }
                }

                if entry.entryType == .password {
                    HStack {
                        Text(isRevealed ? entry.content : String(repeating: "•", count: min(entry.content.count, 12)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button {
                            isRevealed.toggle()
                        } label: {
                            Image(systemName: isRevealed ? "eye.slash" : "eye")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                } else if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Text(entry.entryType.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.caption(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary : AppTheme.cardBackground)
                .foregroundStyle(isSelected ? .white : AppTheme.textSecondary)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : AppTheme.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        NotebookListView()
    }
    .modelContainer(for: NotebookEntry.self, inMemory: true)
}
