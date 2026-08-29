import Foundation

/// First-tap and hammer contracts that do not need SwiftUI.
enum PagePlainText {
    static func fileName(title: String, body: String) -> String {
        let base = PageCopy.displayTitle(title: title, body: body)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
        return "\(base).txt"
    }

    static func contents(title: String, body: String) -> String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty { return body }
        if body.isEmpty { return title }
        return "\(title)\n\n\(body)"
    }
}

enum ComposePolicy {
    static let cooldown: TimeInterval = 0.8

    static func reuseBlankPage(
        createdAt: Date,
        title: String,
        body: String,
        now: Date = .now
    ) -> Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && now.timeIntervalSince(createdAt) < cooldown
    }
}

enum DeleteDecision {
    static func shouldDelete(confirmed: Bool) -> Bool { confirmed }
}

enum SeedPolicy {
    static func shouldSeed(storeIsEmpty: Bool, didLaunch: Bool) -> Bool {
        storeIsEmpty && !didLaunch
    }
}

/// Style sheet order. Size is last so it stays reachable when the keyboard is up.
enum StyleSheetLayout {
    static let sections: [String] = ["Paper", "Type", "Ink", "Size"]
}

/// Keyboard inset is SwiftUI's safe area (includes the system keyboard).
/// A non-nil guessed pad is a just-works fail (KB_COVER).
enum KeyboardAvoidance {
    static let guessedBottomPoints: Double? = nil
}

/// Library merge: paper sheet is the object; chrome stays system iOS 26.
enum LibraryLook {
    static let cellKind = "paper-sheet"
    static let greetingFamily = Typeface.editorial.familyName
    static let composeKind = "system"
    static let composeSystemImage = "square.and.pencil"
    static let searchablePrompt = "Search pages"
    static let sheetMinHeight: Double = 176
    static let sheetCornerRadius: Double = 12
}

struct LibraryPage: RecencyPage, Equatable, Sendable {
    var title: String
    var body: String
    var updatedAt: Date
    var paper: Paper
    var typeface: Typeface
}

struct LibrarySheet: Equatable, Sendable {
    var kind: String
    var when: String
    var face: String
    var title: String
    var snippet: String?
    var footer: String
    var paper: Paper
    var typeface: Typeface
}

enum LibrarySheetCopy {
    static func cell(
        title: String,
        body: String,
        updatedAt: Date,
        paper: Paper,
        typeface: Typeface,
        now: Date = .now
    ) -> LibrarySheet {
        let display = PageCopy.displayTitle(title: title, body: body)
        let preview = PageCopy.preview(body)
        let showPreview = !preview.isEmpty && preview != display
        let words = PageCopy.wordCount(title, body)
        let noun = words == 1 ? "word" : "words"
        return LibrarySheet(
            kind: LibraryLook.cellKind,
            when: PageCopy.whenLabel(updatedAt, now: now),
            face: typeface.name,
            title: display,
            snippet: showPreview ? preview : nil,
            footer: "\(words) \(noun)  ·  \(paper.name)",
            paper: paper,
            typeface: typeface
        )
    }

    static func sheets(pages: [LibraryPage], query: String, now: Date = .now) -> [LibrarySheet] {
        LibraryGrouping.group(pages: pages, query: query, now: now)
            .flatMap(\.pages)
            .map {
                cell(
                    title: $0.title,
                    body: $0.body,
                    updatedAt: $0.updatedAt,
                    paper: $0.paper,
                    typeface: $0.typeface,
                    now: now
                )
            }
    }
}

enum LibraryEmpty {
    static func headline(searching: Bool) -> String {
        searching ? "Nothing matches" : "The desk is clear"
    }

    static func detail(searching: Bool) -> String {
        searching
            ? "Try a different word, or start a new page."
            : "A blank sheet, waiting. Start whenever you like."
    }
}

/// Editor merge: the page is a sheet on the desk; chrome stays system iOS 26.
enum EditorLook {
    static let surfaceKind = "sheet-on-desk"
    static let isFullBleed = false
    static let wrap = "native"
    static let backKind = "system"
    static let focusKind = "system-toolbar"
    static let stylesKind = "system-sheet"
    static let stylesSystemImage = "textformat"
    static let bodyKind = "text-editor"
    static let cornerRadius: Double = 16
    /// Thin side reveal. 24pt read as a postcard; 0 is full-bleed Notes.
    static let deskInset: Double = 14
    static let deskTop: Double = 8
    /// Thin desk below the sheet. 40pt floated the page.
    static let deskBottom: Double = 14
    /// Large page you write on. 0.76 was a postcard; 1.0 is Notes.
    static let sheetMaxHeightFraction: Double = 0.92
    static let guessedKeyboardPad: Double? = nil

    /// Height of the paper in the current safe-area field (keyboard-aware).
    /// Always shorter than the field so grain shows below. No guessed pad.
    static func sheetHeight(inField fieldHeight: Double) -> Double {
        let usable = max(0, fieldHeight - deskTop - deskBottom)
        let capped = fieldHeight * sheetMaxHeightFraction
        return min(usable, capped)
    }
}

struct EditorFooter: Equatable, Sendable {
    var words: String
    var style: String
    var placement: String
}

/// Debug-only launch: `VELLUM_OPEN_FIRST=1` pushes the first page so Mini
/// can photograph the editor without a tap. Release always returns false.
enum DebugOpenFirst {
    static let environmentKey = "VELLUM_OPEN_FIRST"

    #if DEBUG
    static let compileGateEnabled = true
    #else
    static let compileGateEnabled = false
    #endif

    static func shouldOpenFirstPage(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        debugBuild: Bool = compileGateEnabled
    ) -> Bool {
        debugBuild && environment[environmentKey] == "1"
    }

    static func pageToOpen<ID>(from ids: [ID]) -> ID? {
        ids.first
    }
}

enum EditorSheetCopy {
    static func footer(wordCount: Int, paper: Paper, typeface: Typeface) -> EditorFooter {
        let noun = wordCount == 1 ? "word" : "words"
        return EditorFooter(
            words: "\(wordCount) \(noun)",
            style: "\(paper.name) · \(typeface.name)",
            placement: "on-sheet"
        )
    }

    static func showsFooter(focus: Bool) -> Bool { !focus }
}

/// Stable grain seed. Do not use `UInt64(hashValue)` — `hashValue` is a signed
/// `Int` and traps (`Negative value is not representable`) on a negative seed.
enum PaperGrain {
    static func seed(for paper: Paper) -> UInt64 {
        seed(forToken: paper.rawValue)
    }

    static func seed(forToken token: String) -> UInt64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in token.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x0100_0000_01b3
        }
        return hash == 0 ? 0x9E37_79B9_7F4A_7C15 : hash
    }
}
