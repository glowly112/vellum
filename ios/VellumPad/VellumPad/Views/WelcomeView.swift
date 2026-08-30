import SwiftUI

/// First-open paper sheets on the Velin desk. Skip or finish — never again.
struct WelcomeView: View {
    var onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    var body: some View {
        ZStack {
            DeskBackdrop()
                .ignoresSafeArea(.container)

            VStack(spacing: 0) {
                Spacer(minLength: 24)
                sheet
                    .id(page)
                    .transition(turn)
                Spacer(minLength: 16)
                chrome
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
            }
        }
        .animation(turnMotion, value: page)
    }

    private var current: (title: String, line: String) {
        WelcomeCopy.pages[page]
    }

    private var isLast: Bool {
        page >= WelcomeCopy.pages.count - 1
    }

    private var sheet: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(current.title)
                .font(VellumFonts.page(.editorial, size: 28, relativeTo: .title))
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
        .shadow(color: VellumPalette.ink.opacity(0.14), radius: 18, y: 10)
        .padding(.horizontal, 28)
        .frame(minHeight: 360)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            current.line.isEmpty ? current.title : "\(current.title) \(current.line)"
        )
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
