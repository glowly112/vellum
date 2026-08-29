import Foundation
import UniformTypeIdentifiers
import CoreTransferable

/// Plain `.txt` for the system share sheet. No markdown, no PDF.
struct PageExport: Transferable {
    let fileName: String
    let text: String

    init(page: Page) {
        let base = PageCopy.displayTitle(title: page.title, body: page.body)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        fileName = "\(base).txt"
        if page.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            text = page.body
        } else if page.body.isEmpty {
            text = page.title
        } else {
            text = "\(page.title)\n\n\(page.body)"
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .plainText) { export in
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(export.fileName)
            try export.text.write(to: url, atomically: true, encoding: .utf8)
            return SentTransferredFile(url)
        }
    }
}
