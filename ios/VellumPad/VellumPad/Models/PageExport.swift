import Foundation
import UniformTypeIdentifiers
import CoreTransferable

/// Plain `.txt` for the system share sheet. No markdown, no PDF.
struct PageExport: Transferable {
    let fileName: String
    let text: String

    init(page: Page) {
        fileName = PagePlainText.fileName(title: page.title, body: page.body)
        text = PagePlainText.contents(title: page.title, body: page.body)
    }

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .plainText) { export in
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(export.fileName)
            try export.text.write(to: url, atomically: true, encoding: .utf8)
            return SentTransferredFile(url)
        }
    }
}
