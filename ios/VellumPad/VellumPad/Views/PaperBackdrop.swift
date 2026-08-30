import SwiftUI

/// Full-bleed paper: fill, grain speckle, ruled lines or dots. Not a wooden desk frame.
/// Do not draw near-vertical fibre strokes — they read as pinstripe ruling.
struct PaperBackdrop: View {
    let paper: Paper
    var compact: Bool = false
    var ruleOffset: CGFloat = 0
    var drawsFill: Bool = true
    var drawsRuling: Bool = true

    var body: some View {
        Canvas { context, size in
            if drawsFill {
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(paper.fill))

                let grainOpacity = paper.isDark ? 0.10 : (compact ? 0.04 : 0.07)
                if size.width > 0, size.height > 0 {
                    var rng = SeededRandom(seed: PaperGrain.seed(for: paper))
                    let count = Int((size.width * size.height) / (compact ? 140 : 90))
                    for _ in 0..<min(count, 900) {
                        let px = CGFloat(rng.next()) * size.width
                        let py = CGFloat(rng.next()) * size.height
                        let rect = CGRect(x: px, y: py, width: 1.1, height: 1.1)
                        let color = paper.isDark
                            ? Color.white.opacity(grainOpacity * rng.next())
                            : VellumPalette.ink.opacity(grainOpacity * rng.next())
                        context.fill(Path(ellipseIn: rect), with: .color(color))
                    }
                }
            }

            guard drawsRuling else { return }

            switch paper.ruling {
            case .none:
                break
            case .lines:
                let step = CGFloat(PaperRuling.step(ruling: .lines, compact: compact))
                let ruleColor = VellumPalette.rule.opacity(compact ? 0.28 : 0.45)
                var y = ruleOffset
                if y < 0 { y = 0 }
                while y < size.height {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(ruleColor), lineWidth: 1)
                    y += step
                }
                if !compact {
                    var margin = Path()
                    margin.move(to: CGPoint(x: 42, y: 0))
                    margin.addLine(to: CGPoint(x: 42, y: size.height))
                    context.stroke(margin, with: .color(VellumPalette.margin.opacity(0.52)), lineWidth: 1)
                }
            case .dots:
                let step = CGFloat(PaperRuling.step(ruling: .dots, compact: compact))
                let dotColor = VellumPalette.ink.opacity(compact ? 0.12 : 0.18)
                var y = ruleOffset > 0 ? ruleOffset : (compact ? 8 : CGFloat(PaperRuling.firstRuleOffset))
                while y < size.height {
                    var x: CGFloat = compact ? 8 : 12
                    while x < size.width {
                        let rect = CGRect(x: x - 0.7, y: y - 0.7, width: 1.4, height: 1.4)
                        context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                        x += step
                    }
                    y += step
                }
            }
        }
        .allowsHitTesting(false)
    }
}

/// Grain desk behind library chrome. Not a paper fill; not `UInt64(hashValue)`.
/// Fill follows system appearance (cream / night). Tooth + quiet vignette.
/// No vertical fibre — those read as pinstripe ruling.
struct DeskBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(AppearanceLook.key) private var appearanceRaw = AppearanceLook.defaultRaw

    private var scheme: ColorScheme {
        VellumPalette.resolvedScheme(appearanceRaw: appearanceRaw, system: colorScheme)
    }

    var body: some View {
        let night = scheme == .dark
        Canvas { context, size in
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(VellumPalette.desk(for: night ? .dark : .light))
            )

            guard size.width > 0, size.height > 0 else { return }
            drawTooth(context: context, size: size, dark: night)
            drawVignette(context: context, size: size, dark: night)
        }
        .allowsHitTesting(false)
    }

    /// Paper/wood tooth. Mixed ink + lift ellipses. No lined rhythm, no fibre.
    /// Night is not quieter — Jamie could not see those specks from a phone.
    private func drawTooth(context: GraphicsContext, size: CGSize, dark: Bool) {
        var rng = SeededRandom(seed: PaperGrain.seed(forToken: "desk"))
        let area = size.width * size.height
        let spacing = dark ? DeskToothLook.darkSpacing : DeskToothLook.lightSpacing
        let cap = dark ? DeskToothLook.darkMax : DeskToothLook.lightMax
        let count = min(Int(area / spacing), cap)
        let ink = dark ? Color.white : VellumPalette.ink
        let lift = dark ? Color.white : VellumPalette.paper
        let inkCap = dark ? DeskToothLook.darkInkCap : DeskToothLook.lightInkCap
        let liftCap = dark ? DeskToothLook.darkLiftCap : DeskToothLook.lightLiftCap

        for i in 0..<count {
            let px = CGFloat(rng.next()) * size.width
            let py = CGFloat(rng.next()) * size.height
            let tooth = i.isMultiple(of: 7)
            let side = tooth
                ? CGFloat(DeskToothLook.toothMin + rng.next() * DeskToothLook.toothSpan)
                : CGFloat(DeskToothLook.sideMin + rng.next() * DeskToothLook.sideSpan)
            let rect = CGRect(x: px, y: py, width: side, height: side * (0.7 + rng.next() * 0.5))
            let highlight = rng.next() > 0.55
            let color = highlight
                ? lift.opacity(liftCap * rng.next())
                : ink.opacity(inkCap * rng.next())
            context.fill(Path(ellipseIn: rect), with: .color(color))
        }
    }

    /// Edge darken only. Not a color wash, starfield, or wellness gradient.
    private func drawVignette(context: GraphicsContext, size: CGSize, dark: Bool) {
        let edge = dark
            ? Color.black.opacity(0.42)
            : VellumPalette.ink.opacity(0.14)
        let radius = hypot(size.width, size.height) * 0.58
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: .clear, location: 0.38),
                    .init(color: edge, location: 1),
                ]),
                center: CGPoint(x: size.width * 0.5, y: size.height * 0.42),
                startRadius: min(size.width, size.height) * 0.22,
                endRadius: radius
            )
        )
    }
}

/// Tiny deterministic RNG so grain does not shimmer on every redraw.
private struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    mutating func next() -> Double {
        state &+= 0x9E37_79B9_7F4A_7C15
        let z = state
        let mixed = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        return Double(mixed % 10_000) / 10_000
    }
}
