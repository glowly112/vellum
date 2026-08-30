import SwiftData
import SwiftUI
import UniformTypeIdentifiers

enum ImportPicker {
    static func types(for source: ImportSource) -> [UTType] {
        var types: [UTType] = [.plainText, .utf8PlainText, .text, .html]
        if let md = UTType(filenameExtension: "md") { types.append(md) }
        if let markdown = UTType(filenameExtension: "markdown") { types.append(markdown) }
        switch source {
        case .notes:
            types.append(.folder)
        case .journal:
            types.append(.pdf)
        case .notion:
            types.append(.commaSeparatedText)
            if let csv = UTType(filenameExtension: "csv") { types.append(csv) }
            types.append(.zip)
        case .file:
            types.append(.commaSeparatedText)
            types.append(.zip)
            types.append(.folder)
        }
        return types
    }
}

enum BringInFiles {
    static func drafts(from urls: [URL], source: ImportSource, now: Date = .now) -> Result<[ImportDraft], ImportError> {
        var payloads: [(name: String, data: Data, fileDate: Date?)] = []
        for url in urls {
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            payloads.append(contentsOf: collect(url))
        }
        return ImportGather.drafts(from: payloads, source: source, now: now)
    }

    static func fileDate(at url: URL) -> Date? {
        let values = try? url.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
        return ImportFileDate.pick(creation: values?.creationDate, modification: values?.contentModificationDate)
    }

    private static func collect(_ url: URL) -> [(name: String, data: Data, fileDate: Date?)] {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        let stamp = fileDate(at: url)
        if isDir.boolValue {
            var out: [(name: String, data: Data, fileDate: Date?)] = []
            let keys: [URLResourceKey] = [.isRegularFileKey, .creationDateKey, .contentModificationDateKey]
            guard let kids = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles]
            ) else { return [] }
            for case let child as URL in kids {
                guard keeps(child) else { continue }
                if let data = try? Data(contentsOf: child) {
                    out.append((child.lastPathComponent, data, fileDate(at: child) ?? stamp))
                }
            }
            return out
        }
        if let data = try? Data(contentsOf: url) {
            return [(url.lastPathComponent, data, stamp)]
        }
        return []
    }

    private static func keeps(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["txt", "text", "md", "markdown", "html", "htm", "csv", "zip", "pdf"].contains(ext)
    }
}

enum ImportApply {
    @MainActor
    static func ingest(
        _ result: Result<[ImportDraft], ImportError>,
        existing: [(title: String, body: String)],
        modelContext: ModelContext
    ) -> (message: String, isError: Bool) {
        switch result {
        case .failure(let error):
            return (error.copy, true)
        case .success(let drafts):
            let plan = ImportDecision.plan(drafts: drafts, existing: existing)
            if plan.keep.isEmpty {
                return (ImportCopy.result(brought: 0, skipped: plan.skipped), plan.skipped == 0)
            }
            let style = StylePreferences.last
            for draft in plan.keep {
                modelContext.insert(
                    Page(
                        title: draft.title,
                        body: draft.body,
                        createdAt: draft.createdAt,
                        updatedAt: draft.updatedAt,
                        fontId: style.typeface.rawValue,
                        paperId: style.paper.rawValue,
                        inkId: style.resolvedInk.rawValue,
                        sizeId: style.size.rawValue
                    )
                )
            }
            try? modelContext.save()
            return (ImportCopy.result(brought: plan.keep.count, skipped: plan.skipped), false)
        }
    }
}
