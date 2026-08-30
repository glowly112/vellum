import Foundation

/// One-shot bring-in. Not sync. Not accounts. Not folders.
enum ImportLook {
    static let kind = "one-shot"
    static let isLiveSync = false
    static let hasAccounts = false
    static let hasSettingsScreen = false
    static let livesInConnections = true
    static let usesPrivateNotesKit = false
    static let usesNotionOAuth = false
    static let sources = ["Notes", "Journal", "Notion"]
    static let storeName = "vellum-pages"
    static let displayName = "Velin"
    /// Recency uses `updatedAt`. Import must write both dates.
    static let writesBothDates = true
    static let inventedDateIsFail = true
    static let emptyIsError = true
    static let skipsDuplicates = true
    static let bringInKind = "system-sheet"
    static let bringInTitle = "Import"
    static let presentsFileImporter = true
    static let fileImporterHost = "connections"
    static let pickHint = "Pick an exported file."
    static let hasSourceMarks = true
    static let sourceMarkKind = "app-icon"
    static let hasShareExtension = false
    static let appGroup = "group.com.jamiematheson.vellumpad"
    static let urlScheme = "velin"
}

enum ImportSource: String, CaseIterable, Sendable {
    case notes
    case journal
    case notion
    case file

    var title: String {
        switch self {
        case .notes: "Notes"
        case .journal: "Journal"
        case .notion: "Notion"
        case .file: "File"
        }
    }

    var hint: String {
        switch self {
        case .notes: "Pick a Notes export."
        case .journal: "Pick a Journal export."
        case .notion: "Pick a Notion CSV or Markdown."
        case .file: "Pick an exported file."
        }
    }

    var markKind: String {
        switch self {
        case .notes: ImportMarkLook.notes
        case .journal: ImportMarkLook.journal
        case .notion: ImportMarkLook.notion
        case .file: ImportMarkLook.file
        }
    }
}

enum ImportError: Error, Equatable, Sendable {
    case empty
    case noDate
    case unreadable
    case needsUnzip
    case needsText

    var copy: String {
        switch self {
        case .empty:
            return "Nothing to import."
        case .noDate:
            return "This page has no date. Velin won’t guess one."
        case .unreadable:
            return "Velin couldn’t read that file."
        case .needsUnzip:
            return "Unzip the Notion export, then import the CSV or Markdown."
        case .needsText:
            return "Export that as text, then import it."
        }
    }
}

struct ImportDraft: Equatable, Sendable {
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var source: ImportSource
}

struct ImportPlan: Equatable, Sendable {
    var keep: [ImportDraft]
    var skipped: Int
}

struct ImportInboxItem: Codable, Equatable, Sendable {
    var title: String
    var body: String
    var createdAt: TimeInterval?
    var updatedAt: TimeInterval?
    var fileDate: TimeInterval?
    var source: String
}

enum ImportDating {
    /// Bind source dates. Never invent `.now`. File date is last resort.
    static func bind(
        created: Date?,
        updated: Date?,
        fileDate: Date?,
        now: Date = .now
    ) -> Result<(created: Date, updated: Date), ImportError> {
        let source = updated ?? created ?? fileDate
        guard let source else { return .failure(.noDate) }
        let createdAt = created ?? source
        let updatedAt = updated ?? created ?? source
        _ = now
        return .success((createdAt, updatedAt))
    }

    static func usesNow(_ date: Date, now: Date) -> Bool {
        abs(date.timeIntervalSince(now)) < 1
    }

    static func parse(_ raw: String) -> Date? {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return nil }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: text) { return date }
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: text) { return date }
        iso.formatOptions = [.withFullDate]
        if let date = iso.date(from: text) { return date }

        let forms = [
            "MMMM d, yyyy h:mm a",
            "MMMM d, yyyy H:mm",
            "MMMM d, yyyy 'at' h:mm a",
            "MMMM d, yyyy",
            "d MMMM yyyy H:mm",
            "d MMMM yyyy 'at' H:mm",
            "d MMMM yyyy 'at' h:mm a",
            "d MMMM yyyy",
            "EEEE, MMMM d, yyyy",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd",
            "MMM d, yyyy h:mm a",
            "MMM d, yyyy",
            "M/d/yyyy h:mm a",
            "M/d/yyyy",
        ]
        let locales = [Locale(identifier: "en_US_POSIX"), Locale(identifier: "en_GB")]
        for form in forms {
            for locale in locales {
                let formatter = DateFormatter()
                formatter.locale = locale
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.dateFormat = form
                if let date = formatter.date(from: text) { return date }
            }
        }
        return nil
    }
}

