import SwiftData
import SwiftUI

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(PageTrash.self) private var trash
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
            .safeAreaInset(edge: .bottom, spacing: 8) {
                if trash.last != nil {
                    undoBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onChange(of: path.count) { _, _ in
                composeLock = false
            }
            .task(id: trash.last?.pageID) {
                guard trash.last != nil else { return }
                try? await Task.sleep(for: .seconds(5))
                if !Task.isCancelled { trash.last = nil }
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
                        .transition(sheetRemoval)
                        .swipeActions(edge: .trailing, allowsFullSwipe: LibraryLook.deleteAllowsFullSwipe) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                removePage(page)
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
                                removePage(page)
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

    /// Journal composition: mark, title, one line. Compose stays in chrome.
    /// Grab: paper is the object. Craft: the empty is paper, not an SF icon.
    @ViewBuilder
    private var emptyState: some View {
        let searching = !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        VStack(spacing: 0) {
            Spacer(minLength: 20)
            EmptyDeskMark()
                .padding(.bottom, 22)
            Text(LibraryEmpty.headline(searching: searching))
                .font(VellumFonts.display(size: 28))
                .foregroundStyle(VellumPalette.ink)
                .multilineTextAlignment(.center)
            Text(LibraryEmpty.detail(searching: searching))
                .font(VellumFonts.ui(.subheadline))
                .foregroundStyle(VellumPalette.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 36)
            if LibraryEmpty.showsClearSearch(searching: searching) {
                Button("Clear search") { query = "" }
                    .font(VellumFonts.ui(.body, weight: .medium))
                    .frame(minHeight: HitTarget.minimum)
                    .padding(.top, 16)
            }
            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(LibraryEmpty.headline(searching: searching)). \(LibraryEmpty.detail(searching: searching))")
    }

    private var undoBar: some View {
        HStack(spacing: 12) {
            Text(DeleteDecision.undoCopy)
                .font(VellumFonts.ui(.subheadline, weight: .medium))
            Spacer(minLength: 8)
            Button(DeleteDecision.undoAction) {
                undoLast()
            }
            .font(VellumFonts.ui(.subheadline, weight: .semibold))
            .frame(minHeight: HitTarget.minimum)
        }
        .foregroundStyle(VellumPalette.paper)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(
            VellumPalette.ink.opacity(0.92),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(DeleteDecision.undoCopy)
        .accessibilityAddTraits(.isButton)
    }

    private var sheetRemoval: AnyTransition {
        if reduceMotion { return .opacity }
        return .asymmetric(
            insertion: .opacity,
            removal: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.94))
        )
    }

    private var deleteMotion: Animation? {
        reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.84)
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

    private func removePage(_ page: Page) {
        trash.remember(page.trashSnapshot)
        if path.last == page.pageID {
            path.removeLast()
        }
        withAnimation(deleteMotion) {
            modelContext.delete(page)
            try? modelContext.save()
        }
    }

    private func undoLast() {
        guard let deleted = trash.take() else { return }
        let page = Page.restored(from: deleted)
        withAnimation(deleteMotion) {
            modelContext.insert(page)
            try? modelContext.save()
        }
    }
}

#Preview {
    LibraryView()
        .environment(PageTrash())
        .modelContainer(for: Page.self, inMemory: true)
}
