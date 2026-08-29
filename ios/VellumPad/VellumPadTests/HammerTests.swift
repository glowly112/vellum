import Foundation
import XCTest
@testable import VellumPad

/// Cap 8. Logic that must stay true for the just-works bar.
final class HammerTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_777_237_200) // 2026-05-01 21:00 UTC-ish

    func testEmptyTitleFallsBackToBodyThenUntitled() {
        XCTAssertEqual(PageCopy.displayTitle(title: "", body: "First line\nSecond"), "First line")
        XCTAssertEqual(PageCopy.displayTitle(title: "   ", body: ""), "Untitled page")
        XCTAssertEqual(PageCopy.displayTitle(title: "Kept", body: "ignored"), "Kept")
    }

    func testBackThenReturnUsesLivePageNotACopy() {
        let page = Page(title: "River", body: "pewter", updatedAt: now)
        let before = page.snapshot()
        XCTAssertTrue(before.matchesLive(page))
        page.revise(title: "Late light", body: "The Thames")
        XCTAssertFalse(before.matchesLive(page), "stale editor copy")
        XCTAssertTrue(page.snapshot().matchesLive(page))
        XCTAssertEqual(page.title, "Late light")
    }

    func testDoubleTapComposeReusesFreshBlank() {
        let created = now
        XCTAssertTrue(
            ComposePolicy.reuseBlankPage(createdAt: created, title: "", body: "", now: created.addingTimeInterval(0.2))
        )
        XCTAssertFalse(
            ComposePolicy.reuseBlankPage(createdAt: created, title: "", body: "", now: created.addingTimeInterval(2))
        )
        XCTAssertFalse(
            ComposePolicy.reuseBlankPage(createdAt: created, title: "Named", body: "", now: created.addingTimeInterval(0.2))
        )
    }

    func testFirstRunSamplesSeedOnce() {
        XCTAssertTrue(SeedPolicy.shouldSeed(storeIsEmpty: true, didLaunch: false))
        XCTAssertFalse(SeedPolicy.shouldSeed(storeIsEmpty: true, didLaunch: true))
        XCTAssertFalse(SeedPolicy.shouldSeed(storeIsEmpty: false, didLaunch: false))
        let samples = SamplePages.makeSamples(now: now)
        XCTAssertEqual(samples.count, 3)
        XCTAssertEqual(samples[0].title, "Late light on the river")
    }

    func testEmptySearchReturnsNoGroups() {
        let pages = [
            PageRecord(title: "River", body: "water", updatedAt: now),
        ]
        XCTAssertTrue(LibraryGrouping.group(pages: pages, query: "zebra", now: now).isEmpty)
        XCTAssertFalse(LibraryGrouping.group(pages: pages, query: "", now: now).isEmpty)
    }

    func testKeyboardCoverContract_sizeIsLastStyleRowAndNightInks() {
        XCTAssertEqual(StyleSheetLayout.sections.last, "Size")
        XCTAssertNil(KeyboardAvoidance.guessedBottomPoints, "KB_COVER: do not guess 34pt / 120pt")
        XCTAssertEqual(Ink.allowed(on: .night), [.cream, .sepia])
        XCTAssertEqual(HitTarget.minimum, 44)
    }

    func testEditorIsColumnPlusInsetNotAPostcard() {
        XCTAssertEqual(EditorLook.surfaceKind, "paper-full")
        XCTAssertNotEqual(EditorLook.surfaceKind, "sheet-on-desk")
        XCTAssertEqual(EditorLook.layoutKind, "column-plus-inset")
        XCTAssertNotEqual(EditorLook.layoutKind, "fraction-card")
        XCTAssertTrue(EditorLook.isFullBleed, "paper is edge to edge")
        XCTAssertEqual(EditorLook.deskPeek, 0, "no desk-grain frame")
        XCTAssertEqual(EditorLook.cornerRadius, 0, "no rounded sheet on grain")
        XCTAssertEqual(EditorLook.wrap, "native")
        XCTAssertEqual(EditorLook.footerPlacement, "safeAreaInset")
        XCTAssertNil(EditorLook.sheetMaxHeightFraction, "no postcard height fraction")
        XCTAssertTrue(EditorLook.fillsToolbarToInset, "paper fills toolbar-to-inset")
        XCTAssertEqual(EditorLook.grainReveal, "none")
        XCTAssertNotEqual(EditorLook.grainReveal, "edge-only")
        XCTAssertEqual(EditorLook.typeLeading, 24)
        XCTAssertEqual(EditorLook.typeLeadingLined, 56)
        XCTAssertEqual(EditorLook.typeTrailing, 24)
        XCTAssertEqual(EditorLook.dateTop, 8)
        XCTAssertEqual(EditorLook.typeLeading(for: .cream), 24)
        XCTAssertEqual(EditorLook.typeLeading(for: .ruled), 56)
        XCTAssertTrue(EditorLook.bodyHoldsSeveralParagraphs)
        XCTAssertFalse(EditorLook.clipsBody, "several paragraphs must not clip")
        XCTAssertGreaterThanOrEqual(EditorLook.bodyMinHeight, 240)
        let field: Double = 668
        XCTAssertEqual(EditorLook.writingHeight(inField: field), field)
        XCTAssertTrue(EditorLook.bodyFitsSeveralParagraphs(inFieldHeight: field))
        XCTAssertFalse(EditorLook.keyboardOpenProven, "do not call the editor done")
    }

    func testEditorFooterCopyUsesSafeAreaInset() {
        let footer = EditorSheetCopy.footer(wordCount: 66, paper: .cream, typeface: .book)
        XCTAssertEqual(footer.words, "66 words")
        XCTAssertTrue(footer.style.isEmpty, "paper · typeface is not on the word-count inset")
        XCTAssertFalse(EditorLook.footerShowsStyle)
        XCTAssertEqual(footer.placement, "safeAreaInset")
        XCTAssertTrue(EditorSheetCopy.showsFooter(focus: false))
        XCTAssertFalse(EditorSheetCopy.showsFooter(focus: true))
    }

    func testEditorChromeIsSystemNotWebPills() {
        XCTAssertEqual(EditorLook.backKind, "system")
        XCTAssertEqual(EditorLook.focusKind, "system-toolbar")
        XCTAssertTrue(EditorLook.focusEyeStays)
        XCTAssertFalse(EditorLook.focusHidesNavBar)
        XCTAssertEqual(EditorLook.stylesKind, "system-sheet")
        XCTAssertEqual(EditorLook.stylesSystemImage, "textformat")
        XCTAssertEqual(EditorLook.stylesDetentStart, "medium")
        XCTAssertNotEqual(EditorLook.stylesSystemImage, "custom-T")
        XCTAssertNotEqual(EditorLook.backKind, "circular-web")
    }

    func testEditorKeyboardCoverKeepsCaretAndLastSection() {
        XCTAssertNil(KeyboardAvoidance.guessedBottomPoints)
        XCTAssertNil(EditorLook.guessedKeyboardPad)
        XCTAssertEqual(EditorLook.bodyKind, "text-editor")
        XCTAssertNotEqual(EditorLook.bodyKind, "nested-scrollview")
        XCTAssertEqual(StyleSheetLayout.sections.last, "Size")
        XCTAssertEqual(EditorSheetCopy.footer(wordCount: 1, paper: .ruled, typeface: .book).words, "1 word")
        XCTAssertEqual(EditorLook.footerPlacement, "safeAreaInset")
        XCTAssertFalse(EditorLook.forbiddenGuessedPads.contains(34))
        XCTAssertFalse(EditorLook.forbiddenGuessedPads.contains(120))
        XCTAssertEqual(HitTarget.minimum, 44)
    }

    func testRuledAndDottedTypeSitsOnSharedPitch() {
        XCTAssertEqual(PaperRuling.pitch, 32)
        XCTAssertEqual(PaperRuling.compactPitch, 22)
        XCTAssertEqual(PaperRuling.compactDotPitch, 16)
        XCTAssertEqual(PaperRuling.firstRuleOffset, 64)
        XCTAssertEqual(PaperRuling.step(ruling: .lines, compact: false), 32)
        XCTAssertEqual(PaperRuling.step(ruling: .dots, compact: false), 32, "editor dots share the type pitch")
        XCTAssertEqual(PaperRuling.step(ruling: .lines, compact: true), 22, "library swatch lines stay 22")
        XCTAssertEqual(PaperRuling.step(ruling: .dots, compact: true), 16, "library swatch dots stay 16")
        for size in TypeSize.allCases {
            XCTAssertEqual(PaperRuling.bodyLineHeight(bodyPoints: size.bodyPoints), PaperRuling.pitch)
            XCTAssertTrue(PaperRuling.sitsOnRule(PaperRuling.bodyLineHeight(bodyPoints: size.bodyPoints)))
            XCTAssertEqual(PaperRuling.titleLineHeight(titlePoints: size.titlePoints), PaperRuling.pitch * 2)
            XCTAssertTrue(PaperRuling.sitsOnRule(PaperRuling.titleLineHeight(titlePoints: size.titlePoints)))
            XCTAssertEqual(size.ruleHeight, CGFloat(PaperRuling.pitch))
        }
        XCTAssertEqual(Paper.ruled.ruling, .lines)
        XCTAssertEqual(Paper.dotted.ruling, .dots)
        XCTAssertNotEqual(EditorLook.deskPeek, 6)
        XCTAssertEqual(EditorLook.grainReveal, "none")
    }

    func testWordCountSitsAboveKeyboardWithoutGuessedPad() {
        XCTAssertNil(KeyboardAvoidance.guessedBottomPoints)
        XCTAssertNil(EditorLook.guessedKeyboardPad)
        XCTAssertGreaterThan(KeyboardAvoidance.wordCountAir, 0)
        XCTAssertLessThan(KeyboardAvoidance.wordCountAir, 8, "flush, a few points above the keys")
        XCTAssertFalse(KeyboardChrome.forbiddenWordCountAir.contains(KeyboardAvoidance.wordCountAir))
        XCTAssertNotEqual(KeyboardAvoidance.wordCountAir, 16, "16pt air was the paper band")
        XCTAssertNotEqual(KeyboardAvoidance.wordCountAir, 34)
        XCTAssertNotEqual(KeyboardAvoidance.wordCountAir, 120)
        XCTAssertEqual(KeyboardAvoidance.wordCountBottomPad(keyboardLift: 0), 0)
        XCTAssertEqual(KeyboardAvoidance.wordCountBottomPad(keyboardLift: 280), KeyboardAvoidance.wordCountAir)
        XCTAssertFalse(EditorLook.forbiddenGuessedPads.contains(34))
        XCTAssertFalse(EditorLook.forbiddenGuessedPads.contains(120))
        XCTAssertFalse(EditorLook.keyboardOpenProven, "Linux has no Mini keyboard pixels")
    }

    func testKeyboardOpenPaperFillsGuttersAndTextTracksKeys() {
        XCTAssertEqual(KeyboardChrome.gutterFill, "paper")
        XCTAssertFalse(KeyboardChrome.systemWhiteGutter, "KB_COVER: no system-white beside the keys")
        XCTAssertTrue(KeyboardChrome.paperRegions.contains("keyboard"))
        XCTAssertTrue(KeyboardChrome.paperRegions.contains("container"))
        XCTAssertTrue(EditorLook.paperIgnoresKeyboard)
        XCTAssertEqual(KeyboardChrome.liftKind, "layout-guide")
        XCTAssertNotEqual(KeyboardChrome.liftKind, "safe-area-jump")
        XCTAssertFalse(KeyboardChrome.liftJumpsAtAnimationStart)
        XCTAssertTrue(KeyboardChrome.textTracksKeyboard)
        XCTAssertTrue(KeyboardChrome.openPadIsKeyboardOnly)
        XCTAssertEqual(KeyboardChrome.writingBottomPad(guidePad: 280, restingPad: 34), 246)
        XCTAssertEqual(KeyboardChrome.writingBottomPad(guidePad: 34, restingPad: 34), 34)
        XCTAssertEqual(KeyboardChrome.writingBottomPad(guidePad: 280, restingPad: 0), 280)
        XCTAssertEqual(KeyboardChrome.restingPad(current: 0, reported: 0), 0)
        XCTAssertEqual(KeyboardChrome.restingPad(current: 0, reported: 34), 34)
        XCTAssertEqual(KeyboardChrome.restingPad(current: 34, reported: 300), 34)
        XCTAssertEqual(KeyboardChrome.restingPad(current: 34, reported: 20), 20)
        XCTAssertEqual(KeyboardChrome.keyboardOnlyLift(guidePad: 34, restingPad: 34), 0)
        XCTAssertEqual(KeyboardChrome.keyboardOnlyLift(guidePad: 300, restingPad: 34), 266)
        XCTAssertEqual(KeyboardChrome.keyboardOnlyLift(guidePad: 300, restingPad: 0), 0)
        XCTAssertTrue(KeyboardChrome.wordCountSitsOnKeyboard)
        XCTAssertEqual(KeyboardChrome.wordCountKind, "caption")
        XCTAssertFalse(KeyboardChrome.wordCountUsesMinimumHit, "44pt minHeight was the paper band")
        XCTAssertNotEqual(EditorLook.minimumHit, 0)
        XCTAssertTrue(KeyboardChrome.caretFollowsWordCount)
        XCTAssertFalse(KeyboardChrome.pinsPageToBottom)
        XCTAssertEqual(KeyboardChrome.caretRoomEdge, "bottom")
        XCTAssertNotEqual(KeyboardChrome.caretRoomEdge, "top")
        XCTAssertEqual(KeyboardChrome.caretScrollTarget, "body")
        XCTAssertNotEqual(KeyboardChrome.caretScrollTarget, "floor")
        XCTAssertEqual(KeyboardChrome.caretFloor(visibleHeight: 400, columnHeight: 300), 100)
        XCTAssertEqual(KeyboardChrome.caretFloor(visibleHeight: 400, columnHeight: 500), 0)
        XCTAssertEqual(KeyboardChrome.caretFloor(visibleHeight: 400, columnHeight: 0), 0)
        XCTAssertEqual(KeyboardChrome.caretFloor(visibleHeight: 0, columnHeight: 300), 0)
        XCTAssertEqual(EditorLook.typeLeading, 24)
        XCTAssertEqual(EditorLook.dateTop, 8)
        XCTAssertNil(KeyboardAvoidance.guessedBottomPoints)
        XCTAssertEqual(EditorLook.deskPeek, 0)
        XCTAssertEqual(EditorLook.surfaceKind, "paper-full")
        XCTAssertFalse(EditorLook.keyboardOpenProven)
    }

    func testStyleSheetLastRowsAreReachable() {
        XCTAssertEqual(StyleSheetLayout.sections.last, "Size")
        XCTAssertTrue(StyleSheetLayout.lastSectionReachable)
        XCTAssertEqual(StyleSheetLayout.detentKind, "medium-first")
        XCTAssertGreaterThanOrEqual(StyleSheetLayout.scrollBottomPad, 44)
        XCTAssertTrue(Typeface.allCases.map(\.name).contains("Typewriter"))
        XCTAssertEqual(Typeface.allCases.last?.name, "Mono")
    }

    func testLibraryEmptyDeskHasNoSheets() {
        let sheets = LibrarySheetCopy.sheets(pages: [], query: "", now: now)
        XCTAssertTrue(sheets.isEmpty)
        XCTAssertEqual(LibraryEmpty.headline(searching: false), "The desk is clear")
    }

    func testLibraryOnePageIsAPaperSheetNotANotesRow() {
        let pages = [
            LibraryPage(title: "Late light on the river", body: "pewter water", updatedAt: now, paper: .cream, typeface: .book),
        ]
        let sheets = LibrarySheetCopy.sheets(pages: pages, query: "", now: now)
        XCTAssertEqual(sheets.count, 1)
        XCTAssertEqual(sheets[0].kind, "paper-sheet")
        XCTAssertNotEqual(sheets[0].kind, "notes-row")
        XCTAssertNotEqual(sheets[0].face, "Aa")
        XCTAssertEqual(sheets[0].face, "Book")
        XCTAssertEqual(sheets[0].title, "Late light on the river")
        XCTAssertGreaterThanOrEqual(LibraryLook.sheetMinHeight, 160)
    }

    func testLibraryLongTitleStaysOnTheSheet() {
        let long = String(repeating: "Late light on the river ", count: 6).trimmingCharacters(in: .whitespaces)
        let sheet = LibrarySheetCopy.cell(
            title: long,
            body: "The Thames.",
            updatedAt: now,
            paper: .cream,
            typeface: .book,
            now: now
        )
        XCTAssertEqual(sheet.kind, "paper-sheet")
        XCTAssertEqual(sheet.title, long)
        XCTAssertTrue(sheet.title.count > 40)
    }

    func testLibrarySearchOpenFiltersAndEmptyMatch() {
        let pages = [
            LibraryPage(title: "River", body: "water", updatedAt: now, paper: .cream, typeface: .book),
        ]
        XCTAssertEqual(LibrarySheetCopy.sheets(pages: pages, query: "river", now: now).count, 1)
        XCTAssertTrue(LibrarySheetCopy.sheets(pages: pages, query: "zebra", now: now).isEmpty)
        XCTAssertEqual(LibraryEmpty.headline(searching: true), "Nothing matches")
    }

    func testLibraryComposeIsSystemNotACustomPill() {
        XCTAssertEqual(LibraryLook.composeKind, "system")
        XCTAssertEqual(LibraryLook.composeSystemImage, "square.and.pencil")
        XCTAssertEqual(LibraryLook.searchablePrompt, "Search pages")
        XCTAssertNotEqual(LibraryLook.composeKind, "custom-pill")
        XCTAssertEqual(LibraryLook.greetingFamily, "Fraunces")
        XCTAssertNotEqual(LibraryLook.greetingFamily, "SF Pro")
        XCTAssertEqual(LibraryLook.deleteKind, "swipe-and-menu")
        XCTAssertEqual(LibraryLook.pinKind, "swipe-and-menu")
    }

    func testLibraryPinLeadsAndDeleteNeedsConfirm() {
        let pinned = LibraryPage(
            title: "Kept",
            body: "pin me",
            updatedAt: now.addingTimeInterval(-20 * 24 * 60 * 60),
            paper: .cream,
            typeface: .book,
            isPinned: true
        )
        let today = LibraryPage(
            title: "Today",
            body: "desk",
            updatedAt: now,
            paper: .cream,
            typeface: .book,
            isPinned: false
        )
        let groups = LibraryGrouping.group(pages: [pinned, today], query: "", now: now)
        XCTAssertEqual(groups.map(\.section), [.pinned, .today])
        XCTAssertEqual(groups[0].pages.first?.title, "Kept")
        XCTAssertTrue(LibraryPin.isPinnedAfterToggle(false))
        XCTAssertFalse(LibraryPin.isPinnedAfterToggle(true))
        XCTAssertFalse(DeleteDecision.shouldDelete(confirmed: false))
        XCTAssertTrue(DeleteDecision.shouldDelete(confirmed: true))
    }

    func testPrePinStoreOpensWithoutCrashing() throws {
        XCTAssertTrue(
            PageStoreOpen.requiredPinCrashesOnPrePinRow(),
            "required isPinned is the 1.0.0 (8) crash — a build-7 row has no that column"
        )
        let row = try PageStoreOpen.openPrePinStore()
        XCTAssertEqual(row.title, "Kept from seven")
        XCTAssertEqual(row.body, "still here")
        XCTAssertNil(row.isPinned)
        XCTAssertFalse(row.pinOn)
        XCTAssertEqual(row.pageID.uuidString, "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
    }

    func testLibrarySheetCarriesPaperAndTypeface() {
        let sheet = LibrarySheetCopy.cell(
            title: "things I noticed",
            body: "rain on warm pavement",
            updatedAt: now.addingTimeInterval(-26 * 60 * 60),
            paper: .sage,
            typeface: .hand,
            now: now
        )
        XCTAssertEqual(sheet.kind, "paper-sheet")
        XCTAssertEqual(sheet.paper, .sage)
        XCTAssertEqual(sheet.typeface, .hand)
        XCTAssertEqual(sheet.face, "Hand")
        XCTAssertEqual(sheet.footer, "7 words  ·  Sage")
        XCTAssertEqual(sheet.typeface.familyName, "Caveat")
        XCTAssertEqual(Typeface.book.familyName, "Literata")
    }

    func testPaperGrainSeedDoesNotTrapOnEveryPaper() {
        var seen: Set<UInt64> = []
        for paper in Paper.allCases {
            let seed = PaperGrain.seed(for: paper)
            XCTAssertNotEqual(seed, 0, paper.rawValue)
            XCTAssertTrue(seen.insert(seed).inserted, paper.rawValue)
        }
        let desk = PaperGrain.seed(forToken: "desk")
        XCTAssertNotEqual(desk, 0)
        XCTAssertTrue(seen.insert(desk).inserted)
    }

    func testCatalogueTypefacesUseOFLFamilyNames() {
        let expected = [
            Typeface.book: "Literata",
            .editorial: "Fraunces",
            .hand: "Caveat",
            .typewriter: "Special Elite",
            .sans: "Source Sans 3",
            .mono: "IBM Plex Mono",
        ]
        for (face, family) in expected {
            XCTAssertEqual(face.familyName, family)
        }
        let standIns: Set<String> = [
            "Georgia", "Palatino", "Palatino-Roman", "Noteworthy",
            "Noteworthy-Light", "American Typewriter", "AmericanTypewriter",
            "SF Pro", "SF Mono",
        ]
        for face in Typeface.allCases {
            XCTAssertFalse(standIns.contains(face.familyName), face.familyName)
        }
        XCTAssertEqual(TypefaceRegistry.files.count, 6)
    }

    func testDeleteConfirmCancelVsConfirm() {
        XCTAssertFalse(DeleteDecision.shouldDelete(confirmed: false))
        XCTAssertTrue(DeleteDecision.shouldDelete(confirmed: true))
    }

    func testDebugOpenFirstIsDebugOnlyAndReadsEnv() {
        XCTAssertEqual(DebugOpenFirst.environmentKey, "VELLUM_OPEN_FIRST")
        XCTAssertFalse(DebugOpenFirst.shouldOpenFirstPage(environment: [:], debugBuild: true))
        XCTAssertTrue(DebugOpenFirst.shouldOpenFirstPage(environment: ["VELLUM_OPEN_FIRST": "1"], debugBuild: true))
        XCTAssertFalse(
            DebugOpenFirst.shouldOpenFirstPage(environment: ["VELLUM_OPEN_FIRST": "1"], debugBuild: false),
            "Release must ignore the env flag"
        )
        let id = UUID(uuidString: "A11CE001-0000-4000-8000-000000000001")!
        XCTAssertEqual(DebugOpenFirst.pageToOpen(from: [id]), id)
        XCTAssertNil(DebugOpenFirst.pageToOpen(from: [UUID]()))
    }

    func testDebugFocusBodyIsDebugOnlyAndFocusesBody() {
        XCTAssertEqual(DebugFocusBody.environmentKey, "VELLUM_FOCUS_BODY")
        XCTAssertEqual(DebugFocusBody.field, "body")
        XCTAssertFalse(DebugFocusBody.shouldFocusBody(environment: [:], debugBuild: true))
        XCTAssertTrue(
            DebugFocusBody.shouldFocusBody(environment: ["VELLUM_FOCUS_BODY": "1"], debugBuild: true),
            "DEBUG true + flag focuses body"
        )
        XCTAssertEqual(
            DebugFocusBody.fieldToFocus(environment: ["VELLUM_FOCUS_BODY": "1"], debugBuild: true),
            "body"
        )
        XCTAssertFalse(
            DebugFocusBody.shouldFocusBody(environment: ["VELLUM_FOCUS_BODY": "1"], debugBuild: false),
            "Release must ignore the env flag"
        )
        XCTAssertNil(
            DebugFocusBody.fieldToFocus(environment: ["VELLUM_FOCUS_BODY": "1"], debugBuild: false),
            "Release never focuses"
        )
        XCTAssertFalse(EditorLook.keyboardOpenProven, "Mini pixels do not exist yet")
        XCTAssertEqual(EditorLook.deskPeek, 0)
        XCTAssertEqual(EditorLook.grainReveal, "none")
        XCTAssertEqual(EditorLook.layoutKind, "column-plus-inset")
    }

    func testShareTxtUsesUntitledWhenEmpty() {
        XCTAssertEqual(PagePlainText.fileName(title: "", body: ""), "Untitled page.txt")
        XCTAssertEqual(PagePlainText.fileName(title: "UI/UX", body: ""), "UI-UX.txt")
        XCTAssertEqual(PagePlainText.contents(title: "Title", body: "Body"), "Title\n\nBody")
        XCTAssertEqual(PagePlainText.contents(title: "", body: "only body"), "only body")
    }
}
