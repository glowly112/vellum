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
        .shadow(color: VellumPalette.ink.opacity(0.12), radius: 8, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: CGFloat(LibraryLook.sheetCornerRadius), style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(sheet.title), \(sheet.footer)")
    }
}

/// Quiet blank cream sheet on the desk. Not an SF symbol.
/// One faint rule; a second sheet sits behind so paper is the object.
struct EmptyDeskMark: View {
    var body: some View {
        ZStack {
            sheetCard
                .offset(x: 7, y: 8)
                .opacity(0.45)
            sheetCard
        }
        .padding(.trailing, 7)
        .padding(.bottom, 8)
        .frame(width: 116, height: 144)
        .accessibilityHidden(true)
    }

    private var sheetCard: some View {
        RoundedRectangle(cornerRadius: CGFloat(LibraryLook.sheetCornerRadius) - 2, style: .continuous)
            .fill(VellumPalette.paper)
            .overlay {
                PaperBackdrop(paper: .cream, compact: true, drawsRuling: false)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: CGFloat(LibraryLook.sheetCornerRadius) - 2,
                            style: .continuous
                        )
                    )
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(VellumPalette.rule.opacity(0.28))
                    .frame(height: 1)
                    .padding(.top, 36)
                    .padding(.horizontal, 14)
            }
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat(LibraryLook.sheetCornerRadius) - 2, style: .continuous)
                    .strokeBorder(VellumPalette.ink.opacity(0.10), lineWidth: 1)
            }
            .shadow(color: VellumPalette.ink.opacity(0.10), radius: 6, y: 2)
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
    .background(VellumPalette.desk)
}
