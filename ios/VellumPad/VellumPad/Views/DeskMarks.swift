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

/// Drawn source marks for Connections. Not SF. Not generic circles.
struct ImportSourceMark: View {
    let source: ImportSource

    var body: some View {
        Group {
            switch source {
            case .notes: NotesPadMark()
            case .journal: JournalBookMark()
            case .notion: NotionNMark()
            case .file: FilePaperMark()
            }
        }
        .frame(width: 36, height: 36)
        .accessibilityHidden(true)
    }
}

/// Apple Notes yellow pad.
private struct NotesPadMark: View {
    var body: some View {
        Canvas { context, size in
            let pad = CGRect(x: 3, y: 2, width: size.width - 6, height: size.height - 5)
            let fill = Color(red: 0.98, green: 0.86, blue: 0.38)
            context.fill(
                Path(roundedRect: pad, cornerRadius: 3.5),
                with: .color(fill)
            )
            let head = CGRect(x: pad.minX, y: pad.minY, width: pad.width, height: 7)
            context.fill(
                Path(roundedRect: head, cornerRadius: 3.5),
                with: .color(Color(red: 0.93, green: 0.76, blue: 0.22))
            )
            let rule = Color(red: 0.78, green: 0.62, blue: 0.18).opacity(0.55)
            var y = pad.minY + 13
            while y < pad.maxY - 3 {
                var line = Path()
                line.move(to: CGPoint(x: pad.minX + 4, y: y))
                line.addLine(to: CGPoint(x: pad.maxX - 4, y: y))
                context.stroke(line, with: .color(rule), lineWidth: 0.8)
                y += 5
            }
            context.stroke(
                Path(roundedRect: pad, cornerRadius: 3.5),
                with: .color(VellumPalette.ink.opacity(0.18)),
                lineWidth: 0.8
            )
        }
    }
}

/// Apple Journal brown book.
private struct JournalBookMark: View {
    var body: some View {
        Canvas { context, size in
            let cover = CGRect(x: 4, y: 3, width: size.width - 7, height: size.height - 6)
            let brown = Color(red: 0.45, green: 0.28, blue: 0.16)
            context.fill(
                Path(roundedRect: cover, cornerRadius: 3),
                with: .color(brown)
            )
            let spine = CGRect(x: cover.minX, y: cover.minY, width: 5, height: cover.height)
            context.fill(
                Path(roundedRect: spine, cornerRadius: 2),
                with: .color(Color(red: 0.32, green: 0.19, blue: 0.10))
            )
            let page = CGRect(x: cover.maxX - 3.5, y: cover.minY + 2, width: 2.4, height: cover.height - 4)
            context.fill(Path(page), with: .color(VellumPalette.ivory))
            var band = Path()
            band.move(to: CGPoint(x: cover.minX + 9, y: cover.midY))
            band.addLine(to: CGPoint(x: cover.maxX - 5, y: cover.midY))
            context.stroke(
                band,
                with: .color(Color(red: 0.78, green: 0.62, blue: 0.34)),
                style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
            )
        }
    }
}

/// Notion N on cream paper.
private struct NotionNMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(VellumPalette.ivory)
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .strokeBorder(VellumPalette.ink.opacity(0.55), lineWidth: 1.2)
            NotionNStroke()
        }
    }
}

private struct NotionNStroke: View {
    var body: some View {
        Canvas { context, size in
            var n = Path()
            n.move(to: CGPoint(x: size.width * 0.30, y: size.height * 0.74))
            n.addLine(to: CGPoint(x: size.width * 0.30, y: size.height * 0.26))
            n.addLine(to: CGPoint(x: size.width * 0.70, y: size.height * 0.74))
            n.addLine(to: CGPoint(x: size.width * 0.70, y: size.height * 0.26))
            context.stroke(
                n,
                with: .color(VellumPalette.ink),
                style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(width: 22, height: 22)
    }
}

private struct FilePaperMark: View {
    var body: some View {
        Canvas { context, size in
            let sheet = CGRect(x: 6, y: 4, width: size.width - 12, height: size.height - 8)
            context.fill(
                Path(roundedRect: sheet, cornerRadius: 2.5),
                with: .color(VellumPalette.paper)
            )
            context.stroke(
                Path(roundedRect: sheet, cornerRadius: 2.5),
                with: .color(VellumPalette.ink.opacity(0.22)),
                lineWidth: 0.8
            )
            var y = sheet.minY + 8
            while y < sheet.maxY - 5 {
                var line = Path()
                line.move(to: CGPoint(x: sheet.minX + 3, y: y))
                line.addLine(to: CGPoint(x: sheet.maxX - 3, y: y))
                context.stroke(line, with: .color(VellumPalette.ink.opacity(0.16)), lineWidth: 0.7)
                y += 4.5
            }
        }
    }
}
