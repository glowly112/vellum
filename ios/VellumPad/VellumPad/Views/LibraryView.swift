import SwiftData
import SwiftUI

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Page.updatedAt, order: .reverse) private var pages: [Page]
    @State private var query = ""
    @State private var path: [UUID] = []
    @State private var composeLock = false

    private var groups: [(section: LibrarySection, pages: [Page])] {
        LibraryGrouping.group(pages: pages, query: query)
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if groups.isEmpty {
                    emptyState
                } else {
                    pageList
                }
            }
            .background(VellumPalette.desk.ignoresSafeArea(.container))
            .navigationTitle(PageCopy.greeting())
            .navigationSubtitle(subtitle)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: UUID.self) { id in
                EditorView(pageID: id)
            }
            .searchable(text: $query, placement: .automatic, prompt: "Search pages")
            .toolbar {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button("New page", systemImage: "square.and.pencil") {
                        startPage()
                    }
                    .accessibilityLabel("New page")
                }
            }
            .onChange(of: path.count) { _, _ in
                composeLock = false
            }
        }
    }

    private var subtitle: String {
        let count = pages.count
        let date = Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))
        let noun = count == 1 ? "page" : "pages"
        return "\(date)  ·  \(count) \(noun)"
    }

    private var pageList: some View {
        List {
            ForEach(groups, id: \.section) { group in
                Section {
                    ForEach(group.pages, id: \.pageID) { page in
                        Button {
                            path.append(page.pageID)
                        } label: {
                            PaperRow(page: page)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                } header: {
                    Text(group.section.title)
                        .font(VellumFonts.ui(.caption, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(VellumPalette.inkSoft)
                        .textCase(.uppercase)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .listSectionSpacing(22)
    }

    @ViewBuilder
    private var emptyState: some View {
        let searching = !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ContentUnavailableView {
            Label(
                searching ? "Nothing matches" : "The desk is clear",
                systemImage: searching ? "magnifyingglass" : "doc"
            )
        } description: {
            Text(
                searching
                    ? "Try a different word, or start a new page."
                    : "A blank sheet, waiting. Start whenever you like."
            )
        } actions: {
            if searching {
                Button("Clear search") { query = "" }
                    .frame(minHeight: HitTarget.minimum)
            }
            Button("Start a page") { startPage() }
                .frame(minHeight: HitTarget.minimum)
        }
    }

    private func startPage() {
        if composeLock { return }
        if let newest = pages.first,
           ComposePolicy.reuseBlankPage(
            createdAt: newest.createdAt,
            title: newest.title,
            body: newest.body
           ) {
            if path.last != newest.pageID {
                path.append(newest.pageID)
            }
            return
        }

        composeLock = true
        let style = StylePreferences.last
        let page = Page(
            title: "",
            body: "",
            createdAt: .now,
            updatedAt: .now,
            fontId: style.typeface.rawValue,
            paperId: style.paper.rawValue,
            inkId: style.resolvedInk.rawValue,
            sizeId: style.size.rawValue
        )
        modelContext.insert(page)
        try? modelContext.save()
        path.append(page.pageID)
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: Page.self, inMemory: true)
}
