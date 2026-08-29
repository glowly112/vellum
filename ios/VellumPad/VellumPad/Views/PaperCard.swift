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
            HStack(alignment: .firstTextBaseline) {
                Text(sheet.when)
                Spacer(minLength: 8)
                if page.pinOn {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                }
                Text(sheet.face)
            }
            .font(VellumFonts.ui(.caption2, weight: .medium))
            .tracking(1.4)
            .textCase(.uppercase)
            .foregroundStyle(ink.color.opacity(0.45))

            Text(sheet.title)
                .font(VellumFonts.page(sheet.typeface, size: titleSize, relativeTo: .title3))
                .foregroundStyle(ink.color)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.top, 12)

            if let snippet = sheet.snippet {
                Text(snippet)
                    .font(VellumFonts.page(sheet.typeface, size: snippetSize, relativeTo: .subheadline))
                    .foregroundStyle(ink.color.opacity(0.85))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8)
            }

            Spacer(minLength: 10)

            Text(sheet.footer)
                .font(VellumFonts.ui(.caption2, weight: .medium))
                .tracking(0.4)
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
        .shadow(color: VellumPalette.ink.opacity(0.12), radius: 8, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: CGFloat(LibraryLook.sheetCornerRadius), style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(sheet.title), \(sheet.paper.name), \(sheet.typeface.name)")
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
            title: "Late light on the river",
            body: "The Thames is the colour of pewter this evening.",
            fontId: Typeface.book.rawValue,
            paperId: Paper.cream.rawValue
        )
    )
    .padding()
    .background(VellumPalette.desk)
}
