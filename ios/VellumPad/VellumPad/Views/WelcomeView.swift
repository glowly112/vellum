import SwiftUI

/// Full-screen brand intro on the Velin desk. Not a sheet over the library.
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
                    Spacer(minLength: max(20, geo.size.height * 0.07))
                    sheets(in: geo.size)
                        .id(page)
                        .transition(turn)
                    Spacer(minLength: 16)
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

    private var isBrand: Bool { page == 0 }

    private func sheets(in size: CGSize) -> some View {
        let width = size.width * 0.90
        let height = min(size.height * 0.64, 520)
        return ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(VellumPalette.paper)
                .shadow(color: VellumPalette.ink.opacity(0.10), radius: 14, y: 8)
                .rotationEffect(.degrees(2.4))
                .offset(x: 10, y: 12)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(VellumPalette.ivory)
                .shadow(color: VellumPalette.ink.opacity(0.08), radius: 10, y: 6)
                .rotationEffect(.degrees(-1.6))
                .offset(x: -8, y: 6)
            sheet
        }
        .frame(width: width, height: height)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken)
    }

    private var sheet: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isBrand {
                EmptyDeskMark()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                Text(WelcomeCopy.kicker)
                    .font(VellumFonts.page(.book, size: 13, relativeTo: .caption))
                    .foregroundStyle(VellumPalette.rust)
                    .textCase(.uppercase)
                    .tracking(1.4)
            }
            Text(current.title)
                .font(VellumFonts.page(.editorial, size: isBrand ? 36 : 30, relativeTo: .title))
                .italic()
                .foregroundStyle(VellumPalette.ink)
            if !current.line.isEmpty {
                Text(current.line)
                    .font(VellumFonts.page(.book, size: 18, relativeTo: .title3))
                    .foregroundStyle(VellumPalette.inkSoft)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(28)
        .background(VellumPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: VellumPalette.ink.opacity(0.16), radius: 20, y: 12)
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(VellumPalette.ink.opacity(0.08), lineWidth: 1)
        }
    }

    private var spoken: String {
        var parts: [String] = []
        if isBrand { parts.append(WelcomeCopy.kicker) }
        parts.append(current.title)
        if !current.line.isEmpty { parts.append(current.line) }
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
            .background(VellumPalette.ink, in: Capsule())
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
