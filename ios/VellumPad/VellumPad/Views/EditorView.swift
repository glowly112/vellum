import SwiftData
import SwiftUI
import UIKit

struct EditorView: View {
    let pageID: UUID

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var pages: [Page]

    @State private var focusMode = false
    @State private var showStyles = false
    @State private var confirmDelete = false
    @State private var styleDetent: PresentationDetent = .medium
    @State private var keyboardLift: CGFloat = 0
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

        return writingColumn(
            page: page,
            paper: paper,
            ink: ink,
            typeface: typeface,
            size: size,
            footer: footer
        )
        .background {
            PaperBackdrop(paper: paper, drawsRuling: false)
                .ignoresSafeArea(.container)
        }
        .background {
            KeyboardLiftReader { keyboardLift = $0 }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(focusMode ? "Exit Focus" : "Focus", systemImage: focusMode ? "eye.slash" : "eye") {
                    if focusMode {
                        focusMode = false
                    } else {
                        field = nil
                        focusMode = true
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
            .presentationDetents([.medium, .large], selection: $styleDetent)
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
        #if DEBUG
        .onAppear {
            focusBodyIfRequested()
        }
        #endif
    }

    #if DEBUG
    private func focusBodyIfRequested() {
        guard DebugFocusBody.shouldFocusBody() else { return }
        field = .body
    }
    #endif

    /// The whole editor is paper: under back / share / Focus / Aa, down to the
    /// word-count inset, out to the screen edges. No desk-grain frame. Type
    /// origin stays (leading 24 / 56 lined, trailing 24, date top 8).
    /// Keyboard-open is still undone.
    private func writingColumn(
        page: Page,
        paper: Paper,
        ink: Ink,
        typeface: Typeface,
        size: TypeSize,
        footer: EditorFooter
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(PageCopy.longDate(page.createdAt))
                .font(VellumFonts.ui(.caption2, weight: .medium))
                .tracking(1.6)
                .foregroundStyle(ink.color.opacity(0.40))
                .padding(.top, focusMode ? 4 : CGFloat(EditorLook.dateTop))

            TextField(
                "Title",
                text: titleBinding(page),
                prompt: Text("Title").foregroundStyle(ink.color.opacity(0.38)),
                axis: .vertical
            )
            .font(VellumFonts.title(typeface, size: size))
            .foregroundStyle(ink.color)
            .tint(ink.color)
            .lineSpacing(rulingSpacing(typeface: typeface, points: size.titlePoints, pitches: PaperRuling.titlePitches))
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
                .lineSpacing(rulingSpacing(typeface: typeface, points: size.bodyPoints, pitches: 1))
                .contentMargins(.top, 0, for: .scrollContent)
                .textInputAutocapitalization(.sentences)
                .focused($field, equals: .body)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .frame(minHeight: CGFloat(EditorLook.bodyMinHeight))
                .overlay(alignment: .topLeading) {
                    if page.body.isEmpty && field != .body {
                        Text("Begin writing…")
                            .font(VellumFonts.body(typeface, size: size))
                            .foregroundStyle(ink.color.opacity(0.38))
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
        .padding(.leading, CGFloat(EditorLook.typeLeading(for: paper)))
        .padding(.trailing, CGFloat(EditorLook.typeTrailing))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            if paper.ruling != .none {
                PaperBackdrop(
                    paper: paper,
                    ruleOffset: CGFloat(PaperRuling.firstRuleOffset),
                    drawsFill: false
                )
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if EditorSheetCopy.showsFooter(focus: focusMode) {
                wordCountInset(footer: footer, ink: ink)
                    .padding(.leading, CGFloat(EditorLook.typeLeading(for: paper)))
                    .padding(.trailing, CGFloat(EditorLook.typeTrailing))
                    .padding(.bottom, CGFloat(KeyboardAvoidance.wordCountBottomPad(keyboardLift: Double(keyboardLift))))
            }
        }
    }

    /// Extra `lineSpacing` so the line box equals `pitch * pitches` (UIFont when we have it).
    private func rulingSpacing(typeface: Typeface, points: Double, pitches: Double) -> CGFloat {
        let target = CGFloat(PaperRuling.pitch * pitches)
        let font = UIFont(name: typeface.familyName, size: points) ?? .systemFont(ofSize: points)
        return max(0, target - font.lineHeight)
    }

    /// Apple `safeAreaInset`: content sits beside the column and grows the safe
    /// area. Keyboard rides the system keyboard safe area. Not a guessed pad.
    private func wordCountInset(footer: EditorFooter, ink: Ink) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ink.color.opacity(0.12))
                .frame(height: 0.5)
            Text(footer.words)
                .monospacedDigit()
                .font(VellumFonts.ui(.caption, weight: .medium))
                .tracking(0.4)
                .foregroundStyle(ink.color.opacity(0.55))
                .frame(maxWidth: .infinity, minHeight: CGFloat(EditorLook.minimumHit), alignment: .leading)
        }
        .accessibilityLabel(footer.words)
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
        styleDetent = .medium
        showStyles = true
    }

    private func deletePage(_ page: Page) {
        showStyles = false
        modelContext.delete(page)
        try? modelContext.save()
        dismiss()
    }
}

/// Reads the keyboard-only bottom safe area (container ignored). Zero when the
/// keyboard is down. Not a guessed 34 / 120.
private struct KeyboardLiftReader: View {
    var onChange: (CGFloat) -> Void

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: KeyboardLiftKey.self, value: geo.safeAreaInsets.bottom)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onPreferenceChange(KeyboardLiftKey.self, perform: onChange)
        .allowsHitTesting(false)
    }
}

private struct KeyboardLiftKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
