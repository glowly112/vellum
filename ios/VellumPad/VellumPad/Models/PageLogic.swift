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
    /// Confirm dialog is a fail. Press / swipe removes the page.
    static let confirms = false
    static let undoKind = "snackbar"
    static let undoCopy = "Removed page"
    static let undoAction = "Undo"
    static let animationKind = DeskMotion.kind
    static let reduceMotionIsInstant = DeskMotion.reduceMotionIsInstant

    static func shouldDelete(confirmed: Bool) -> Bool { true }
}

/// Shared spring for desk sheet mutations and focus chrome.
/// Reduce Motion is instant. Insertion moves, not only removal.
enum DeskMotion {
    static let kind = "spring"
    static let response: Double = 0.42
    static let damping: Double = 0.84
    static let reduceMotionIsInstant = true
    static let insertionMoves = true
    static let pinUsesMotion = true
    static let focusUsesMotion = true
    static let focusHidesNavBar = false
    static let focusRestylesPaper = false
}

/// Snapshot so Undo can put the page back. Not a confirm payload.
struct DeletedPage: Equatable, Sendable {
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
}

enum SeedPolicy {
    static func shouldSeed(storeIsEmpty: Bool, didLaunch: Bool) -> Bool {
        storeIsEmpty && !didLaunch
    }
}

/// First-launch desk notes. Sound like something left on the table, not a journal.
enum SampleDeskCopy {
    static let bookTitle = "Sam"
    static let bookBody = "Ring back after six — number is on the fridge."

    static let handTitle = "call mum"
    static let handBody = "Sunday, if I remember. Keys are in the blue bowl."

    static let typeTitle = "list"
    static let typeBody = """
    - oat milk, lemons, too many lemons
    - send the draft before Monday
    - no email after nine
    """

    static let forbiddenPhrases = [
        "pewter Thames",
        "a blank page is never actually blank",
        "the way a good sentence feels",
        "I keep meaning to write more, and then the day is gone.",
    ]

    static var allBodies: [String] { [bookBody, handBody, typeBody] }

