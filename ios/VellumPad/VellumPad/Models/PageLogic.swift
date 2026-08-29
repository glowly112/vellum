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
    static let lastSectionReachable = true
    /// Open large so Typewriter and Size are not clipped on a medium detent.
    static let detentKind = "medium-first"
    static let scrollBottomPad: Double = 56
}

/// Keyboard inset is SwiftUI's safe area (includes the system keyboard).
/// A non-nil guessed pad is a just-works fail (KB_COVER).
enum KeyboardAvoidance {
    static let guessedBottomPoints: Double? = nil
    /// A few points above the keys / predictive bar. 16 was a tall paper band.
    /// Not a keyboard height (not 34 / 120).
    static let wordCountAir: Double = 4

    static func wordCountBottomPad(keyboardLift: Double) -> Double {
        keyboardLift > 0 ? wordCountAir : 0
    }
}

/// Keyboard-open chrome. The clip’s fail is jank: text jumps to the end
/// the moment the keyboard starts moving, because a safe-area read snaps.
/// Paper still fills beside / behind the keys so a system-white gutter cannot
/// show. Do not guess 34 / 120.
enum KeyboardChrome {
    /// Paper ignores both. `.container` only lets the paper resize with the keys.
    static let paperRegions: [String] = ["container", "keyboard"]
    /// Left and right of the keys (and behind them) are paper, not window white.
    static let gutterFill = "paper"
    static let systemWhiteGutter = false
    /// Bottom pad follows `keyboardLayoutGuide` (animates). Not a jumped safe area.
    static let liftKind = "layout-guide"
    static let liftJumpsAtAnimationStart = false
    static let textTracksKeyboard = true
    /// Caption on the keys. Build 11’s remaining band was `minimumHit` (44) on the Text.
    static let wordCountSitsOnKeyboard = true
    static let wordCountKind = "caption"
    static let wordCountUsesMinimumHit = false
    static let forbiddenWordCountAir: [Double] = [16, 34, 120]
    /// Open pad is guide minus resting. Full guide is one home-indicator too tall.
    static let openPadIsKeyboardOnly = true

    /// Closed: resting (home indicator). Open: keyboard-only. No guessed 34 / 42 / 44.
    static func writingBottomPad(guidePad: Double, restingPad: Double = 0) -> Double {
        let lift = keyboardOnlyLift(guidePad: guidePad, restingPad: restingPad)
        if lift > 0 { return lift }
        return max(0, guidePad)
    }

    /// First measured resting inset (home indicator). Not a guessed 34.
    static func restingPad(current: Double, reported: Double) -> Double {
        guard reported > 0 else { return current }
        if current == 0 || reported < current { return reported }
        return current
    }

    /// Keyboard-only lift for word-count air. Zero until resting is known.
    static func keyboardOnlyLift(guidePad: Double, restingPad: Double) -> Double {
        guard restingPad > 0 else { return 0 }
        return max(0, guidePad - restingPad)
    }
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
    static let deleteKind = "swipe-and-menu"
    static let pinKind = "swipe-and-menu"
}

enum LibraryPin {
    static func isPinnedAfterToggle(_ current: Bool) -> Bool { !current }
}

/// How a `vellum-pages` row must be shaped so a phone on build 7 can open build 9.
///
/// Build 7 stored pageID…sizeId and no pin. Build 8 added a required `isPinned: Bool`
/// and `VellumPadApp` `fatalError`s if ModelContainer fails. SwiftData cannot
/// lightweight-migrate a missing column onto a required Bool — that is the crash.
/// An optional pin (`nil` → unpinned) is a default SwiftData can apply. Do not
/// wipe the store or fall back to in-memory.
enum PageStoreOpen {
    /// Live stored pin. Must stay optional. Required Bool is the 1.0.0 (8) crash.
    struct CurrentRow: Codable, Equatable, Sendable {
        var pageID: UUID
        var title: String
        var body: String
        var createdAt: Date
        var updatedAt: Date
        var fontId: String
        var paperId: String
        var inkId: String
        var sizeId: String
        var isPinned: Bool?

        var pinOn: Bool { isPinned ?? false }
    }

    /// What 1.0.0 (8) shipped. Decoding a build-7 row must fail.
    struct RequiredPinRow: Codable, Sendable {
        var pageID: UUID
        var title: String
        var body: String
        var createdAt: Date
        var updatedAt: Date
        var fontId: String
        var paperId: String
        var inkId: String
        var sizeId: String
        var isPinned: Bool
    }

    /// Build-7 fixture: the live keys, no `isPinned`.
    static let prePinStoreJSON = """
    {"pageID":"AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA","title":"Kept from seven","body":"still here","createdAt":0,"updatedAt":0,"fontId":"book","paperId":"cream","inkId":"charcoal","sizeId":"m"}
    """

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    /// Opens a pre-pin store payload with the current row schema.
    /// Must not throw, must keep the page, pin defaults off.
    /// Fails if `CurrentRow.isPinned` is a required `Bool` — that is the fix.
    static func openPrePinStore(_ json: String = prePinStoreJSON) throws -> CurrentRow {
        try decoder.decode(CurrentRow.self, from: Data(json.utf8))
    }

