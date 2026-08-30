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
    @State private var bringInOpen = false
    @State private var bringInSource: ImportSource = .notes
    @State private var pickingFiles = false
    @State private var bringInMessage = ""
    @State private var bringInIsError = false

    private var groups: [(section: LibrarySection, pages: [Page])] {
        LibraryGrouping.group(pages: pages, query: query)
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if groups.isEmpty {
                    emptyDesk
                } else {
                    pageList
                }
            }
            .animation(deskMotion, value: groups.isEmpty)
            .background {
                DeskBackdrop()
                    .ignoresSafeArea(.container)
            }
            .navigationTitle(PageCopy.greeting())
            .navigationSubtitle(subtitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbarTitleDisplayMode(.large)
            .navigationDestination(for: UUID.self) { id in
                EditorView(pageID: id)
            }
            .searchable(text: $query, placement: .automatic, prompt: "Search pages")
            .toolbar {
                // Fraunces on the stock large-title slot. Do not hide the
                // nav bar. UINavigationBarAppearance flattens Liquid Glass.
                // Size is system largeTitle (not 34). Italic overshoot is
                // font metrics, not a guessed pad. Fail GREETING_CLIP.
                ToolbarItem(placement: .largeTitle) {
                    Text(PageCopy.greeting())
                        .font(VellumFonts.display())
                        .foregroundStyle(VellumPalette.onDesk)
                        .padding(.top, VellumFonts.greetingTopAir())
                        .padding(.bottom, CGFloat(LibraryGreeting.belowGreeting))
                        .fixedSize(horizontal: false, vertical: true)
                        .greetingLeading()
                        .accessibilityHidden(true)
                }
                // Date · pages: stock subtitle slots, Path lockup.
                // `.navigationSubtitle` stays for VoiceOver. Live date.
                ToolbarItem(placement: .largeSubtitle) {
                    deskSubtitle
                }
                ToolbarItem(placement: .subtitle) {
                    deskSubtitle
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(LibraryLook.bringInTitle, systemImage: LibraryLook.bringInSystemImage) {
                        bringInMessage = ""
                        bringInIsError = false
                        withAnimation(deskMotion) { bringInOpen = true }
                    }
                    .accessibilityLabel(LibraryLook.bringInTitle)
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
            .sheet(isPresented: $bringInOpen) {
                BringInSheet(
                    onPick: { source in
                        bringInSource = source
                        pickingFiles = true
                    },
                    message: bringInMessage,
                    isError: bringInIsError
                )
            }
            .fileImporter(
                isPresented: $pickingFiles,
                allowedContentTypes: ImportPicker.types(for: bringInSource),
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    applyImport(BringInFiles.drafts(from: urls, source: bringInSource))
                case .failure:
                    showBringIn(ImportError.unreadable.copy, error: true)
                }
            }
            .onOpenURL { url in
                handleIncoming(url)
            }
            .safeAreaInset(edge: .bottom, spacing: 8) {
                if trash.last != nil {
                    undoBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(deskMotion, value: trash.last?.pageID)
            .onAppear {
                discardBlankDrafts(except: Set(path))
                drainInbox()
            }
            .onChange(of: path) { _, newPath in
                composeLock = false
                discardBlankDrafts(except: Set(newPath))
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

    private var pageCount: Int {
        pages.filter { LibraryListing.hasInk(title: $0.title, body: $0.body) }.count
    }

    private var subtitle: String {
        DeskMetaCopy.spoken(count: pageCount)
    }

    /// Path lockup in the stock subtitle slot. Live date + count.
    private var deskSubtitle: some View {
        DeskMetaLockup(date: DeskMetaCopy.dateLabel(), count: pageCount)
            .greetingLeading()
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
                        .transition(sheetMotion)
                        .swipeActions(edge: .trailing, allowsFullSwipe: LibraryLook.deleteAllowsFullSwipe) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                removePage(page)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button(page.pinOn ? "Unpin" : "Pin", systemImage: page.pinOn ? "pin.slash" : "pin") {
                                togglePin(page)
                            }
                            .tint(VellumPalette.onDeskSoft)
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
                    if group.section.showsHeader {
                        PinnedSectionMark()
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .listSectionSpacing(22)
        .safeAreaPadding(.top)
        .animation(deskMotion, value: deskSignature)
    }

    /// Pin, grouping, undo, and compose-return all share this identity.
    private var deskSignature: String {
        groups.map { group in
            let ids = group.pages.map { "\($0.pageID.uuidString):\($0.pinOn)" }.joined(separator: ",")
            return "\(group.section.rawValue):\(ids)"
        }.joined(separator: "|")
    }

    /// WWDC25: large titles live at the top of the content scroll view.
    /// Empty desk had no scroll view, so Fraunces sat in the bar slot and
    /// was sliced by the status bar (GREETING_CLIP, phone 23).
    private var emptyDesk: some View {
        ScrollView {
            emptyState
                .containerRelativeFrame(.vertical)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .safeAreaPadding(.top)
    }

    /// Mark + headline. No second poetic line. Compose stays in chrome.
    @ViewBuilder
    private var emptyState: some View {
        let searching = !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let detail = LibraryEmpty.detail(searching: searching)
        VStack(spacing: 0) {
            Spacer(minLength: 20)
            EmptyDeskMark()
                .padding(.bottom, 22)
            Text(LibraryEmpty.headline(searching: searching))
                .font(VellumFonts.display(size: 28))
                .foregroundStyle(VellumPalette.onDesk)
                .multilineTextAlignment(.center)
            if !detail.isEmpty {
                Text(detail)
                    .font(VellumFonts.ui(.subheadline))
                    .foregroundStyle(VellumPalette.onDeskSoft)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 36)
            }
            if LibraryEmpty.showsClearSearch(searching: searching) {
                Button("Clear search") { query = "" }
                    .font(VellumFonts.ui(.body, weight: .medium))
                    .foregroundStyle(VellumPalette.onDesk)
                    .frame(minHeight: HitTarget.minimum)
                    .padding(.top, 16)
            }
            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            detail.isEmpty
                ? LibraryEmpty.headline(searching: searching)
                : "\(LibraryEmpty.headline(searching: searching)). \(detail)"
        )
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

    /// Insertion moves too — pin into Pinned was a fade-only snap.
    private var sheetMotion: AnyTransition {
        if reduceMotion { return .opacity }
        return .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.96)),
            removal: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.94))
        )
    }

    private var deskMotion: Animation? {
        reduceMotion ? nil : .spring(
            response: DeskMotion.response,
            dampingFraction: DeskMotion.damping
        )
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
        withAnimation(deskMotion) {
            modelContext.insert(page)
            try? modelContext.save()
        }
        path.append(page.pageID)
    }

    /// Blank Untitled / 0-word drafts are not a populated desk. Drop them
    /// when they are not open so they do not persist as a lonely card.
    private func discardBlankDrafts(except open: Set<UUID>) {
        let blanks = pages.filter { page in
            !open.contains(page.pageID)
                && !LibraryListing.hasInk(title: page.title, body: page.body)
        }
        guard !blanks.isEmpty else { return }
        withAnimation(deskMotion) {
            for page in blanks {
                modelContext.delete(page)
            }
            try? modelContext.save()
        }
    }

    private func togglePin(_ page: Page) {
        withAnimation(deskMotion) {
            page.pinOn.toggle()
            try? modelContext.save()
        }
    }

    private func removePage(_ page: Page) {
        trash.remember(page.trashSnapshot)
        if path.last == page.pageID {
            path.removeLast()
        }
        withAnimation(deskMotion) {
            modelContext.delete(page)
            try? modelContext.save()
        }
    }

    private func undoLast() {
        guard let deleted = trash.take() else { return }
        let page = Page.restored(from: deleted)
        withAnimation(deskMotion) {
            modelContext.insert(page)
            try? modelContext.save()
        }
    }

    private func handleIncoming(_ url: URL) {
        if url.isFileURL {
            applyImport(BringInFiles.drafts(from: [url], source: .file), reveal: true)
            return
        }
        if url.scheme == ImportInbox.urlScheme {
            applyImport(ImportInbox.drafts(from: ImportInbox.items(from: url)), reveal: true)
        }
    }

    private func drainInbox() {
        let items = ImportInbox.take()
        guard !items.isEmpty else { return }
        applyImport(ImportInbox.drafts(from: items), reveal: true)
    }

    private func applyImport(_ result: Result<[ImportDraft], ImportError>, reveal: Bool = false) {
        if reveal {
            withAnimation(deskMotion) { bringInOpen = true }
        }
        switch result {
        case .failure(let error):
            showBringIn(error.copy, error: true)
        case .success(let drafts):
            let existing = pages.map { (title: $0.title, body: $0.body) }
            let plan = ImportDecision.plan(drafts: drafts, existing: existing)
            if plan.keep.isEmpty {
                showBringIn(ImportCopy.result(brought: 0, skipped: plan.skipped), error: plan.skipped == 0)
                return
            }
            let style = StylePreferences.last
            withAnimation(deskMotion) {
                for draft in plan.keep {
                    modelContext.insert(
                        Page(
                            title: draft.title,
                            body: draft.body,
                            createdAt: draft.createdAt,
                            updatedAt: draft.updatedAt,
                            fontId: style.typeface.rawValue,
                            paperId: style.paper.rawValue,
                            inkId: style.resolvedInk.rawValue,
                            sizeId: style.size.rawValue
                        )
                    )
                }
                try? modelContext.save()
            }
            showBringIn(ImportCopy.result(brought: plan.keep.count, skipped: plan.skipped), error: false)
        }
    }

    private func showBringIn(_ message: String, error: Bool) {
        bringInMessage = message
        bringInIsError = error
        if !bringInOpen {
            withAnimation(deskMotion) { bringInOpen = true }
        }
    }
}

/// Same origin as the greeting so the date line shares its leading.
private extension View {
    func greetingLeading() -> some View {
        self
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, CGFloat(LibraryGreeting.titleLeading))
    }
}

#Preview {
    LibraryView()
        .environment(PageTrash())
        .modelContainer(for: Page.self, inMemory: true)
}