    static func containsForbiddenPhrase(_ text: String) -> Bool {
        forbiddenPhrases.contains { text.localizedCaseInsensitiveContains($0) }
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
    /// Per-keystroke park froze TextEditor’s offset (phone 20: glyphs stacked).
    /// The system editor scrolls. Last-line flush is secondary.
    static let caretFollowsWordCount = false
    static let caretParksPerKeystroke = false
    static let pinsPageToBottom = false
    static let caretRoomEdge = "bottom"
    /// System editor keeps the caret visible. Not scrollTo(body) / caret-rect.
    static let caretScrollTarget = "system"
    /// Phone 20: `frame(height:)` lagged one keystroke behind wrap.
    static let capsBodyToMeasuredHeight = false
    /// Build 16 sliced glyphs. Build 17 added a full pitch inside `"body"` on
    /// top of leftover slack and overshot (~3 rulings). A few points, not a pitch.
    static let caretClearanceLines = 0.0
    static let caretClearanceInsideTarget = true
    /// Leftover under the last glyphs (TextEditor bottom pad). Not 34 / 120.
    static let leftoverPad = 8.0
    /// Caret field follows the live layout guide, not a Mini-sized ScrollView.
    static let caretUsesLiveGuide = true
    /// Phone 20/21: caret-rect nudge stacked glyphs. System editor scrolls.
    static let caretUsesCaretRect = false

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

    /// Field above the hairline. Uses the live `keyboardLayoutGuide` pad
    /// (same as the caption). A ScrollView measure can miss a taller phone
    /// keyboard + suggestion bar and park the caret line under the count.
    /// Unmeasured container → 0. Do not invent a 44pt inset.
    static func caretVisibleHeight(
        containerHeight: Double,
        guidePad: Double,
        restingPad: Double,
        insetHeight: Double
    ) -> Double {
        guard containerHeight > 0 else { return 0 }
        let pad = writingBottomPad(guidePad: guidePad, restingPad: restingPad)
        return max(0, containerHeight - pad - max(0, insetHeight))
    }

    /// How far the ScrollView extends behind the hairline. `scrollTo(.bottom)`
    /// on that extra parks glyphs under the count (phone 18).
    static func caretScrollOverlap(fieldHeight: Double, visibleHeight: Double) -> Double {
        guard fieldHeight > 0, visibleHeight > 0 else { return 0 }
        return max(0, fieldHeight - visibleHeight)
    }

    /// Slack *under* the column is leftover empty paper (Mini 16–18:
    /// 66 / 99 / 72pt under the last ink). Always 0. Unmeasured → 0.
    static func caretFloor(visibleHeight: Double, columnHeight: Double) -> Double {
        guard visibleHeight > 0, columnHeight > 0 else { return 0 }
        return 0
    }

    /// Short page + follow: leftover sits *above* the column so the last
    /// line can reach the hairline. Closed / unmeasured: 0 — origin stays.
    static func caretSlackAbove(
        visibleHeight: Double,
        columnHeight: Double,
        following: Bool
    ) -> Double {
        guard following, visibleHeight > 0, columnHeight > 0 else { return 0 }
        return max(0, visibleHeight - columnHeight)
    }

    /// Short page + follow: fill the field so the column can sit on the inset.
    /// Closed / unmeasured: 0 so origin stays at the top.
    static func caretFieldFill(visibleHeight: Double, following: Bool) -> Double {
        guard following, visibleHeight > 0 else { return 0 }
        return visibleHeight
    }

    /// Rules travel with the column when slack sits above. Not a guessed 34 / 120.
    static func caretRuleOffset(
        base: Double,
        visibleHeight: Double,
        columnHeight: Double,
        following: Bool
    ) -> Double {
        base + caretSlackAbove(
            visibleHeight: visibleHeight,
            columnHeight: columnHeight,
            following: following
        )
    }

    /// A few points in the scroll target so the hairline misses the glyphs.
    /// Not a pitch (build 17 stacked `lineHeight` on leftover pad).
    static func caretClearance(lineHeight: Double) -> Double {
        guard lineHeight > 0 else { return 0 }
        return KeyboardAvoidance.wordCountAir
    }

    /// Build 17: leftover + pitch ≥ one ruling of empty paper.
    static func clearanceStacksOnLeftover(lineHeight: Double, leftoverPad: Double) -> Bool {
        caretClearance(lineHeight: lineHeight) + leftoverPad >= lineHeight
    }

    /// How far to move the caret so its bottom plus a few points sits on the
    /// hairline. Positive = too low (phone clip). Negative = too high (Mini 42pt).
    /// Unmeasured → 0. Air is word-count air, not a pitch / 34 / 120.
    static func caretNudge(caretBottom: Double, hairlineY: Double, air: Double) -> Double {
        guard caretBottom > 0, hairlineY > 0 else { return 0 }
        return caretBottom + air - hairlineY
    }

    /// Slack above the column when the caret is too high to scroll (offset 0).
    static func caretTopInset(nudge: Double) -> Double {
        max(0, -nudge)
    }

    /// Extra scroll when the caret is under the hairline.
    static func caretBottomInset(nudge: Double) -> Double {
        max(0, nudge)
    }
}

/// Library merge: paper sheet is the object; chrome stays system iOS 26.
/// First-paint greeting. Fail `GREETING_CLIP` if Fraunces is sliced.
///
/// Apple (WWDC25): large titles sit at the top of the **content scroll view**
/// and scroll under the bar. Keep the scroll view extended under the bar;
/// do not homemade-draw the title. `ToolbarItem(.largeTitle)` takes
/// precedence over `navigationTitle` (SwiftUI `ToolbarItemPlacement.largeTitle`).
/// Size is the system large-title text style, not a guessed 34.
enum LibraryGreeting {
    static let clipFail = "GREETING_CLIP"
    static let usesStockLargeTitle = true
    static let hidesNavBar = false
    static let homemadeDraw = false
    static let family = Typeface.editorial.familyName
    static let sizeKind = "largeTitle"
    static let guessedPoints: Double? = nil
    /// 34 was an island guess. 16 was a full extra line under the greeting.
    static let forbiddenGuessedPads: [Double] = [34, 16]
    static let firstPaintVisible = true
    static let emptyUsesScrollView = true
    static let greetingIgnoresSafeArea = false
    static let deskFillIgnoresSafeArea = true
    /// Extra air under the island: SwiftUI `safeAreaPadding(.top)` with
    /// the system default length (`nil`), not a guessed 34.
    /// https://developer.apple.com/documentation/swiftui/view/safeareapadding(_:_:)
    static let airKind = "safeAreaPadding"
    static let airUsesSystemDefault = true
    static let hugsIsland = false
    /// No extra line under the greeting. The title line box already
    /// includes italic descenders; 16 sat the date a line away.
    /// Title-to-subtitle is the stock slots, not island air, not 34.
    static let belowGreeting: Double = 0
    static let belowGreetingKind = "tight-title-to-subtitle"
    /// Shared origin with the greeting so Sunday sits under Good.
    static let titleLeading: Double = 0
    static let subtitleSharesLeading = true
    /// Stock `ToolbarItem(.largeSubtitle)` / `.subtitle`. Not a homemade draw.
    /// Fraunces roman at subheadline — quiet meta, not a second greeting.
    static let subtitleFamily = Typeface.editorial.familyName
    static let subtitleStyle = "roman"
    static let subtitleSizeKind = "subheadline"
    static let subtitleUsesStockSlot = true
    static let subtitleIsItalic = false
    static let subtitleForbiddenFamily = "SF Pro"
    static let subtitleMarkKind = "path-lockup"

