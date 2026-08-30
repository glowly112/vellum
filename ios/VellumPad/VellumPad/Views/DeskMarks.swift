import SwiftUI

/// Date · pages lockup for the stock subtitle slot.
/// Live weekday / date / count. Drawn middot and a tiny paper sheet.
/// Not SF. Not a second Good afternoon. Not a frozen bitmap.
struct DeskMetaLockup: View {
    let date: String
    let count: Int

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(date)
                .font(VellumFonts.deskMeta())
                .foregroundStyle(VellumPalette.onDeskSoft)
                .lineLimit(1)
            DeskMiddot()
            DeskPageMark(count: count)
        }
        .accessibilityHidden(true)
    }
}

/// Ink disc. Not the system interpunct.
private struct DeskMiddot: View {
    var body: some View {
        Canvas { context, size in
            let rect = CGRect(x: 0.5, y: 0.5, width: size.width - 1, height: size.height - 1)
            context.fill(Path(ellipseIn: rect), with: .color(VellumPalette.onDeskSoft))
        }
        .frame(width: 3.5, height: 3.5)
        .accessibilityHidden(true)
    }
}

/// Mini paper stamp carrying the live page count. Cream, rust margin, Fraunces.
/// Same objects as EmptyDeskMark. Not the word Vellum. Not SF.
private struct DeskPageMark: View {
    let count: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                .fill(VellumPalette.paper)
            Capsule()
                .fill(VellumPalette.rust)
                .frame(width: 1.4, height: 11)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 3)
            Text("\(count)")
                .font(VellumFonts.page(.editorial, size: 11, relativeTo: .caption2))
                .foregroundStyle(VellumPalette.ink)
                .offset(x: 1.2)
        }
        .frame(width: count > 9 ? 26 : 18, height: 18)
        .overlay {
            RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                .strokeBorder(VellumPalette.ink.opacity(0.10), lineWidth: 0.8)
        }
        .shadow(color: VellumPalette.lift.opacity(0.65), radius: 2, y: 1)
        .rotationEffect(.degrees(-1.5))
        .accessibilityHidden(true)
    }
}

/// Pinned section mark. Path pin + Fraunces. Not SF caption caps.
struct PinnedSectionMark: View {
    var body: some View {
        HStack(alignment: .center, spacing: 7) {
            pinChip
            Text(DeskMarks.pinnedVoiceOver)
                .font(VellumFonts.page(.editorial, size: 13, relativeTo: .caption))
                .foregroundStyle(VellumPalette.onDeskSoft)
        }
        .textCase(.none)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(DeskMarks.pinnedVoiceOver)
    }

    private var pinChip: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(VellumPalette.paper)
            DeskPinTick()
        }
        .frame(width: 16, height: 16)
        .overlay {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(VellumPalette.ink.opacity(0.10), lineWidth: 0.8)
        }
        .shadow(color: VellumPalette.lift.opacity(0.55), radius: 2, y: 1)
        .rotationEffect(.degrees(-2))
        .accessibilityHidden(true)
    }
}

/// Drawn pin tick. Rust ink. Not `pin.fill`.
private struct DeskPinTick: View {
    var body: some View {
        Canvas { context, size in
            let ink = VellumPalette.rust
            let head = CGRect(
                x: size.width * 0.28,
                y: size.height * 0.12,
                width: size.width * 0.44,
                height: size.height * 0.36
            )
            context.fill(Path(ellipseIn: head), with: .color(ink))
            var shaft = Path()
            shaft.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.44))
            shaft.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.86))
            context.stroke(
                shaft,
                with: .color(ink),
                style: StrokeStyle(lineWidth: 1.3, lineCap: .round)
            )
        }
        .frame(width: 9, height: 12)
    }
}

/// Bundled App Store icons for Connections. Not SF. Not drawn pads.
struct ImportSourceMark: View {
    let source: ImportSource

    private var size: CGFloat { CGFloat(ImportMarkLook.pointSize) }
    private var corner: CGFloat { size * CGFloat(ImportMarkLook.cornerRatio) }

    var body: some View {
        Image(source.markKind)
            .renderingMode(.original)
            .resizable()
            .interpolation(.high)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(VellumPalette.ink.opacity(0.12), lineWidth: 1)
            }
            .accessibilityHidden(true)
    }
}