enum ImportMarkLook {
    static let kind = "app-icon"
    static let usesSF = false
    static let usesGenericCircle = false
    static let usesDrawnPaths = false
    static let notes = "notes"
    static let journal = "journal"
    static let notion = "notion"
    static let file = "paper"
    static let imagesets = [notes, journal, notion]
    static let pointSize = 38.0
    static let cornerRatio = 0.22
}

enum ImportCopy {
    static let keepsDate = "A page keeps the date it was written."
    static let pickHint = ImportLook.pickHint
    static let shareHint = "Or share a note to Velin."

    static func result(brought: Int, skipped: Int) -> String {
        if brought == 0, skipped > 0 { return "Already on the desk." }
        if brought == 1, skipped == 0 { return "Imported 1 page." }
        if brought > 1, skipped == 0 { return "Imported \(brought) pages." }
        if brought > 0, skipped > 0 {
            return "Imported \(brought). \(skipped) already here."
        }
        return ImportError.empty.copy
    }
}

enum ImportDecision {
    static func fingerprint(title: String, body: String) -> String {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = body.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(t)\n\n\(b)"
    }

    static func plan(
        drafts: [ImportDraft],
        existing: [(title: String, body: String)]
    ) -> ImportPlan {
        var seen = Set(existing.map { fingerprint(title: $0.title, body: $0.body) })
        var keep: [ImportDraft] = []
        var skipped = 0
        for draft in drafts {
            let key = fingerprint(title: draft.title, body: draft.body)
            if seen.contains(key) {
                skipped += 1
                continue
            }
            seen.insert(key)
            keep.append(draft)
        }
        return ImportPlan(keep: keep, skipped: skipped)
    }
}

enum ImportFileDate {
    static func pick(creation: Date?, modification: Date?) -> Date? {
        creation ?? modification
    }
}

enum ImportGather {
    static func drafts(
        from payloads: [(name: String, data: Data, fileDate: Date?)],
        source: ImportSource,
        now: Date = .now
    ) -> Result<[ImportDraft], ImportError> {
        if payloads.isEmpty { return .failure(.empty) }
        var all: [ImportDraft] = []
        var lastError: ImportError?
        for payload in payloads {
            switch ImportRead.file(
                name: payload.name,
                data: payload.data,
                fileDate: payload.fileDate,
                source: source,
                now: now
            ) {
            case .success(let drafts):
                all.append(contentsOf: drafts)
            case .failure(let error):
                lastError = error
            }
        }
        if all.isEmpty { return .failure(lastError ?? .empty) }
        return .success(all)
    }
}

enum ImportInbox {
    static let appGroup = ImportLook.appGroup
    static let fileName = "inbox.json"
    static let urlScheme = ImportLook.urlScheme
    static let urlHost = "inbox"

    static func containerURL() -> URL? {
        #if canImport(UIKit)
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        #else
        nil
        #endif
    }

    static func fileURL() -> URL? {
        containerURL()?.appendingPathComponent(fileName)
    }

    static func encode(_ items: [ImportInboxItem]) -> Data {
        (try? JSONEncoder().encode(items)) ?? Data()
    }

    static func decode(_ data: Data) -> [ImportInboxItem] {
        (try? JSONDecoder().decode([ImportInboxItem].self, from: data)) ?? []
    }

