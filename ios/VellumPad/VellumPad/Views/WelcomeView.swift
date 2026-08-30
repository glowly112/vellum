import SwiftUI

/// Full-screen brand intro on the Velin desk. Not a sheet over the library.
/// Each page teaches the product with real writing — not an empty cream card.
struct WelcomeView: View {
    var onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                DeskBackdrop()
                    .ignoresSafeArea(.container)

                VStack(spacing: 0) {
                    Spacer(minLength: max(16, geo.size.height * 0.05))
                    pageBody(in: geo.size)
                        .id(page)
                        .transition(turn)
                    Spacer(minLength: 12)
                    chrome
                        .padding(.horizontal, 28)
                        .padding(.bottom, 28)
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .animation(turnMotion, value: page)
    }

    private var current: (title: String, line: String) {
        WelcomeCopy.pages[page]
    }

    private var isLast: Bool {
        page >= WelcomeCopy.pages.count - 1
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
                    body: SampleDeskCopy.typeBody,
                    typeface: .typewriter,
                    paper: .ruled
                )
                WelcomeMiniCard(
                    title: SampleDeskCopy.bookTitle,
                    body: SampleDeskCopy.bookBody,
                    typeface: .book,
                    paper: .cream
                )
                WelcomeMiniCard(
                    title: SampleDeskCopy.handTitle,
                    body: SampleDeskCopy.handBody,
                    typeface: .hand,
                    paper: .sage
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
                    .foregroundStyle(VellumPalette.ink)
                Text(WelcomePreview.editorBody)
                    .font(VellumFonts.page(.editorial, size: 18, relativeTo: .body))
                    .foregroundStyle(VellumPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
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
            .shadow(color: VellumPalette.lift, radius: 16, y: 8)
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
                ForEach([ImportSource.notes, .journal, .notion], id: \.self) { source in
                    VStack(spacing: 8) {
                        ImportSourceMark(source: source)
                        Text(source.title)
                            .font(VellumFonts.page(.book, size: 13, relativeTo: .caption))
                            .foregroundStyle(VellumPalette.onDesk)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(18)
            .background(VellumPalette.chromeRow, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            Text(WelcomePreview.importKeepsDate)
                .font(VellumFonts.page(.book, size: 16, relativeTo: .body))
                .foregroundStyle(VellumPalette.onDesk)
            Text(WelcomePreview.staysLocal)
                .font(VellumFonts.page(.book, size: 16, relativeTo: .body))
                .foregroundStyle(VellumPalette.onDeskSoft)
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, maxHeight: min(size.height * 0.72, 560), alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken)
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: 8) {
            if page == 0 {
                HStack(alignment: .center, spacing: 10) {
                    EmptyDeskMark()
                        .scaleEffect(0.55, anchor: .leading)
                        .frame(width: 44, height: 44)
                    Text(WelcomeCopy.kicker)
                        .font(VellumFonts.page(.book, size: 13, relativeTo: .caption))
                        .foregroundStyle(VellumPalette.rust)
                        .textCase(.uppercase)
                        .tracking(1.4)
                }
            }
            Text(current.title)
                .font(VellumFonts.page(.editorial, size: 32, relativeTo: .title))
                .italic()
                .foregroundStyle(VellumPalette.onDesk)
            if !current.line.isEmpty {
                Text(current.line)
                    .font(VellumFonts.page(.book, size: 17, relativeTo: .title3))
                    .foregroundStyle(VellumPalette.onDeskSoft)
            }
        }
    }

    private var spoken: String {
        var parts: [String] = []
        if page == 0 { parts.append(WelcomeCopy.kicker) }
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
            .foregroundStyle(VellumPalette.onDesk)
            .frame(minHeight: CGFloat(HitTarget.minimum))
            .accessibilityLabel(WelcomeCopy.skip)

            Spacer()

            Button(isLast ? WelcomeCopy.done : WelcomeCopy.turn) {
                advance()
            }
            .font(VellumFonts.page(.book, size: 16, relativeTo: .body))
            .foregroundStyle(VellumPalette.paper)
            .padding(.horizontal, 18)
            .frame(minHeight: CGFloat(HitTarget.minimum))
            .background(VellumPalette.onDesk, in: Capsule())
            .accessibilityLabel(isLast ? WelcomeCopy.done : WelcomeCopy.turn)
        }
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

    private func advance() {
        DeskHapticsPlay.tick()
        if isLast {
            finish()
            return
        }
        page += 1
    }

    private func finish() {
        WelcomeGate.finish()
        onFinished()
    }
}

/// Compact catalog card for the welcome desk. Cream papers stay cream.
private struct WelcomeMiniCard: View {
    let title: String
    let body: String
    let typeface: Typeface
    let paper: Paper

    var body: some View {
        let titleSize: CGFloat = typeface == .hand ? 20 : 17
        let snippetSize: CGFloat = typeface == .hand ? 15 : 13
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(VellumFonts.page(typeface, size: titleSize, relativeTo: .headline))
                .foregroundStyle(paper.defaultInk.color)
                .lineLimit(1)
            Text(body)
                .font(VellumFonts.page(typeface, size: snippetSize, relativeTo: .subheadline))
                .foregroundStyle(paper.defaultInk.color.opacity(0.85))
                .lineLimit(2)
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
        .shadow(color: VellumPalette.lift, radius: 6, y: 2)
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
