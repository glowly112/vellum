import SwiftUI

/// Full-bleed paper: fill, fibre, ruled lines or dots. Not a wooden desk frame.
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

                let fibreOpacity = paper.isDark ? 0.04 : (compact ? 0.035 : 0.028)
                let fibreColor = paper.isDark ? Color.white.opacity(fibreOpacity) : VellumPalette.ink.opacity(fibreOpacity)
                var x: CGFloat = 0
                while x < size.width + size.height {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x - size.height * 0.08, y: size.height))
                    context.stroke(path, with: .color(fibreColor), lineWidth: 1)
                    x += 18
                }

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

/// Grain desk behind the editor sheet. Not a paper fill; not `UInt64(hashValue)`.
struct DeskBackdrop: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(VellumPalette.desk))

            let fibre = VellumPalette.ink.opacity(0.03)
            var x: CGFloat = 0
            while x < size.width + size.height {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x - size.height * 0.08, y: size.height))
                context.stroke(path, with: .color(fibre), lineWidth: 1)
                x += 18
            }

            if size.width > 0, size.height > 0 {
                var rng = SeededRandom(seed: PaperGrain.seed(forToken: "desk"))
                let count = Int((size.width * size.height) / 110)
                for _ in 0..<min(count, 900) {
                    let px = CGFloat(rng.next()) * size.width
                    let py = CGFloat(rng.next()) * size.height
                    let rect = CGRect(x: px, y: py, width: 1.1, height: 1.1)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(VellumPalette.ink.opacity(0.055 * rng.next()))
                    )
                }
            }
        }
        .allowsHitTesting(false)
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