    /// Required `isPinned` cannot read a build-7 row. Documents the crash.
    static func requiredPinCrashesOnPrePinRow(_ json: String = prePinStoreJSON) -> Bool {
        (try? decoder.decode(RequiredPinRow.self, from: Data(json.utf8))) == nil
    }
}

struct LibraryPage: RecencyPage, Equatable, Sendable {
    var title: String
    var body: String
    var updatedAt: Date
    var paper: Paper
    var typeface: Typeface
    var isPinned: Bool = false
    var pinOn: Bool { isPinned }
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

/// Editor merge: the whole editor is paper. Chrome stays system iOS 26.
///
/// Apple TextEditor — “A view that can display and edit long-form text.”
/// Multiline, scrollable. Several paragraphs must not clip.
/// Apple safeAreaInset — shows specified content beside the modified view and
/// increases the safe area by that content. Word-count is that inset.
/// Paper is the view background, edge to edge (under the toolbar, down to the
/// inset, out to the screen edges). No desk-grain frame. No rounded sheet.
/// Type origin stays: leading 24 (56 if lined), trailing 24, date top 8.
/// Keyboard uses the system keyboard safe area — do not guess 34 or 120.
/// Keyboard-open is still undone.
enum EditorLook {
    /// Whole editor is paper. Not a card on a desk (`sheet-on-desk` / deskPeek 6).
    static let surfaceKind = "paper-full"
    static let layoutKind = "column-plus-inset"
    /// Paper goes edge to edge. Not a Notes clone — still Vellum paper + inset.
    static let isFullBleed = true
    static let wrap = "native"
    static let backKind = "system"
    static let focusKind = "system-toolbar"
    /// Focus keeps the nav bar so the eye stays tappable. No invisible top tap.
    static let focusEyeStays = true
    static let focusHidesNavBar = false
    static let stylesKind = "system-sheet"
    static let stylesSystemImage = "textformat"
    static let stylesDetentStart = "medium"
    /// Paper · typeface lives on the top Page style control, not the word-count inset.
    static let footerShowsStyle = false
    static let bodyKind = "text-editor"
    /// No rounded sheet sitting on grain.
    static let cornerRadius: Double = 0
    /// No desk-grain frame. Paper fills the screen edges.
    static let deskPeek: Double = 0
    static let sheetMaxHeightFraction: Double? = nil
    static let footerPlacement = "safeAreaInset"
    static let fillsToolbarToInset = true
    /// Paper stays behind the keys. Not a container-only ignore (that resizes).
    static let paperIgnoresKeyboard = true
    static let grainReveal = "none"
    static let bodyHoldsSeveralParagraphs = true
    static let clipsBody = false
    /// Mini type origin. Do not shift date / title / body.
    static let typeLeading: Double = 24
    static let typeLeadingLined: Double = 56
    static let typeTrailing: Double = 24
    static let dateTop: Double = 8
    static let bodyMinHeight: Double = 280
    static let chromeAboveBody: Double = 80
    static let severalParagraphHeight: Double = 240
    static let guessedKeyboardPad: Double? = nil
    static let forbiddenGuessedPads: [Double] = []
    static let minimumHit: Double = 44
    /// Mini keyboard-open pixels are still unwatched. Do not call the editor done.
    static let keyboardOpenProven = false

    /// Paper fills the field. No peek subtraction.
    static func writingHeight(inField fieldHeight: Double) -> Double {
        max(0, fieldHeight)
    }

    static func bodyFitsSeveralParagraphs(inFieldHeight field: Double) -> Bool {
        writingHeight(inField: field) - chromeAboveBody >= severalParagraphHeight
    }

    static func typeLeading(for paper: Paper) -> Double {
        paper.ruling == .lines ? typeLeadingLined : typeLeading
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

/// Debug-only launch: `VELLUM_FOCUS_BODY=1` focuses the body `TextEditor` on
/// appear so the system keyboard comes up. Mini cannot tap (no assistive
/// access). Release always returns false.
enum DebugFocusBody {
    static let environmentKey = "VELLUM_FOCUS_BODY"
    static let field = "body"

    #if DEBUG
    static let compileGateEnabled = true
    #else
    static let compileGateEnabled = false
    #endif

    static func shouldFocusBody(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        debugBuild: Bool = compileGateEnabled
    ) -> Bool {
        debugBuild && environment[environmentKey] == "1"
    }

    /// Body only, and only when Debug + flag. Release never focuses.
    static func fieldToFocus(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        debugBuild: Bool = compileGateEnabled
    ) -> String? {
        shouldFocusBody(environment: environment, debugBuild: debugBuild) ? field : nil
    }
}

enum EditorSheetCopy {
    static func footer(wordCount: Int, paper: Paper, typeface: Typeface) -> EditorFooter {
        let noun = wordCount == 1 ? "word" : "words"
        return EditorFooter(
            words: "\(wordCount) \(noun)",
            style: "",
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
