import SwiftUI

/// Full-screen product intro. Not a sheet over the library.
/// Stamp bounce, then the three lessons. Writing on cream sheets stays charcoal.
struct WelcomeView: View {
    var onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(AppearanceLook.key) private var appearanceRaw = AppearanceLook.defaultRaw
    @State private var showingStamp = WelcomeLook.hasStamp
    @State private var stampLanded = false
    @State private var page = 0

    private var scheme: ColorScheme {
        VellumPalette.resolvedScheme(appearanceRaw: appearanceRaw, system: colorScheme)
    }

    private var deskInk: Color { VellumPalette.onDesk(for: scheme) }
    private var deskInkSoft: Color { VellumPalette.onDeskSoft(for: scheme) }
    private var sheetInk: Color { VellumPalette.ink }
    private var lift: Color { VellumPalette.lift(for: scheme) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                DeskBackdrop()
                    .ignoresSafeArea(.container)

                VStack(spacing: 0) {
                    Spacer(minLength: max(16, geo.size.height * 0.05))
                    if showingStamp {
                        stampBeat
                            .frame(maxWidth: .infinity, maxHeight: min(geo.size.height * 0.72, 560))
                    } else {
                        pageBody(in: geo.size)
                            .id(page)
                            .transition(turn)
                    }
                    Spacer(minLength: 12)
                    chrome
                        .padding(.horizontal, 28)
                        .padding(.bottom, 28)
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .velinAppearance(appearanceRaw)
        .animation(turnMotion, value: page)
        .animation(turnMotion, value: showingStamp)
        .onAppear { runOpeningBeat() }
    }

    private var current: (title: String, line: String) {
        WelcomeCopy.pages[page]
    }

    private var isLast: Bool {
        !showingStamp && page >= WelcomeCopy.pages.count - 1
    }

    private var stampBeat: some View {
        EmptyDeskMark()
            .scaleEffect(stampLanded || reduceMotion ? 1 : WelcomeLook.bounceStartScale)
            .offset(y: stampLanded || reduceMotion ? 0 : 22)
            .opacity(stampLanded || reduceMotion ? 1 : 0.4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func pageBody(in size: CGSize) -> some View {
        switch page {
        case 0:
            libraryLesson(in: size)
        case 1:
            editorLesson(in: size)
        default:
            importLesson(in: size)
        }
    }

    private func libraryLesson(in size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            headline
            VStack(spacing: 8) {
                WelcomeMiniCard(
                    title: SampleDeskCopy.typeTitle,
                    snippet: SampleDeskCopy.typeBody,
                    typeface: .typewriter,
                    paper: .ruled,
                    appearDelay: 0,
                    scheme: scheme
                )
                WelcomeMiniCard(
                    title: SampleDeskCopy.bookTitle,
                    snippet: SampleDeskCopy.bookBody,
                    typeface: .book,
                    paper: .cream,
                    appearDelay: WelcomeLook.staggerStep,
                    scheme: scheme
                )
                WelcomeMiniCard(
                    title: SampleDeskCopy.handTitle,
                    snippet: SampleDeskCopy.handBody,
                    typeface: .hand,
                    paper: .sage,
                    appearDelay: WelcomeLook.staggerStep * 2,
                    scheme: scheme
                )
            }
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, maxHeight: min(size.height * 0.72, 560), alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken)
    }

    private func editorLesson(in size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            headline
            VStack(alignment: .leading, spacing: 10) {
                Text(WelcomePreview.editorTitle)
                    .font(VellumFonts.page(.editorial, size: 28, relativeTo: .title))
                    .foregroundStyle(sheetInk)
                WelcomeTypedText(
                    full: WelcomePreview.editorBody,
                    font: VellumFonts.page(.editorial, size: 18, relativeTo: .body),
                    ink: sheetInk
                )
                Spacer(minLength: 0)
            }
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 220, maxHeight: min(size.height * 0.48, 340), alignment: .topLeading)
            .background {
                PaperBackdrop(paper: .cream, compact: false, drawsRuling: false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(VellumPalette.ink.opacity(0.08), lineWidth: 1)
            }
            .shadow(color: lift, radius: 16, y: 8)
            .modifier(WelcomeArrive(delay: 0.04))
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, maxHeight: min(size.height * 0.72, 560), alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken)
    }

    private func importLesson(in size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            headline
            HStack(spacing: 14) {
                ForEach(Array([ImportSource.notes, .journal, .notion].enumerated()), id: \.element) { index, source in
                    VStack(spacing: 8) {
                        ImportSourceMark(source: source)
                        Text(source.title)
                            .font(VellumFonts.page(.book, size: 13, relativeTo: .caption))
                            .foregroundStyle(deskInk)
                    }
                    .frame(maxWidth: .infinity)
                    .modifier(WelcomeArrive(delay: Double(index) * WelcomeLook.staggerStep))
                }
            }
            .padding(18)
            .background(VellumPalette.chromeRow(for: scheme), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            Text(WelcomePreview.importKeepsDate)
                .font(VellumFonts.page(.book, size: 16, relativeTo: .body))
                .foregroundStyle(deskInk)
            Text(WelcomePreview.staysLocal)
                .font(VellumFonts.page(.book, size: 16, relativeTo: .body))
                .foregroundStyle(deskInkSoft)
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, maxHeight: min(size.height * 0.72, 560), alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken)
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(current.title)
                .font(VellumFonts.page(.editorial, size: 32, relativeTo: .title))
                .italic()
                .foregroundStyle(deskInk)
            if !current.line.isEmpty {
                Text(current.line)
                    .font(VellumFonts.page(.book, size: 17, relativeTo: .title3))
                    .foregroundStyle(deskInkSoft)
            }
        }
    }

