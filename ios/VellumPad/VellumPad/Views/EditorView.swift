import SwiftData
import SwiftUI

struct EditorView: View {
    let pageID: UUID

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var pages: [Page]

    @State private var focusMode = false
    @State private var showStyles = false
    @State private var confirmDelete = false
    @FocusState private var field: Field?

    private enum Field: Hashable {
        case title
        case body
    }

    init(pageID: UUID) {
        self.pageID = pageID
        let id = pageID
        _pages = Query(filter: #Predicate<Page> { $0.pageID == id })
    }

    private var page: Page? { pages.first }

    var body: some View {
        Group {
            if let page {
                editor(page)
            } else {
                missing
            }
        }
    }

    private func editor(_ page: Page) -> some View {
        let paper = page.paper
        let ink = page.ink
        let typeface = page.typeface
        let size = page.typeSize
        let editing = field != nil
        let footer = EditorSheetCopy.footer(
            wordCount: page.words,
            paper: paper,
            typeface: typeface
        )

        return ZStack {
            DeskBackdrop()
                .ignoresSafeArea(.container)

            VStack(spacing: 0) {
                if focusMode {
                    Color.clear
                        .frame(height: 28)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { focusMode = false }
                        .accessibilityLabel("Exit focus")
                        .accessibilityAddTraits(.isButton)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(PageCopy.longDate(page.createdAt))
                        .font(VellumFonts.ui(.caption2, weight: .medium))
                        .tracking(1.6)
                        .foregroundStyle(ink.color.opacity(0.40))
                        .padding(.top, focusMode ? 4 : 8)

                    TextField(
                        "Title",
                        text: titleBinding(page),
                        prompt: Text("Title").foregroundStyle(ink.color.opacity(0.38)),
                        axis: .vertical
                    )
                    .font(VellumFonts.title(typeface, size: size))
                    .foregroundStyle(ink.color)
                    .tint(ink.color)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.next)
                    .focused($field, equals: .title)
                    .onSubmit { field = .body }
                    .padding(.top, 12)

                    TextEditor(text: bodyBinding(page))
                        .font(VellumFonts.body(typeface, size: size))
                        .foregroundStyle(ink.color)
                        .tint(ink.color)
                        .scrollContentBackground(.hidden)
                        .lineSpacing(CGFloat(size.bodyPoints * (size.bodyLeading - 1)))
                        .textInputAutocapitalization(.sentences)
                        .focused($field, equals: .body)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .overlay(alignment: .topLeading) {
                            if page.body.isEmpty && field != .body {
                                Text("Begin writing…")
                                    .font(VellumFonts.body(typeface, size: size))
                                    .foregroundStyle(ink.color.opacity(0.38))
                                    .padding(.top, 16)
                                    .allowsHitTesting(false)
                            }
                        }

                    if EditorSheetCopy.showsFooter(focus: focusMode) {
                        Button {
                            openStyles()
                        } label: {
                            HStack {
                                Text(footer.words)
                                    .monospacedDigit()
                                Spacer()
                                Text(footer.style)
                            }
                            .font(VellumFonts.ui(.caption, weight: .medium))
                            .tracking(0.4)
                            .foregroundStyle(ink.color.opacity(0.55))
                            .frame(minHeight: HitTarget.minimum)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Page style, \(footer.words), \(footer.style)")
                    }
                }
                .padding(.leading, paper.ruling == .lines ? 56 : 24)
                .padding(.trailing, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    PaperBackdrop(paper: paper, ruleOffset: 86)
                }
                .clipShape(RoundedRectangle(cornerRadius: CGFloat(EditorLook.cornerRadius), style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: CGFloat(EditorLook.cornerRadius), style: .continuous)
                        .strokeBorder(VellumPalette.ink.opacity(paper.isDark ? 0.28 : 0.10), lineWidth: 1)
                }
                .shadow(color: VellumPalette.ink.opacity(0.14), radius: 12, y: 4)
            }
            .padding(.horizontal, CGFloat(EditorLook.deskInset))
            .padding(.bottom, CGFloat(EditorLook.deskInset))
            .padding(.top, focusMode ? 6 : 2)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(focusMode)
        .toolbar(focusMode ? .hidden : .automatic, for: .navigationBar)
        .toolbar(focusMode ? .hidden : .automatic, for: .bottomBar)
        .toolbarColorScheme(paper.isDark ? .dark : .light, for: .navigationBar)
        .tint(paper.isDark ? VellumPalette.creamInk : nil)
        .toolbar {
            if !focusMode {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: PageExport(page: page), preview: SharePreview(page.displayTitle)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Focus", systemImage: "eye") {
                        field = nil
                        focusMode = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Page style", systemImage: EditorLook.stylesSystemImage) {
                        openStyles()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ShareLink(item: PageExport(page: page), preview: SharePreview(page.displayTitle)) {
                            Label("Share as Text", systemImage: "square.and.arrow.up")
                        }
                        Button("Delete page", systemImage: "trash", role: .destructive) {
                            confirmDelete = true
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis")
                    }
                    .menuIndicator(.hidden)
                }
                if editing {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") {
                            field = nil
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showStyles) {
            StyleSheetView(
                style: Binding(
                    get: { PageStyle(page: page) },
                    set: { page.apply(style: $0) }
                ),
                onDelete: { deletePage(page) }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
            .presentationBackground(paper.isDark ? VellumPalette.night : VellumPalette.paper)
        }
        .alert("Delete this page?", isPresented: $confirmDelete) {
            Button("Delete page", role: .destructive) { deletePage(page) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This page will be removed from this device. It cannot be undone.")
        }
    }

    private var missing: some View {
        ContentUnavailableView {
            Label("This page isn't here", systemImage: "doc")
        } description: {
            Text("It may have been deleted, or the link is old.")
        } actions: {
            Button("Back to pages") { dismiss() }
                .frame(minHeight: HitTarget.minimum)
        }
        .navigationTitle("Page")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func titleBinding(_ page: Page) -> Binding<String> {
        Binding(
            get: { page.title },
            set: { page.revise(title: $0) }
        )
    }

    private func bodyBinding(_ page: Page) -> Binding<String> {
        Binding(
            get: { page.body },
            set: { page.revise(body: $0) }
        )
    }

    private func openStyles() {
        field = nil
        showStyles = true
    }

    private func deletePage(_ page: Page) {
        showStyles = false
        modelContext.delete(page)
        try? modelContext.save()
        dismiss()
    }
}