    static func write(_ items: [ImportInboxItem]) -> Bool {
        guard let url = fileURL() else { return false }
        do {
            try encode(items).write(to: url, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    static func take() -> [ImportInboxItem] {
        guard let url = fileURL(),
              let data = try? Data(contentsOf: url)
        else { return [] }
        try? FileManager.default.removeItem(at: url)
        return decode(data)
    }

    static func item(from draft: ImportDraft) -> ImportInboxItem {
        ImportInboxItem(
            title: draft.title,
            body: draft.body,
            createdAt: draft.createdAt.timeIntervalSince1970,
            updatedAt: draft.updatedAt.timeIntervalSince1970,
            fileDate: nil,
            source: draft.source.rawValue
        )
    }

    static func drafts(from items: [ImportInboxItem], now: Date = .now) -> Result<[ImportDraft], ImportError> {
        var drafts: [ImportDraft] = []
        var lastError: ImportError = .empty
        for item in items {
            let source = ImportSource(rawValue: item.source) ?? .file
            if !ImportRead.hasInk(title: item.title, body: item.body) {
                lastError = .empty
                continue
            }
            let created = item.createdAt.map(Date.init(timeIntervalSince1970:))
            let updated = item.updatedAt.map(Date.init(timeIntervalSince1970:))
            let fileDate = item.fileDate.map(Date.init(timeIntervalSince1970:))
            switch ImportDating.bind(created: created, updated: updated, fileDate: fileDate, now: now) {
            case .failure(let error):
                lastError = error
            case .success(let dates):
                drafts.append(
                    ImportDraft(
                        title: item.title,
                        body: item.body,
                        createdAt: dates.created,
                        updatedAt: dates.updated,
                        source: source
                    )
                )
            }
        }
        if drafts.isEmpty { return .failure(lastError) }
        return .success(drafts)
    }

    static func payloadURL(items: [ImportInboxItem]) -> URL? {
        let b64 = encode(items).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        if b64.count > 1800 {
            return URL(string: "\(urlScheme)://\(urlHost)")
        }
        return URL(string: "\(urlScheme)://\(urlHost)?p=\(b64)")
    }

    static func items(from url: URL) -> [ImportInboxItem] {
        guard url.scheme == urlScheme else { return [] }
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        guard let p = query?.first(where: { $0.name == "p" })?.value else {
            return take()
        }
        var b64 = p
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while b64.count % 4 != 0 { b64.append("=") }
        guard let data = Data(base64Encoded: b64) else { return take() }
        let decoded = decode(data)
        return decoded.isEmpty ? take() : decoded
    }
}

enum ImportRead {
    /// Same ink bar as `LibraryListing`. Kept here so ShareToVelin compiles this file alone.
    static func hasInk(title: String, body: String) -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !body.split { $0.isWhitespace || $0.isNewline }.isEmpty
    }

    static func file(
        name: String,
        data: Data,
        fileDate: Date?,
        source: ImportSource,
        now: Date = .now
    ) -> Result<[ImportDraft], ImportError> {
        if data.isEmpty { return .failure(.empty) }
        if isZip(name, data: data) { return .failure(.needsUnzip) }
        if isPDF(name, data: data) { return .failure(.needsText) }
        let lower = name.lowercased()
        if lower.hasSuffix(".csv") || looksLikeCSV(data) {
            return csv(data, fileDate: fileDate, source: source == .file ? .notion : source, now: now)
        }
        guard let text = decode(data) else { return .failure(.unreadable) }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .failure(.empty)
        }
        if looksLikeCSV(text: text) {
            return csv(data, fileDate: fileDate, source: source == .file ? .notion : source, now: now)
        }
        return textPage(name: name, text: text, fileDate: fileDate, source: source, now: now)
    }

    static func excerpt(name: String, text: String) -> (title: String, body: String, date: Date?) {
        let cleaned = stripHTML(text).replacingOccurrences(of: "\r\n", with: "\n")
        return splitPage(cleaned, fallbackTitle: titleFromFileName(name))
    }

    static func textPage(
        name: String,
        text: String,
        fileDate: Date?,
        source: ImportSource,
        now: Date = .now
    ) -> Result<[ImportDraft], ImportError> {
        let parsed = excerpt(name: name, text: text)
        if !hasInk(title: parsed.title, body: parsed.body) {
            return .failure(.empty)
        }
        switch ImportDating.bind(created: parsed.date, updated: parsed.date, fileDate: fileDate, now: now) {
        case .failure(let error):
            return .failure(error)
        case .success(let dates):
            return .success([
                ImportDraft(
                    title: parsed.title,
                    body: parsed.body,
                    createdAt: dates.created,
                    updatedAt: dates.updated,
                    source: source
                ),
            ])
        }
    }

    static func csv(
        _ data: Data,
        fileDate: Date?,
        source: ImportSource,
        now: Date = .now
    ) -> Result<[ImportDraft], ImportError> {
        guard let text = decode(data) else { return .failure(.unreadable) }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .failure(.empty)
        }
        let table = CSVTable.parse(text)
        guard !table.headers.isEmpty else { return .failure(.empty) }
        if table.rows.isEmpty { return .failure(.empty) }

        let titleKey = firstHeader(in: table.headers, matching: ["name", "title", "page", "note"])
        let createdKey = firstHeader(in: table.headers, matching: [
            "created time", "created", "created at", "creation time",
        ])
        let updatedKey = firstHeader(in: table.headers, matching: [
            "last edited time", "last edited", "updated", "updated at", "last edited at",
        ])
        let bodyKey = firstHeader(in: table.headers, matching: [
            "text", "content", "body", "markdown", "notes", "page content",
        ])

        var drafts: [ImportDraft] = []
        var missingDate = false
        for row in table.rows {
            let title = titleKey.flatMap { row[$0] } ?? ""
            let body = bodyKey.flatMap { row[$0] } ?? leftoverBody(row, excluding: [titleKey, createdKey, updatedKey])
            if !hasInk(title: title, body: body) { continue }
            let created = createdKey.flatMap { row[$0] }.flatMap(ImportDating.parse)
            let updated = updatedKey.flatMap { row[$0] }.flatMap(ImportDating.parse)
            switch ImportDating.bind(created: created, updated: updated, fileDate: fileDate, now: now) {
            case .failure:
                missingDate = true
            case .success(let dates):
                drafts.append(
                    ImportDraft(
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        body: body.trimmingCharacters(in: .whitespacesAndNewlines),
                        createdAt: dates.created,
                        updatedAt: dates.updated,
                        source: source
                    )
                )
            }
        }
        if drafts.isEmpty {
            return .failure(missingDate ? .noDate : .empty)
        }
        return .success(drafts)
    }

