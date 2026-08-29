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
    @State private var keyboardPad: CGFloat = 0
    @State private var restingPad: CGFloat = 0
    @State private var bodyHeight: CGFloat = 0
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
                .ignoresSafeArea()
        }
        .background {
            paper.fill.ignoresSafeArea()
        }
        .background {
            KeyboardPadReader { pad in
                keyboardPad = pad
                restingPad = CGFloat(
                    KeyboardChrome.restingPad(current: Double(restingPad), reported: Double(pad))
                )
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard)
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

    /// The whole editor is paper: under back / share / Focus / Aa, out to the
    /// screen edges, and behind / beside the keys. No desk-grain frame. Type
    /// origin stays (leading 24 / 56 lined, trailing 24, date top 8).
    /// The live UITextInput caret rect sits a few points above the
    /// word-count hairline. Field-size / scrollTo("body") left Mini 42pt
    /// high and the phone clipped. Not pinned at rest.
    private func writingColumn(
        page: Page,
        paper: Paper,
        ink: Ink,
        typeface: Typeface,
        size: TypeSize,
        footer: EditorFooter
    ) -> some View {
        let lift = KeyboardChrome.keyboardOnlyLift(
            guidePad: Double(keyboardPad),
            restingPad: Double(restingPad)
        )
        let followCaret = field == .body && lift > 0
        let editorHeight = CGFloat(EditorLook.bodyEditorHeight(
            measured: Double(bodyHeight),
            empty: page.body.isEmpty
        ))

        return ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                    Text(PageCopy.longDate(page.createdAt))
                        .font(VellumFonts.ui(.caption2, weight: .medium))
                        .tracking(1.6)
                        .foregroundStyle(ink.color.opacity(0.40))
                        .padding(.top, focusMode ? 4 : CGFloat(EditorLook.dateTop))
                        .id("page-top")

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

                    ZStack(alignment: .topLeading) {
                        Text(page.body.isEmpty ? " " : page.body)
                            .font(VellumFonts.body(typeface, size: size))
                            .lineSpacing(rulingSpacing(typeface: typeface, points: size.bodyPoints, pitches: 1))
                            .padding(.top, 8)
                            .padding(.bottom, CGFloat(EditorLook.bodyBottomPad))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(0)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.size.height
                            } action: { height in
                                bodyHeight = height
                            }

                        TextEditor(text: bodyBinding(page))
                            .font(VellumFonts.body(typeface, size: size))
                            .foregroundStyle(ink.color)
                            .tint(ink.color)
                            .scrollContentBackground(.hidden)
                            .scrollDisabled(true)
                            .lineSpacing(rulingSpacing(typeface: typeface, points: size.bodyPoints, pitches: 1))
                            .contentMargins(.top, 0, for: .scrollContent)
                            .contentMargins(.bottom, 0, for: .scrollContent)
                            .textInputAutocapitalization(.sentences)
                            .focused($field, equals: .body)
                            .padding(.top, 8)
                            .padding(.bottom, CGFloat(EditorLook.bodyBottomPad))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .frame(height: editorHeight)
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
                    .id("body")
                    }
                }
                .padding(.leading, CGFloat(EditorLook.typeLeading(for: paper)))
                .padding(.trailing, CGFloat(EditorLook.typeTrailing))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background {
                    if paper.ruling != .none {
                        PaperBackdrop(
                            paper: paper,
                            ruleOffset: CGFloat(PaperRuling.firstRuleOffset),
                            drawsFill: false
                        )
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: followCaret) { _, on in
                if !on {
                    proxy.scrollTo("page-top", anchor: .top)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if EditorSheetCopy.showsFooter(focus: focusMode) {
                wordCountInset(footer: footer, ink: ink, followCaret: followCaret)
                    .padding(.leading, CGFloat(EditorLook.typeLeading(for: paper)))
                    .padding(.trailing, CGFloat(EditorLook.typeTrailing))
                    .padding(.bottom, CGFloat(KeyboardAvoidance.wordCountBottomPad(keyboardLift: lift)))
            }
        }
        .padding(.bottom, CGFloat(KeyboardChrome.writingBottomPad(
            guidePad: Double(keyboardPad),
            restingPad: Double(restingPad)
        )))
        .ignoresSafeArea(.keyboard)
        .ignoresSafeArea(.container, edges: .bottom)
    }

    /// Extra `lineSpacing` so the line box equals `pitch * pitches` (UIFont when we have it).
    private func rulingSpacing(typeface: Typeface, points: Double, pitches: Double) -> CGFloat {
        let target = CGFloat(PaperRuling.pitch * pitches)
        let font = UIFont(name: typeface.familyName, size: points) ?? .systemFont(ofSize: points)
        return max(0, target - font.lineHeight)
    }

    /// Apple `safeAreaInset`: content sits beside the column and grows the safe
    /// area. Bottom pad is the keyboard layout guide, not a jumped safe area.
    private func wordCountInset(footer: EditorFooter, ink: Ink, followCaret: Bool) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ink.color.opacity(0.12))
                .frame(height: 0.5)
                .background {
                    CaretHairlineFollower(
                        following: followCaret,
                        air: CGFloat(KeyboardAvoidance.wordCountAir)
                    )
                }
            Text(footer.words)
                .monospacedDigit()
                .font(VellumFonts.ui(.caption, weight: .medium))
                .tracking(0.4)
                .foregroundStyle(ink.color.opacity(0.55))
                .frame(maxWidth: .infinity, alignment: .leading)
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