    private var spoken: String {
        var parts: [String] = []
        parts.append(current.title)
        if !current.line.isEmpty { parts.append(current.line) }
        if page == 0 {
            parts.append(contentsOf: WelcomePreview.libraryTitles)
        } else if page == 1 {
            parts.append(WelcomePreview.editorTitle)
            parts.append(WelcomePreview.editorBody)
        } else {
            parts.append(contentsOf: WelcomePreview.importSources)
            parts.append(WelcomePreview.importKeepsDate)
            parts.append(WelcomePreview.staysLocal)
        }
        return parts.joined(separator: ". ")
    }

    private var chrome: some View {
        HStack {
            Button(WelcomeCopy.skip) {
                finish()
            }
            .font(VellumFonts.page(.book, size: 16, relativeTo: .body))
            .foregroundStyle(deskInk)
            .frame(minHeight: CGFloat(HitTarget.minimum))
            .accessibilityLabel(WelcomeCopy.skip)

            Spacer()

            if !showingStamp {
                Button(isLast ? WelcomeCopy.done : WelcomeCopy.turn) {
                    advance()
                }
                .font(VellumFonts.page(.book, size: 16, relativeTo: .body))
                .foregroundStyle(VellumPalette.paper)
                .padding(.horizontal, 18)
                .frame(minHeight: CGFloat(HitTarget.minimum))
                .background(deskInk, in: Capsule())
                .accessibilityLabel(isLast ? WelcomeCopy.done : WelcomeCopy.turn)
            }
        }
    }

    private var bounceMotion: Animation? {
        reduceMotion ? nil : .spring(
            response: WelcomeLook.bounceResponse,
            dampingFraction: WelcomeLook.bounceDamping
        )
    }

    private var turnMotion: Animation? {
        reduceMotion ? nil : .spring(
            response: DeskMotion.response,
            dampingFraction: DeskMotion.damping
        )
    }

    private var turn: AnyTransition {
        if reduceMotion { return .opacity }
        return .asymmetric(
            insertion: .modifier(
                active: WelcomeTurn(progress: 1),
                identity: WelcomeTurn(progress: 0)
            ),
            removal: .modifier(
                active: WelcomeTurn(progress: -1),
                identity: WelcomeTurn(progress: 0)
            )
        )
    }

