import SwiftUI

struct PaperCard: View {
    let page: Page

    var body: some View {
        let ink = page.ink
        let typeface = page.typeface
        let paper = page.paper
        let title = page.displayTitle
        let preview = page.preview
        let showPreview = !preview.isEmpty && preview != title

        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(PageCopy.whenLabel(page.updatedAt))
                Spacer(minLength: 8)
                Text(typeface.name.uppercased())
            }
            .font(VellumFonts.ui(.caption2, weight: .medium))
            .tracking(1.2)
            .foregroundStyle(ink.color.opacity(0.45))

            Text(title)
                .font(VellumFonts.page(typeface, size: 21.5, relativeTo: .title3))
                .foregroundStyle(ink.color)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.top, 10)

            if showPreview {
                Text(preview)
                    .font(VellumFonts.page(typeface, size: 15, relativeTo: .subheadline))
                    .foregroundStyle(ink.color.opacity(0.85))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8)
            }

            Spacer(minLength: 8)

            Text("\(page.words) \(page.words == 1 ? "word" : "words")  ·  \(paper.name)")
                .font(VellumFonts.ui(.caption2))
                .foregroundStyle(ink.color.opacity(0.40))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
        .background {
            PaperBackdrop(paper: paper, compact: true)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: VellumPalette.ink.opacity(paper.isDark ? 0.28 : 0.10), radius: 14, x: 0, y: 8)
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(VellumPalette.ink.opacity(paper.isDark ? 0.18 : 0.06), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(paper.name), \(typeface.name)")
    }
}