/// Bottom pad from `keyboardLayoutGuide`, which travels with the system
/// keyboard (including interactive dismiss). A GeometryReader on
/// `safeAreaInsets` jumps to the end frame when the animation starts — that
/// was the jank. Not a guessed 34 / 120.
private struct KeyboardPadReader: UIViewRepresentable {
    var onPad: (CGFloat) -> Void

    func makeUIView(context: Context) -> KeyboardPadUIView {
        let view = KeyboardPadUIView()
        view.onPad = onPad
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: KeyboardPadUIView, context: Context) {
        uiView.onPad = onPad
    }
}

private final class KeyboardPadUIView: UIView {
    var onPad: ((CGFloat) -> Void)?

    private let probe = UIView()
    private var installed = false
    private var last: CGFloat = .nan
    private var observers: [NSObjectProtocol] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        probe.translatesAutoresizingMaskIntoConstraints = false
        probe.isUserInteractionEnabled = false
        probe.backgroundColor = .clear
    }

    required init?(coder: NSCoder) { nil }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        installIfNeeded()
        report()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        report()
    }

    private func installIfNeeded() {
        guard window != nil, !installed else { return }
        installed = true
        addSubview(probe)
        NSLayoutConstraint.activate([
            probe.leadingAnchor.constraint(equalTo: leadingAnchor),
            probe.trailingAnchor.constraint(equalTo: trailingAnchor),
            probe.bottomAnchor.constraint(equalTo: bottomAnchor),
            probe.topAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
        ])
        let names: [Notification.Name] = [
            UIResponder.keyboardWillChangeFrameNotification,
            UIResponder.keyboardDidChangeFrameNotification,
        ]
        for name in names {
            observers.append(
                NotificationCenter.default.addObserver(
                    forName: name,
                    object: nil,
                    queue: .main
                ) { [weak self] note in
                    self?.trackKeyboard(note)
                }
            )
        }
    }

    private func trackKeyboard(_ note: Notification) {
        let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?
            .doubleValue ?? 0
        let curveRaw = (note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?
            .uintValue ?? 7
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        setNeedsLayout()
        if duration > 0 {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [options, .beginFromCurrentState]
            ) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    private func report() {
        let pad = probe.bounds.height
        guard pad.isFinite else { return }
        if last.isFinite, abs(pad - last) < 0.25 { return }
        last = pad
        onPad?(pad)
    }
}

/// Parks the first-responder `UITextInput` caret a few points above this
/// view (the word-count hairline). Ancestor walks miss SwiftUI's TextEditor;
/// the first responder is the live caret. Not a guessed 34 / 120.
private struct CaretHairlineFollower: UIViewRepresentable {
    var following: Bool
    var air: CGFloat

    func makeUIView(context: Context) -> CaretHairlineView {
        let view = CaretHairlineView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: CaretHairlineView, context: Context) {
        uiView.air = air
        uiView.following = following
        uiView.nudge()
        DispatchQueue.main.async { uiView.nudge() }
    }
}

private final class CaretHairlineView: UIView {
    var following = false
    var air: CGFloat = 4
    private weak var lastScroll: UIScrollView?
    private var observers: [NSObjectProtocol] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        let names: [Notification.Name] = [
            UITextView.textDidChangeNotification,
            UITextView.textDidBeginEditingNotification,
            UIResponder.keyboardDidChangeFrameNotification,
        ]
        for name in names {
            observers.append(
                NotificationCenter.default.addObserver(
                    forName: name,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    self?.nudge()
                }
            )
        }
    }

    required init?(coder: NSCoder) { nil }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        nudge()
    }

    func nudge() {
        guard let window else { return }
        guard following else {
            if let scroll = lastScroll { reset(scroll) }
            return
        }
        guard let text = Self.bodyTextView(in: window) else { return }
        guard let scroll = Self.outerScrollView(from: text, in: window) else { return }
        lastScroll = scroll
        guard let range = text.selectedTextRange else { return }
        let caret = text.caretRect(for: range.start)
        guard caret.origin.x.isFinite, caret.origin.y.isFinite, caret.height > 0 else { return }
        let caretBottom = text.convert(CGPoint(x: caret.midX, y: caret.maxY), to: window).y
        let hairlineY = convert(.zero, to: window).y
        let remaining = CGFloat(KeyboardChrome.caretNudge(
            caretBottom: Double(caretBottom),
            hairlineY: Double(hairlineY),
            air: Double(air)
        ))
        apply(remaining, to: scroll)
    }

    private func apply(_ remaining: CGFloat, to scroll: UIScrollView) {
        if remaining < -0.5 {
            let top = max(0, scroll.contentInset.top - remaining)
            scroll.contentInset.top = top
            scroll.contentInset.bottom = 0
            scroll.contentOffset = CGPoint(x: scroll.contentOffset.x, y: -top)
        } else if remaining > 0.5 {
            let bottom = max(0, scroll.contentInset.bottom + remaining)
            scroll.contentInset.top = 0
            scroll.contentInset.bottom = bottom
            scroll.contentOffset = CGPoint(
                x: scroll.contentOffset.x,
                y: scroll.contentOffset.y + remaining
            )
        }
    }

    private func reset(_ scroll: UIScrollView) {
        guard scroll.contentInset.top != 0 || scroll.contentInset.bottom != 0 else { return }
        scroll.contentInset.top = 0
        scroll.contentInset.bottom = 0
    }

    /// First responder `UITextView` — the body TextEditor. Title is a field.
    private static func bodyTextView(in window: UIWindow) -> UITextView? {
        if let text = currentFirstResponder() as? UITextView { return text }
        return firstResponder(in: window) as? UITextView
    }

    private static func currentFirstResponder() -> UIResponder? {
        FirstResponderBox.current = nil
        UIApplication.shared.sendAction(
            #selector(UIResponder.vellum_captureFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        return FirstResponderBox.current
    }

    private static func firstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for child in view.subviews {
            if let found = firstResponder(in: child) { return found }
        }
        return nil
    }

    private static func outerScrollView(from start: UIView, in window: UIWindow) -> UIScrollView? {
        var found: UIScrollView?
        var node = start.superview
        while let current = node {
            if let scroll = current as? UIScrollView, !(scroll is UITextView) {
                found = scroll
            }
            node = current.superview
        }
        if found == nil {
            found = firstScrollView(in: window)
        }
        return found
    }

    private static func firstScrollView(in view: UIView) -> UIScrollView? {
        if let scroll = view as? UIScrollView, !(scroll is UITextView) { return scroll }
        for child in view.subviews {
            if let found = firstScrollView(in: child) { return found }
        }
        return nil
    }
}

private enum FirstResponderBox {
    static weak var current: UIResponder?
}

private extension UIResponder {
    @objc func vellum_captureFirstResponder() {
        FirstResponderBox.current = self
    }
}