    private func runOpeningBeat() {
        guard showingStamp else { return }
        if reduceMotion {
            stampLanded = true
            Task { @MainActor in
                await Task.yield()
                showingStamp = false
            }
            return
        }
        stampLanded = false
        Task { @MainActor in
            await Task.yield()
            withAnimation(bounceMotion) { stampLanded = true }
            try? await Task.sleep(for: .seconds(WelcomeLook.bounceSettle))
            guard showingStamp else { return }
            showingStamp = false
            // Advance to Pages you keep. Do not finish() — that skipped Mini.
        }
    }

    private func advance() {
        DeskHapticsPlay.tick()
        if isLast {
            finish()
            return
        }
        page += 1
    }

    /// Skip / Done only. Stamp bounce must not call this.
    private func finish() {
        WelcomeGate.finish()
        onFinished()
    }
}

/// Compact catalog card. Cream papers stay cream. Ink is the paper’s ink, not primary.
private struct WelcomeMiniCard: View {
    let title: String
    let snippet: String
    let typeface: Typeface
    let paper: Paper
    var appearDelay: Double = 0
    var scheme: ColorScheme = .light

    var body: some View {
        let titleSize: CGFloat = typeface == .hand ? 20 : 17
        let snippetSize: CGFloat = typeface == .hand ? 15 : 13
        let ink = Ink.resolve(paper.defaultInk, on: paper).color
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(VellumFonts.page(typeface, size: titleSize, relativeTo: .headline))
                .foregroundStyle(ink)
                .lineLimit(1)
            WelcomeTypedText(
                full: snippet,
                font: VellumFonts.page(typeface, size: snippetSize, relativeTo: .subheadline),
                ink: ink.opacity(0.85),
                lineLimit: 2
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            PaperBackdrop(paper: paper, compact: true)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(VellumPalette.ink.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: VellumPalette.lift(for: scheme), radius: 6, y: 2)
        .modifier(WelcomeArrive(delay: appearDelay))
    }
}

/// Human-speed prefix. No cursor. Reduce Motion shows the full string at once.
private struct WelcomeTypedText: View {
    let full: String
    let font: Font
    let ink: Color
    var lineLimit: Int? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = 0

    var body: some View {
        Text(WelcomeTypewriter.visible(full: full, revealed: revealed))
            .font(font)
            .foregroundStyle(ink)
            .lineLimit(lineLimit)
            .fixedSize(horizontal: false, vertical: true)
            .task(id: full) {
                if reduceMotion || !WelcomeLook.typesWriting {
                    revealed = full.count
                    return
                }
                revealed = 0
                while revealed < full.count {
                    try? await Task.sleep(for: .seconds(WelcomeTypewriter.interval))
                    if Task.isCancelled { return }
                    revealed += 1
                }
            }
            .accessibilityLabel(full)
    }
}

/// Staggered spring arrival. Snap is a miss. Reduce Motion is instant.
private struct WelcomeArrive: ViewModifier {
    var delay: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var arrived = false

    func body(content: Content) -> some View {
        content
            .opacity(arrived ? 1 : 0)
            .offset(y: arrived ? 0 : 16)
            .scaleEffect(arrived ? 1 : 0.94)
            .onAppear {
                if reduceMotion {
                    arrived = true
                    return
                }
                withAnimation(
                    .spring(
                        response: DeskMotion.response,
                        dampingFraction: DeskMotion.damping
                    ).delay(delay)
                ) {
                    arrived = true
                }
            }
    }
}

/// Mesh page-turn: the sheet hinges on its leading edge.
private struct WelcomeTurn: ViewModifier {
    var progress: Double

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(progress * 82),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: 0.55
            )
            .opacity(progress == 0 ? 1 : 0.2)
    }
}