    private static func leftoverBody(
        _ row: [String: String],
        excluding: [String?]
    ) -> String {
        let skip = Set(excluding.compactMap { $0 })
        return row.keys.sorted()
            .filter { !skip.contains($0) }
            .compactMap { key in
                let value = row[key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if value.isEmpty { return nil }
                return value
            }
            .joined(separator: "\n")
    }

    private static func firstHeader(in headers: [String], matching keys: [String]) -> String? {
        let wanted = Set(keys)
        return headers.first { wanted.contains($0) }
    }

    private static func decode(_ data: Data) -> String? {
        if let text = String(data: data, encoding: .utf8) { return stripBOM(text) }
        return String(data: data, encoding: .utf16)
    }

    private static func stripBOM(_ text: String) -> String {
        if text.hasPrefix("\u{feff}") {
            return String(text.dropFirst())
        }
        return text
    }

    private static func looksLikeCSV(_ data: Data) -> Bool {
        guard let text = decode(data) else { return false }
        return looksLikeCSV(text: text)
    }

    private static func looksLikeCSV(text: String) -> Bool {
        let first = text.split(whereSeparator: \.isNewline).first.map(String.init) ?? ""
        let lower = first.lowercased()
        return lower.contains("created time") || lower.contains("last edited")
    }

    private static func isZip(_ name: String, data: Data) -> Bool {
        if name.lowercased().hasSuffix(".zip") { return true }
        return data.starts(with: [0x50, 0x4B, 0x03, 0x04])
            || data.starts(with: [0x50, 0x4B, 0x05, 0x06])
    }

    private static func isPDF(_ name: String, data: Data) -> Bool {
        if name.lowercased().hasSuffix(".pdf") { return true }
        return data.starts(with: Array("%PDF".utf8))
    }

    private static func titleFromFileName(_ name: String) -> String {
        let base = (name as NSString).deletingPathExtension
        let trimmed = base.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "" : trimmed
    }

    private static func stripHTML(_ text: String) -> String {
        guard text.localizedCaseInsensitiveContains("<html")
            || text.localizedCaseInsensitiveContains("<body")
            || text.contains("<p")
            || text.contains("<h1")
        else { return text }
        var out = text
        out = out.replacingOccurrences(of: #"<br\s*/?>"#, with: "\n", options: .regularExpression)
        out = out.replacingOccurrences(of: #"</p>"#, with: "\n\n", options: [.regularExpression, .caseInsensitive])
        out = out.replacingOccurrences(of: #"</h[1-6]>"#, with: "\n", options: [.regularExpression, .caseInsensitive])
        out = out.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
        out = out.replacingOccurrences(of: "&nbsp;", with: " ")
        out = out.replacingOccurrences(of: "&amp;", with: "&")
        out = out.replacingOccurrences(of: "&lt;", with: "<")
        out = out.replacingOccurrences(of: "&gt;", with: ">")
        out = out.replacingOccurrences(of: "&quot;", with: "\"")
        return out
    }

    private static func splitPage(_ text: String, fallbackTitle: String) -> (title: String, body: String, date: Date?) {
        var lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var date: Date?
        var title = ""

        if lines.first?.trimmingCharacters(in: .whitespaces) == "---" {
            lines.removeFirst()
            var matter: [String] = []
            while let line = lines.first {
                lines.removeFirst()
                if line.trimmingCharacters(in: .whitespaces) == "---" { break }
                matter.append(line)
            }
            for line in matter {
                let parts = line.split(separator: ":", maxSplits: 1).map {
                    $0.trimmingCharacters(in: .whitespaces)
                }
                guard parts.count == 2 else { continue }
                let key = parts[0].lowercased()
                if key == "title" { title = parts[1] }
                if key == "created" || key == "updated" || key == "date" {
                    date = date ?? ImportDating.parse(parts[1])
                }
            }
        }

        while let first = lines.first, first.trimmingCharacters(in: .whitespaces).isEmpty {
            lines.removeFirst()
        }
        if date == nil {
            var index = 0
            while index < min(6, lines.count) {
                let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
                let stripped = trimmed.replacingOccurrences(
                    of: #"^(date|created|updated|modified|last edited|last modified|created on)\s*[:–-]\s*"#,
                    with: "",
                    options: [.regularExpression, .caseInsensitive]
                )
                if let found = ImportDating.parse(stripped) {
                    date = found
                    lines.remove(at: index)
                    continue
                }
                index += 1
            }
        }
        if title.isEmpty, let first = lines.first {
            let heading = first.trimmingCharacters(in: .whitespaces)
            if heading.hasPrefix("#") {
                title = heading.replacingOccurrences(of: #"^#+\s*"#, with: "", options: .regularExpression)
                lines.removeFirst()
            } else if heading.count < 80, ImportDating.parse(heading) == nil {
                title = heading
                lines.removeFirst()
            }
        }
        if title.isEmpty { title = fallbackTitle }
        let body = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        return (title, body, date)
    }
}

/// Small quoted-CSV reader. Enough for Notion export.
struct CSVTable {
    var headers: [String]
    var rows: [[String: String]]

    static func parse(_ text: String) -> CSVTable {
        let records = records(in: text)
        guard let head = records.first else {
            return CSVTable(headers: [], rows: [])
        }
        let headers = head.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        var rows: [[String: String]] = []
        for record in records.dropFirst() {
            var row: [String: String] = [:]
            for (index, header) in headers.enumerated() {
                let value = index < record.count ? record[index] : ""
                row[header] = value
            }
            if row.values.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                rows.append(row)
            }
        }
        return CSVTable(headers: headers, rows: rows)
    }

    private static func records(in text: String) -> [[String]] {
        var records: [[String]] = []
        var field = ""
        var row: [String] = []
        var quoted = false
        let chars = Array(text)
        var i = 0
        while i < chars.count {
            let ch = chars[i]
            if quoted {
                if ch == "\"" {
                    if i + 1 < chars.count, chars[i + 1] == "\"" {
                        field.append("\"")
                        i += 1
                    } else {
                        quoted = false
                    }
                } else {
                    field.append(ch)
                }
            } else if ch == "\"" {
                quoted = true
            } else if ch == "," {
                row.append(field)
                field = ""
            } else if ch == "\n" || ch == "\r" {
                if ch == "\r", i + 1 < chars.count, chars[i + 1] == "\n" {
                    i += 1
                }
                row.append(field)
                field = ""
                if row.contains(where: { !$0.isEmpty }) {
                    records.append(row)
                }
                row = []
            } else {
                field.append(ch)
            }
            i += 1
        }
        if quoted || !field.isEmpty || !row.isEmpty {
            row.append(field)
            if row.contains(where: { !$0.isEmpty }) {
                records.append(row)
            }
        }
        return records
    }
}
