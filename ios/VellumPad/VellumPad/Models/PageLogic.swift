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

/// Editor merge: writing column, not a library card. Chrome stays system iOS 26.
///
/// Apple TextEditor — “A view that can display and edit long-form text.”
/// Multiline, scrollable. Several paragraphs must not clip.
/// Apple safeAreaInset — shows specified content beside the modified view and
/// increases the safe area by that content. Word-count is that inset, not a
/// footer glued inside a short card.
/// Paper fills under the system toolbar down to the inset. Desk grain peeks
/// at the edges only. Keyboard uses the system keyboard safe area — do not
/// guess 34 or 120. Keyboard-open is still undone.
enum EditorLook {
    static let surfaceKind = "sheet-on-desk"
    /// Discard `fraction-card` (`0.76`, `0.92` / 14pt). That is still a postcard.
    static let layoutKind = "column-plus-inset"
    static let isFullBleed = false
    static let wrap = "native"
    static let backKind = "system"
    static let focusKind = "system-toolbar"
    static let stylesKind = "system-sheet"
    static let stylesSystemImage = "textformat"
    static let bodyKind = "text-editor"
    static let cornerRadius: Double = 16
    /// Thin desk grain at the edges only — not a 14/24pt postcard gutter.
    static let deskPeek: Double = 6
    /// No height-fraction card. Paper is the column background.
    static let sheetMaxHeightFraction: Double? = nil
    static let footerPlacement = "safeAreaInset"
    static let fillsToolbarToInset = true
    static let grainReveal = "edge-only"
    static let bodyHoldsSeveralParagraphs = true
    static let clipsBody = false
    /// Four short paragraphs. `TextEditor` is scrollable; the column must be tall enough.
    static let bodyMinHeight: Double = 280
    static let chromeAboveBody: Double = 80
    static let severalParagraphHeight: Double = 240
    static let guessedKeyboardPad: Double? = nil
    static let forbiddenGuessedPads: [Double] = []
    static let minimumHit: Double = 44
    /// Mini keyboard-open pixels are still unwatched. Do not call the editor done.
    static let keyboardOpenProven = false

    /// Paper height in the field under the toolbar, above the word-count inset.
    /// Peek is edge-only. No `sheetMaxHeightFraction`.
    static func writingHeight(inField fieldHeight: Double) -> Double {
        max(0, fieldHeight - deskPeek * 2)
    }

    static func bodyFitsSeveralParagraphs(inFieldHeight field: Double) -> Bool {
        writingHeight(inField: field) - chromeAboveBody >= severalParagraphHeight
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
            placement: "safeAreaInset"
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
