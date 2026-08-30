import SwiftUI
import UIKit

/// Bound-edge rail on the right of the sheet. Rust hairline + cream paper thumb.
/// Placement from Books; charm is Velin paper. TextEditor owns scrolling.
/// Observe offset; only write contentOffset while the thumb is scrubbing.
/// Do not park the caret.
struct BoundEdgeRail: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: CGFloat = 0
    @State private var isLong = false
    @State private var scrubbing = false
    @State private var revealed = false
    @State private var hideTask: Task<Void, Never>?
    @State private var lastOffset: Double?
    @State private var box = TextViewBox()

    private let thumbHeight: CGFloat = 22
    private let railWidth: CGFloat = 22

    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            ZStack(alignment: .top) {
                if isLong {
                    Capsule()
                        .fill(VellumPalette.rust.opacity(BoundEdgeRailLook.shownHairlineOpacity))
                        .frame(width: 1.25)
                        .frame(maxHeight: .infinity)
                    BoundEdgeThumb()
                        .frame(width: 10, height: thumbHeight)
                        .offset(y: thumbY(in: height))
                        .gesture(scrub(in: height))
                }
            }
            .opacity(markOpacity)
            .animation(revealMotion, value: revealed)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: railWidth)
        .allowsHitTesting(isLong)
        .accessibilityHidden(true)
        .background {
            BoundEdgeProbe(box: box, scrubbing: scrubbing, onMetrics: apply)
        }
        .onDisappear { hideTask?.cancel() }
    }

    private var markOpacity: Double {
        if !isLong { return BoundEdgeRailLook.restOpacity }
        return revealed ? 1 : BoundEdgeRailLook.restOpacity
    }

    /// Fade when motion is allowed. Reduce Motion is a cut, not a tween.
    private var revealMotion: Animation? {
        reduceMotion ? nil : .easeOut(duration: 0.28)
    }

    private func thumbY(in height: CGFloat) -> CGFloat {
        let travel = max(0, height - thumbHeight)
        return progress * travel
    }

    private func scrub(in height: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                scrubbing = true
                reveal()
                let travel = max(1, height - thumbHeight)
                let next = min(1, max(0, (value.location.y - thumbHeight / 2) / travel))
                progress = next
                box.scrub(progress: next)
            }
            .onEnded { _ in
                scrubbing = false
                scheduleHide()
            }
    }

    private func apply(offset: Double, content: Double, bounds: Double) {
        let long = BoundEdgeRailLook.isLongPage(content: content, bounds: bounds)
        if isLong != long { isLong = long }
        guard !scrubbing else { return }
        let next = CGFloat(BoundEdgeRailLook.progress(offset: offset, content: content, bounds: bounds))
        if abs(next - progress) > 0.002 {
            progress = next
        }
        if long, let prior = lastOffset, abs(offset - prior) > 1 {
            reveal()
        }
        lastOffset = offset
        if !long {
            revealed = false
            hideTask?.cancel()
        }
    }

    private func reveal() {
        revealed = true
        hideTask?.cancel()
        if !scrubbing { scheduleHide() }
    }

    private func scheduleHide() {
        guard BoundEdgeRailLook.hidesWhenIdle else { return }
        hideTask?.cancel()
        hideTask = Task {
            let ns = UInt64(BoundEdgeRailLook.idleHideSeconds * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ns)
            if Task.isCancelled { return }
            await MainActor.run {
                if !scrubbing { revealed = false }
            }
        }
    }
}

/// Small cream paper chip. Path/ink, not SF.
private struct BoundEdgeThumb: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(VellumPalette.paper.opacity(BoundEdgeRailLook.shownThumbFillOpacity))
            .overlay {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .strokeBorder(VellumPalette.ink.opacity(0.08), lineWidth: 0.7)
            }
            .shadow(color: VellumPalette.lift.opacity(0.28), radius: 1, y: 0.4)
    }
}

private final class TextViewBox {
    weak var textView: UITextView?

    func scrub(progress: CGFloat) {
        guard let tv = textView else { return }
        let inset = tv.adjustedContentInset
        let visible = Double(tv.bounds.height - inset.top - inset.bottom)
        let content = Double(tv.contentSize.height)
        let y = BoundEdgeRailLook.contentOffset(progress: Double(progress), content: content, bounds: visible)
        tv.setContentOffset(CGPoint(x: 0, y: y - Double(inset.top)), animated: false)
    }
}

/// Finds the body UITextView, hides the system indicator, reports offset.
/// Does not set insets, scrollTo, or caret rects.
private struct BoundEdgeProbe: UIViewRepresentable {
    let box: TextViewBox
    var scrubbing: Bool
    var onMetrics: (Double, Double, Double) -> Void

    func makeUIView(context: Context) -> ProbeView {
        let view = ProbeView()
        view.box = box
        view.scrubbing = scrubbing
        view.onMetrics = onMetrics
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: ProbeView, context: Context) {
        uiView.box = box
        uiView.scrubbing = scrubbing
        uiView.onMetrics = onMetrics
        uiView.hideSystemIndicator()
    }

    final class ProbeView: UIView {
        var box: TextViewBox?
        var scrubbing = false
        var onMetrics: ((Double, Double, Double) -> Void)?
        private var offsetObs: NSKeyValueObservation?
        private var sizeObs: NSKeyValueObservation?
        private var attempts = 0

        override func didMoveToWindow() {
            super.didMoveToWindow()
            attempts = 0
            attach()
        }

        func hideSystemIndicator() {
            box?.textView?.showsVerticalScrollIndicator = false
            box?.textView?.showsHorizontalScrollIndicator = false
        }

        private func attach() {
            if let tv = findBodyEditor() {
                hook(tv)
                return
            }
            attempts += 1
            guard attempts < 24 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.attach()
            }
        }

        private func hook(_ tv: UITextView) {
            box?.textView = tv
            tv.showsVerticalScrollIndicator = false
            tv.showsHorizontalScrollIndicator = false
            offsetObs = tv.observe(\.contentOffset, options: [.new]) { [weak self] view, _ in
                self?.report(view)
            }
            sizeObs = tv.observe(\.contentSize, options: [.new]) { [weak self] view, _ in
                self?.report(view)
            }
            report(tv)
        }

        private func report(_ tv: UITextView) {
            guard !scrubbing else { return }
            let inset = tv.adjustedContentInset
            let visible = Double(tv.bounds.height - inset.top - inset.bottom)
            let content = Double(tv.contentSize.height)
            let offset = Double(tv.contentOffset.y + inset.top)
            DispatchQueue.main.async { [weak self] in
                self?.onMetrics?(offset, content, visible)
            }
        }

        private func findBodyEditor() -> UITextView? {
            var root: UIView = self
            while let next = root.superview { root = next }
            var best: UITextView?
            var bestArea: CGFloat = 0
            func walk(_ view: UIView) {
                if let tv = view as? UITextView {
                    let area = tv.bounds.width * tv.bounds.height
                    if area > bestArea {
                        bestArea = area
                        best = tv
                    }
                }
                view.subviews.forEach(walk)
            }
            walk(root)
            return best
        }
    }
}
