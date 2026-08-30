import SwiftUI

/// Library cell: the page is a paper sheet, not a Notes thumbnail beside a row.
struct PaperSheet: View {
    let page: Page

    var body: some View {
        let sheet = LibrarySheetCopy.cell(
            title: page.title,
            body: page.body,
            updatedAt: page.updatedAt,
            paper: page.paper,
            typeface: page.typeface
        )
        let ink = page.ink
        let titleSize: CGFloat = sheet.typeface == .hand ? 24 : 22
        let snippetSize: CGFloat = sheet.typeface == .hand ? 17 : 15

        VStack(alignment: .leading, spacing: 0) {
            Text(sheet.title)
                .font(VellumFonts.page(sheet.typeface, size: titleSize, relativeTo: .title3))
                .foregroundStyle(ink.color)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let snippet = sheet.snippet {
                Text(snippet)
                    .font(VellumFonts.page(sheet.typeface, size: snippetSize, relativeTo: .subheadline))
                    .foregroundStyle(ink.color.opacity(0.85))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8)
            }

            Spacer(minLength: 10)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if page.pinOn {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                }
                Text(sheet.footer)
                    .font(VellumFonts.ui(.caption2, weight: .medium))
                    .tracking(0.4)
                Spacer(minLength: 0)
            }
            .foregroundStyle(ink.color.opacity(0.40))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, minHeight: CGFloat(LibraryLook.sheetMinHeight), alignment: .topLeading)
        .background {
            PaperBackdrop(paper: sheet.paper, compact: true)
        }
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(LibraryLook.sheetCornerRadius), style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CGFloat(LibraryLook.sheetCornerRadius), style: .continuous)
                .strokeBorder(VellumPalette.ink.opacity(sheet.paper.isDark ? 0.28 : 0.10), lineWidth: 1)
        }
        .shadow(color: VellumPalette.lift, radius: 8, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: CGFloat(LibraryLook.sheetCornerRadius), style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(sheet.title), \(sheet.footer)")
    }
}

/// Paper stamp on the empty desk. Same object as the web Mark:
/// cream sheet, rust margin, serif V. Decorative — not the word Vellum.
/// Not a stacked empty-state card. Not an SF symbol.
struct EmptyDeskMark: View {
    private let corner: CGFloat = 14

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(VellumPalette.paper)
            PaperBackdrop(paper: .cream, compact: true, drawsRuling: false)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            Capsule()
                .fill(VellumPalette.rust)
                .frame(width: 2.5, height: 54)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 16)
            Text(LibraryEmpty.markLetter)
                .font(VellumFonts.page(.editorial, size: 40, relativeTo: .title))
                .fontWeight(.bold)
                .foregroundStyle(VellumPalette.ink)
                .offset(x: 7, y: 3)
        }
        .frame(width: 80, height: 80)
        .overlay {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(VellumPalette.ink.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: VellumPalette.lift, radius: 8, y: 3)
        .rotationEffect(.degrees(-2.5))
        .accessibilityHidden(true)
    }
}

struct PaperSheetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    PaperSheet(
        page: Page(
            title: SampleDeskCopy.bookTitle,
            body: SampleDeskCopy.bookBody,
            fontId: Typeface.book.rawValue,
            paperId: Paper.cream.rawValue
        )
    )
    .padding()
    .background { DeskBackdrop() }
}