    /// Extra top air so italic Fraunces ascenders clear the system line box.
    /// Unmeasured → 0. Not a guessed 34.
    static func italicOvershoot(systemAscender: Double, faceAscender: Double) -> Double {
        guard systemAscender > 0, faceAscender > 0 else { return 0 }
        return max(0, faceAscender - systemAscender)
    }
}

/// Date · pages and PINNED are desk-drawn marks. Same craft as the paper stamp:
/// Path / ink, catalog serif lettering. Not SF, not Inter, not a frozen bitmap.
enum DeskMarks {
    static let kind = "path-ink"
    static let usesSystemFace = false
    static let forbiddenFaces = ["SF Pro", "Inter"]
    static let dateIsLive = true
    static let dateFrozenBitmap = false
    static let dateLettering = Typeface.editorial.familyName
    static let middotKind = "path"
    static let pageMarkKind = "paper-stamp"
    static let pageMarkHasRustMargin = true
    static let pinnedKind = "path-wordmark"
    static let pinnedLettering = Typeface.editorial.familyName
    static let pinnedVoiceOver = "Pinned"
    static let pinnedUsesSFCaps = false
    static let drawsFibre = false
    static let greetingHomemade = false
}

/// Live date · pages copy. Not a frozen Sunday August 30.
enum DeskMetaCopy {
    static func dateLabel(now: Date = .now) -> String {
        now.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    static func spoken(count: Int, now: Date = .now) -> String {
        let noun = count == 1 ? "page" : "pages"
        return "\(dateLabel(now: now))  ·  \(count) \(noun)"
    }

    static func isLive(label: String, now: Date) -> Bool {
        label == dateLabel(now: now)
    }
}

enum LibraryLook {
    static let cellKind = "paper-sheet"
    static let greetingFamily = Typeface.editorial.familyName
    static let composeKind = "system"
    static let composeSystemImage = "square.and.pencil"
    static let bringInKind = "connections"
    static let bringInPlacement = "settings"
    static let bringInSystemImage = "square.and.arrow.down"
    static let bringInTitle = "Import"
    static let settingsKind = "system"
    static let settingsSystemImage = "gearshape"
    static let settingsPlacement = "topBarTrailing"
    static let searchablePrompt = "Search pages"
    static let sheetMinHeight: Double = 176
    static let sheetCornerRadius: Double = 12
    static let deleteKind = "swipe-and-menu"
    static let deleteConfirms = false
    static let deleteAllowsFullSwipe = true
    static let pinKind = "swipe-and-menu"
    /// Only Pinned stamps a header. That header is a desk mark, not SF caps.
    static let pinnedHeaderKind = "path-wordmark"
    /// Typeface lives on the sheet as the writing face, not a BOOK/HAND chip.
    static let showsFaceChip = false
    /// Card already carries a quiet when. Do not also stamp TODAY/YESTERDAY.
    static let showsRecencyHeaders = false
    static let forbiddenFaceChips = ["BOOK", "HAND", "TYPEWRITER"]
}

/// Paper fill + grain + horizontal rules. Vertical fibre every 18pt was a pinstripe.
enum PaperLook {
    static let drawsFibreStrokes = false
    static let forbiddenFibreStep: Double = 18
    static let keepsGrainSpeckle = true
    static let keepsHorizontalRules = true
}

/// Library desk follows system appearance. Catalog paper fills do not remap.
enum DeskLook {
    static let followsSystemColorScheme = true
    static let hasSettingsToggle = true
    static let remapsCatalogPaper = false
    static let lightDesk = "cream"
    static let darkDesk = "night"
    static let emptyMarkPaper = "cream"
    static let emptyMarkStaysLight = true
    static let editorSurface = "page-paper"
    static let preferredColorScheme: String? = nil
    /// Library field is a surface (tooth + vignette), not a flat fill.
    static let usesBackdrop = true
    static let hasTooth = true
    static let hasVignette = true
    static let vignetteKind = "edge-darken"
    static let forbiddenVignettes = ["starfield", "wellness", "copilot"]
    static let drawsFibreStrokes = false
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
        let when = PageCopy.whenLabel(updatedAt, now: now)
        return LibrarySheet(
            kind: LibraryLook.cellKind,
            when: when,
            face: "",
            title: display,
            snippet: showPreview ? preview : nil,
            footer: "\(when)  ·  \(paper.name)",
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
    /// Desk stamp: cream sheet, rust margin, serif V. Not a stacked empty-state card.
    /// Not an SF `doc` / magnifying glass. The name is not written as Vellum.
    static let markKind = "paper-stamp"
    static let markSystemImage: String? = nil
    static let forbiddenMarks: [String] = ["doc", "magnifyingglass", "doc.text"]
    static let composeStaysInChrome = true
    static let markPaper = "cream"
    static let markDrawsRuling = false
    static let markLetter = "V"
    static let markWritesName = false
    static let markHasRustMargin = true

    static func headline(searching: Bool) -> String {
        searching ? "Nothing matches" : "Empty"
    }

    static func detail(searching: Bool) -> String {
        searching ? "Try a different word." : ""
    }

    static func showsClearSearch(searching: Bool) -> Bool { searching }

    static func showsStartPage(searching: Bool) -> Bool {
        _ = searching
        return false
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
    /// One system TextEditor. Not a ScrollView wrapping a height-capped editor.
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
    /// TextEditor / measure Text bottom pad. Leftover under the last line box.
    static let bodyBottomPad: Double = 8

    /// Hug the measured body. `bodyMinHeight` (280) inside `"body"` is the
    /// empty paper Mini 18 parked under “the page waiting.” Empty / unmeasured
    /// still use the min so a blank page is not one line.
    static func bodyEditorHeight(measured: Double, empty: Bool) -> Double {
        if empty { return bodyMinHeight }
        if measured > 0 { return measured }
        return bodyMinHeight
    }
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

    /// System chevron-pill is the miss. TextEditor still owns scrolling.
    static let hidesSystemScrollIndicator = true
    static let boundEdgeKind = "path-ink"
}

/// Right-edge bound rail. Rust hairline + cream paper thumb.
/// Placement from Books; charm is Velin paper. Not SF. Not caret-park.
enum BoundEdgeRailLook {
    static let kind = "path-ink"
    static let placement = "trailing-edge"
    static let hidesSystemIndicator = true
    static let usesSystemFace = false
    static let forbiddenFaces = ["SF Pro", "Inter"]
    static let hairlineInk = "rust"
    static let thumbKind = "paper"
    static let shortPageIsQuiet = true
    static let ownsScrolling = false
    static let parksCaret = false
    static let usesScrollTo = false
    static let usesCaretRect = false
    static let capsBodyHeight = false
    static let reduceMotionThumbIsInstant = true
    /// Short pages stay quiet. A few points of overflow is not a long page.
    static let quietSlop: Double = 12
    /// At rest the rail is gone. A wash at rest is still “always visible.”
    static let restOpacity: Double = 0
    static let shownHairlineOpacity: Double = 0.38
    static let shownThumbFillOpacity: Double = 0.92
    static let idleHideSeconds: Double = 1
    static let hidesWhenIdle = true
    static let reduceMotionFades = false

    static func isLongPage(content: Double, bounds: Double) -> Bool {
        content - bounds > quietSlop
    }

    static func progress(offset: Double, content: Double, bounds: Double) -> Double {
        let maxY = content - bounds
        guard maxY > quietSlop else { return 0 }
        return min(1, max(0, offset / maxY))
    }

    static func contentOffset(progress: Double, content: Double, bounds: Double) -> Double {
        let maxY = max(0, content - bounds)
        return min(1, max(0, progress)) * maxY
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
