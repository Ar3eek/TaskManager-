import SwiftData
import SwiftUI

struct QuickLinksListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \QuickLink.createdAt, order: .reverse) private var links: [QuickLink]

    @State private var showingAdd = false
    @State private var linkToEdit: QuickLink?

    var body: some View {
        List {
            if links.isEmpty {
                ContentUnavailableView {
                    Label("Brak skrótów", systemImage: "link")
                } description: {
                    Text("Zapisuj strony, loginy i szybki dostęp do kont.")
                }
            } else {
                ForEach(links) { link in
                    QuickLinkRowView(link: link)
                        .contentShape(Rectangle())
                        .onTapGesture { linkToEdit = link }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(link)
                            } label: {
                                Label("Usuń", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("Skróty i linki")
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
            QuickLinkFormView()
        }
        .sheet(item: $linkToEdit) { link in
            QuickLinkFormView(link: link)
        }
    }
}

struct QuickLinkRowView: View {
    let link: QuickLink

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "link.circle.fill")
                    .foregroundStyle(AppTheme.warning)
                Text(link.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if let url = URL(string: link.url), !link.url.isEmpty {
                    Link(destination: url) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                    }
                }
            }

            if !link.url.isEmpty {
                Text(link.url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if !link.username.isEmpty {
                Label(link.username, systemImage: "person")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        QuickLinksListView()
    }
    .modelContainer(for: QuickLink.self, inMemory: true)
}
