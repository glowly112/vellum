import SwiftData
import SwiftUI

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Page.updatedAt, order: .reverse) private var pages: [Page]
    @State private var query = ""
    @State private var path: [UUID] = []
    @State private var composeLock = false
    @State private var pagePendingDelete: Page?

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
            .toolbarTitleDisplayMode(.large)
            .navigationDestination(for: UUID.self) { id in
                EditorView(pageID: id)
            }
            .searchable(text: $query, placement: .automatic, prompt: "Search pages")
            .toolbar {
                // Fraunces italic greeting without UINavigationBarAppearance
                // (that flatten iOS 26 glass on search + compose).
                ToolbarItem(placement: .largeTitle) {
                    Text(PageCopy.greeting())
                        .font(VellumFonts.display())
                        .foregroundStyle(VellumPalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityHidden(true)
                }
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button("New page", systemImage: LibraryLook.composeSystemImage) {
                        startPage()
                    }
                    .accessibilityLabel("New page")
                }
            }
            .onChange(of: path.count) { _, _ in
                composeLock = false
            }
            .alert("Delete this page?", isPresented: Binding(
                get: { pagePendingDelete != nil },
                set: { if !$0 { pagePendingDelete = nil } }
            )) {
                Button("Delete page", role: .destructive) {
                    if let page = pagePendingDelete {
                        deletePage(page)
                    }
                }
                Button("Cancel", role: .cancel) {
                    pagePendingDelete = nil
                }
            } message: {
                Text("This page will be removed from this device. It cannot be undone.")
            }
            #if DEBUG
            .onAppear {
                openFirstPageIfRequested()
            }
            .onChange(of: pages.count) { _, _ in
                openFirstPageIfRequested()
            }
            #endif
        }
    }

    #if DEBUG
    private func openFirstPageIfRequested() {
        guard DebugOpenFirst.shouldOpenFirstPage() else { return }
        guard path.isEmpty else { return }
        guard let id = DebugOpenFirst.pageToOpen(from: pages.map(\.pageID)) else { return }
        path.append(id)
    }
    #endif

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
                            PaperSheet(page: page)
                        }
                        .buttonStyle(PaperSheetButtonStyle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                pagePendingDelete = page
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button(page.pinOn ? "Unpin" : "Pin", systemImage: page.pinOn ? "pin.slash" : "pin") {
                                togglePin(page)
                            }
                            .tint(VellumPalette.inkSoft)
                        }
                        .contextMenu {
                            Button(page.pinOn ? "Unpin" : "Pin", systemImage: page.pinOn ? "pin.slash" : "pin") {
                                togglePin(page)
                            }
                            Button("Delete page", systemImage: "trash", role: .destructive) {
                                pagePendingDelete = page
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
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
                LibraryEmpty.headline(searching: searching),
                systemImage: searching ? "magnifyingglass" : "doc"
            )
        } description: {
            Text(LibraryEmpty.detail(searching: searching))
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

    private func togglePin(_ page: Page) {
        page.pinOn.toggle()
        try? modelContext.save()
    }

    private func deletePage(_ page: Page) {
        if path.last == page.pageID {
            path.removeLast()
        }
        modelContext.delete(page)
        try? modelContext.save()
        pagePendingDelete = nil
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: Page.self, inMemory: true)
}
