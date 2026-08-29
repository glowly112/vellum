import SwiftUI

/// Library row: a small paper stamp plus type, not a wall of identical cards.
struct PaperRow: View {
    let page: Page

    var body: some View {
        let ink = page.ink
        let typeface = page.typeface
        let paper = page.paper
        let title = page.displayTitle
        let preview = page.preview
        let showPreview = !preview.isEmpty && preview != title

        HStack(alignment: .top, spacing: 14) {
            PaperStamp(paper: paper, typeface: typeface, ink: ink)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(VellumFonts.page(typeface, size: 20, relativeTo: .headline))
                    .foregroundStyle(VellumPalette.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if showPreview {
                    Text(preview)
                        .font(VellumFonts.ui(.subheadline))
                        .foregroundStyle(VellumPalette.inkSoft)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Text(
                    "\(PageCopy.whenLabel(page.updatedAt))  ·  \(page.words) \(page.words == 1 ? "word" : "words")  ·  \(paper.name)  ·  \(typeface.name)"
                )
                .font(VellumFonts.ui(.caption2, weight: .medium))
                .foregroundStyle(VellumPalette.inkFaint)
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .frame(minHeight: HitTarget.minimum, alignment: .top)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(paper.name), \(typeface.name)")
    }
}

struct PaperStamp: View {
    let paper: Paper
    let typeface: Typeface
    let ink: Ink

    var body: some View {
        ZStack(alignment: .topLeading) {
            PaperBackdrop(paper: paper, compact: true)
            Text("Aa")
                .font(VellumFonts.page(typeface, size: 15, relativeTo: .caption))
                .foregroundStyle(ink.color)
                .padding(.top, paper.ruling == .lines ? 14 : 10)
                .padding(.leading, paper.ruling == .lines ? 12 : 8)
        }
        .frame(width: 48, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(VellumPalette.ink.opacity(paper.isDark ? 0.28 : 0.10), lineWidth: 1)
        }
        .shadow(color: VellumPalette.ink.opacity(0.10), radius: 3, y: 1)
        .accessibilityHidden(true)
    }
}
