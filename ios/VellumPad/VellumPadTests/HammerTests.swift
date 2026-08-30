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
        XCTAssertEqual(samples[0].title, SampleDeskCopy.bookTitle)
        XCTAssertEqual(samples[0].body, SampleDeskCopy.bookBody)
        XCTAssertEqual(samples[0].typeface, .book)
        XCTAssertEqual(samples[0].paper, .cream)
        XCTAssertEqual(samples[1].title, SampleDeskCopy.handTitle)
        XCTAssertEqual(samples[1].typeface, .hand)
        XCTAssertEqual(samples[1].paper, .sage)
        XCTAssertEqual(samples[2].title, SampleDeskCopy.typeTitle)
        XCTAssertEqual(samples[2].typeface, .typewriter)
        XCTAssertEqual(samples[2].paper, .ruled)
        for sample in samples {
            XCTAssertFalse(SampleDeskCopy.containsForbiddenPhrase(sample.title))
            XCTAssertFalse(SampleDeskCopy.containsForbiddenPhrase(sample.body))
        }
        for body in SampleDeskCopy.allBodies {
            XCTAssertFalse(SampleDeskCopy.containsForbiddenPhrase(body))
        }
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
        XCTAssertTrue(EditorLook.hidesSystemScrollIndicator)
        XCTAssertEqual(EditorLook.boundEdgeKind, "path-ink")
        XCTAssertEqual(BoundEdgeRailLook.kind, "path-ink")
        XCTAssertEqual(BoundEdgeRailLook.placement, "trailing-edge")
        XCTAssertTrue(BoundEdgeRailLook.hidesSystemIndicator)
        XCTAssertFalse(BoundEdgeRailLook.usesSystemFace)
        XCTAssertTrue(BoundEdgeRailLook.forbiddenFaces.contains("SF Pro"))
        XCTAssertTrue(BoundEdgeRailLook.forbiddenFaces.contains("Inter"))
        XCTAssertEqual(BoundEdgeRailLook.hairlineInk, "rust")
        XCTAssertEqual(BoundEdgeRailLook.thumbKind, "paper")
        XCTAssertTrue(BoundEdgeRailLook.shortPageIsQuiet)
        XCTAssertFalse(BoundEdgeRailLook.ownsScrolling)
        XCTAssertFalse(BoundEdgeRailLook.parksCaret)
        XCTAssertFalse(BoundEdgeRailLook.usesScrollTo)
        XCTAssertFalse(BoundEdgeRailLook.usesCaretRect)
        XCTAssertFalse(BoundEdgeRailLook.capsBodyHeight)
        XCTAssertTrue(BoundEdgeRailLook.reduceMotionThumbIsInstant)
        XCTAssertEqual(BoundEdgeRailLook.restOpacity, 0)
        XCTAssertLessThan(BoundEdgeRailLook.shownHairlineOpacity, 0.5)
        XCTAssertGreaterThan(BoundEdgeRailLook.shownHairlineOpacity, 0)
        XCTAssertGreaterThan(BoundEdgeRailLook.shownThumbFillOpacity, 0.8)
        XCTAssertEqual(BoundEdgeRailLook.idleHideSeconds, 1)
        XCTAssertTrue(BoundEdgeRailLook.hidesWhenIdle)
        XCTAssertFalse(BoundEdgeRailLook.reduceMotionFades)
        XCTAssertFalse(BoundEdgeRailLook.isLongPage(content: 400, bounds: 400))
        XCTAssertTrue(BoundEdgeRailLook.isLongPage(content: 900, bounds: 400))
        XCTAssertEqual(BoundEdgeRailLook.progress(offset: 250, content: 900, bounds: 400), 0.5)
        XCTAssertEqual(BoundEdgeRailLook.contentOffset(progress: 0.5, content: 900, bounds: 400), 250)
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
        XCTAssertFalse(KeyboardChrome.caretFollowsWordCount, "per-keystroke park stacked glyphs")
        XCTAssertFalse(KeyboardChrome.caretParksPerKeystroke)
        XCTAssertFalse(KeyboardChrome.pinsPageToBottom)
        XCTAssertEqual(KeyboardChrome.caretRoomEdge, "bottom")
        XCTAssertNotEqual(KeyboardChrome.caretRoomEdge, "top")
        XCTAssertEqual(KeyboardChrome.caretScrollTarget, "system")
        XCTAssertNotEqual(KeyboardChrome.caretScrollTarget, "caret")
        XCTAssertNotEqual(KeyboardChrome.caretScrollTarget, "body")
        XCTAssertNotEqual(KeyboardChrome.caretScrollTarget, "floor")
        XCTAssertFalse(KeyboardChrome.caretUsesCaretRect, "caret-rect nudge stacked glyphs")
        XCTAssertFalse(KeyboardChrome.capsBodyToMeasuredHeight, "stale measure height stacked glyphs")
        XCTAssertTrue(KeyboardChrome.caretClearanceInsideTarget, "sibling after body is ignored by scrollTo")
        XCTAssertEqual(KeyboardChrome.caretClearanceLines, 0)
        XCTAssertEqual(
            KeyboardChrome.caretClearance(lineHeight: PaperRuling.bodyLineHeight(bodyPoints: TypeSize.m.bodyPoints)),
            KeyboardAvoidance.wordCountAir
        )
        XCTAssertEqual(KeyboardChrome.caretClearance(lineHeight: PaperRuling.pitch), KeyboardAvoidance.wordCountAir)
        XCTAssertEqual(KeyboardChrome.caretClearance(lineHeight: 0), 0)
        XCTAssertLessThan(KeyboardChrome.caretClearance(lineHeight: PaperRuling.pitch), PaperRuling.pitch)
        XCTAssertNotEqual(KeyboardChrome.caretClearance(lineHeight: PaperRuling.pitch), 34)
        XCTAssertNotEqual(KeyboardChrome.caretClearance(lineHeight: PaperRuling.pitch), 120)
        XCTAssertFalse(
            KeyboardChrome.clearanceStacksOnLeftover(
                lineHeight: PaperRuling.pitch,
                leftoverPad: EditorLook.bodyBottomPad
            ),
            "pitch stacked on leftover pad overshot (~3 rulings)"
        )
        XCTAssertEqual(KeyboardChrome.leftoverPad, EditorLook.bodyBottomPad)
        XCTAssertEqual(KeyboardChrome.caretFloor(visibleHeight: 400, columnHeight: 300), 0, "no slack under the last line")
        XCTAssertEqual(KeyboardChrome.caretFloor(visibleHeight: 400, columnHeight: 500), 0)
        XCTAssertEqual(KeyboardChrome.caretFloor(visibleHeight: 400, columnHeight: 0), 0)
        XCTAssertEqual(KeyboardChrome.caretFloor(visibleHeight: 0, columnHeight: 300), 0)
        XCTAssertEqual(
            KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 328, following: true),
            72,
            "Mini 18 leftover sits above the column, not under the last ink"
        )
        XCTAssertEqual(KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 300, following: true), 100)
        XCTAssertEqual(
            KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 300, following: false),
            0,
            "closed origin stays"
        )
        XCTAssertEqual(KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 0, following: true), 0)
        XCTAssertEqual(KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 500, following: true), 0)
        XCTAssertEqual(KeyboardChrome.caretFieldFill(visibleHeight: 400, following: true), 400)
        XCTAssertEqual(KeyboardChrome.caretFieldFill(visibleHeight: 400, following: false), 0, "closed origin stays")
        XCTAssertEqual(KeyboardChrome.caretFieldFill(visibleHeight: 0, following: true), 0)
        XCTAssertTrue(KeyboardChrome.caretUsesLiveGuide)
        XCTAssertEqual(KeyboardChrome.caretNudge(caretBottom: 481, hairlineY: 523, air: 4), -38)
        XCTAssertEqual(KeyboardChrome.caretTopInset(nudge: -38), 38, "Mini 20: 42pt high needs lift, not a field-size no-op")
        XCTAssertEqual(KeyboardChrome.caretBottomInset(nudge: -38), 0)
        XCTAssertEqual(KeyboardChrome.caretNudge(caretBottom: 533, hairlineY: 523, air: 4), 14)
        XCTAssertEqual(KeyboardChrome.caretBottomInset(nudge: 14), 14, "phone clip: caret under the hairline")
        XCTAssertEqual(KeyboardChrome.caretNudge(caretBottom: 519, hairlineY: 523, air: 4), 0)
        XCTAssertEqual(KeyboardChrome.caretNudge(caretBottom: 0, hairlineY: 523, air: 4), 0)
        XCTAssertNotEqual(KeyboardChrome.caretNudge(caretBottom: 481, hairlineY: 523, air: 4), 34)
        XCTAssertNotEqual(KeyboardChrome.caretNudge(caretBottom: 481, hairlineY: 523, air: 4), 120)
        XCTAssertEqual(
            KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 280, restingPad: 34, insetHeight: 20),
            534
        )
        XCTAssertEqual(
            KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 340, restingPad: 34, insetHeight: 20),
            474,
            "taller phone keyboard + suggestion bar shrinks the field"
        )
        XCTAssertLessThan(
            KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 340, restingPad: 34, insetHeight: 20),
            KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 280, restingPad: 34, insetHeight: 20)
        )
        XCTAssertEqual(
            KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 280, restingPad: 34, insetHeight: 0),
            554,
            "do not invent a 44pt inset"
        )
        XCTAssertEqual(KeyboardChrome.caretVisibleHeight(containerHeight: 0, guidePad: 280, restingPad: 34, insetHeight: 20), 0)
        XCTAssertEqual(KeyboardChrome.caretScrollOverlap(fieldHeight: 554, visibleHeight: 534), 20)
        XCTAssertEqual(KeyboardChrome.caretScrollOverlap(fieldHeight: 534, visibleHeight: 534), 0)
        XCTAssertEqual(KeyboardChrome.caretScrollOverlap(fieldHeight: 0, visibleHeight: 534), 0)
        XCTAssertEqual(EditorLook.bodyEditorHeight(measured: 208, empty: false), 208)
        XCTAssertNotEqual(EditorLook.bodyEditorHeight(measured: 208, empty: false), EditorLook.bodyMinHeight)
        XCTAssertEqual(EditorLook.bodyEditorHeight(measured: 0, empty: false), EditorLook.bodyMinHeight)
        XCTAssertEqual(EditorLook.bodyEditorHeight(measured: 208, empty: true), EditorLook.bodyMinHeight)
        XCTAssertEqual(
            KeyboardChrome.caretRuleOffset(base: 64, visibleHeight: 400, columnHeight: 300, following: true),
            164
        )
        XCTAssertEqual(
            KeyboardChrome.caretRuleOffset(base: 64, visibleHeight: 400, columnHeight: 300, following: false),
            64,
            "closed rules stay on the locked origin"
        )
        XCTAssertTrue(PaperRuling.sitsOnRule(PaperRuling.bodyLineHeight(bodyPoints: TypeSize.m.bodyPoints)))
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
        XCTAssertFalse(LibraryListing.hasInk(title: "", body: ""))
        XCTAssertFalse(LibraryListing.hasInk(title: "   ", body: "\n"))
        XCTAssertFalse(LibraryListing.showsInLibrary(title: "", body: ""))
        XCTAssertTrue(
            LibrarySheetCopy.sheets(
                pages: [LibraryPage(title: "", body: "", updatedAt: now, paper: .ivory, typeface: .book)],
                query: "",
                now: now
            ).isEmpty,
            "Untitled / 0 words is the empty desk, not a postcard"
        )
        XCTAssertTrue(LibraryListing.hasInk(title: "Kept", body: ""))
        XCTAssertTrue(LibraryListing.hasInk(title: "", body: "a line"))
        XCTAssertEqual(LibraryEmpty.headline(searching: false), "Empty")
        XCTAssertTrue(LibraryEmpty.detail(searching: false).isEmpty, "no second poetic line on the empty desk")
        XCTAssertEqual(LibraryEmpty.markKind, "paper-stamp")
        XCTAssertNotEqual(LibraryEmpty.markKind, "paper-sheet")
        XCTAssertEqual(LibraryEmpty.markLetter, "V")
        XCTAssertFalse(LibraryEmpty.markWritesName)
        XCTAssertTrue(LibraryEmpty.markHasRustMargin)
        XCTAssertNil(LibraryEmpty.markSystemImage)
        XCTAssertFalse(LibraryEmpty.forbiddenMarks.contains(LibraryEmpty.markKind))
        XCTAssertTrue(LibraryEmpty.composeStaysInChrome)
        XCTAssertFalse(LibraryEmpty.showsStartPage(searching: false))
        XCTAssertFalse(LibraryEmpty.showsClearSearch(searching: false))
    }

    func testLibraryOnePageIsAPaperSheetNotANotesRow() {
        let pages = [
            LibraryPage(title: "Late light on the river", body: "pewter water", updatedAt: now, paper: .cream, typeface: .book),
        ]
        let sheets = LibrarySheetCopy.sheets(pages: pages, query: "", now: now)
        XCTAssertEqual(sheets.count, 1)
        XCTAssertEqual(sheets[0].kind, "paper-sheet")
        XCTAssertNotEqual(sheets[0].kind, "notes-row")
        XCTAssertTrue(sheets[0].face.isEmpty, "no BOOK/HAND/TYPEWRITER chip")
        XCTAssertFalse(LibraryLook.showsFaceChip)
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
        XCTAssertEqual(LibraryEmpty.markKind, "paper-stamp")
        XCTAssertNil(LibraryEmpty.markSystemImage)
        XCTAssertTrue(LibraryEmpty.showsClearSearch(searching: true))
        XCTAssertFalse(LibraryEmpty.showsStartPage(searching: true))
        XCTAssertTrue(LibraryEmpty.composeStaysInChrome)
    }

    func testLibraryComposeIsSystemNotACustomPill() {
        XCTAssertEqual(LibraryLook.composeKind, "system")
        XCTAssertEqual(LibraryLook.composeSystemImage, "square.and.pencil")
        XCTAssertEqual(LibraryLook.searchablePrompt, "Search pages")
        XCTAssertNotEqual(LibraryLook.composeKind, "custom-pill")
        XCTAssertEqual(LibraryLook.greetingFamily, "Fraunces")
        XCTAssertNotEqual(LibraryLook.greetingFamily, "SF Pro")
        XCTAssertEqual(LibraryGreeting.family, "Fraunces")
        XCTAssertTrue(LibraryGreeting.usesStockLargeTitle)
        XCTAssertFalse(LibraryGreeting.hidesNavBar)
        XCTAssertFalse(LibraryGreeting.homemadeDraw)
        XCTAssertEqual(LibraryGreeting.sizeKind, "largeTitle")
        XCTAssertNil(LibraryGreeting.guessedPoints)
        XCTAssertTrue(LibraryGreeting.forbiddenGuessedPads.contains(34))
        XCTAssertTrue(LibraryGreeting.firstPaintVisible, "GREETING_CLIP: first paint must show the full greeting")
        XCTAssertTrue(LibraryGreeting.emptyUsesScrollView, "iOS 26 large title lives in the content scroll view")
        XCTAssertFalse(LibraryGreeting.greetingIgnoresSafeArea)
        XCTAssertTrue(LibraryGreeting.deskFillIgnoresSafeArea)
        XCTAssertEqual(LibraryGreeting.clipFail, "GREETING_CLIP")
        XCTAssertEqual(LibraryGreeting.italicOvershoot(systemAscender: 28, faceAscender: 32), 4)
        XCTAssertEqual(LibraryGreeting.italicOvershoot(systemAscender: 28, faceAscender: 28), 0)
        XCTAssertEqual(LibraryGreeting.italicOvershoot(systemAscender: 0, faceAscender: 32), 0)
        XCTAssertNotEqual(LibraryGreeting.italicOvershoot(systemAscender: 28, faceAscender: 32), 34)
        XCTAssertEqual(LibraryGreeting.airKind, "safeAreaPadding")
        XCTAssertTrue(LibraryGreeting.airUsesSystemDefault, "safeAreaPadding(.top) uses the system default, not 34")
        XCTAssertFalse(LibraryGreeting.hugsIsland)
        XCTAssertEqual(LibraryGreeting.belowGreeting, 0)
        XCTAssertEqual(LibraryGreeting.belowGreetingKind, "tight-title-to-subtitle")
        XCTAssertTrue(LibraryGreeting.forbiddenGuessedPads.contains(16), "16 sat the date a line away")
        XCTAssertTrue(LibraryGreeting.forbiddenGuessedPads.contains(34))
        XCTAssertFalse(LibraryGreeting.forbiddenGuessedPads.contains(LibraryGreeting.belowGreeting))
        XCTAssertNotEqual(LibraryGreeting.belowGreeting, 16)
        XCTAssertNotEqual(LibraryGreeting.belowGreeting, 34)
        XCTAssertEqual(LibraryGreeting.titleLeading, 0)
        XCTAssertTrue(LibraryGreeting.subtitleSharesLeading)
        XCTAssertEqual(LibraryGreeting.subtitleFamily, "Fraunces")
        XCTAssertNotEqual(LibraryGreeting.subtitleFamily, LibraryGreeting.subtitleForbiddenFamily)
        XCTAssertEqual(LibraryGreeting.subtitleStyle, "roman")
        XCTAssertFalse(LibraryGreeting.subtitleIsItalic)
        XCTAssertEqual(LibraryGreeting.subtitleSizeKind, "subheadline")
        XCTAssertNotEqual(LibraryGreeting.subtitleSizeKind, "largeTitle")
        XCTAssertTrue(LibraryGreeting.subtitleUsesStockSlot)
        XCTAssertEqual(LibraryGreeting.subtitleMarkKind, "path-lockup")
        XCTAssertFalse(LibraryGreeting.homemadeDraw)
        XCTAssertFalse(LibraryGreeting.hidesNavBar)
        XCTAssertEqual(DeskMarks.kind, "path-ink")
        XCTAssertFalse(DeskMarks.usesSystemFace)
        XCTAssertTrue(DeskMarks.forbiddenFaces.contains("SF Pro"))
        XCTAssertTrue(DeskMarks.forbiddenFaces.contains("Inter"))
        XCTAssertTrue(DeskMarks.dateIsLive)
        XCTAssertFalse(DeskMarks.dateFrozenBitmap)
        XCTAssertEqual(DeskMarks.dateLettering, "Fraunces")
        XCTAssertEqual(DeskMarks.middotKind, "path")
        XCTAssertEqual(DeskMarks.pageMarkKind, "paper-stamp")
        XCTAssertTrue(DeskMarks.pageMarkHasRustMargin)
        XCTAssertEqual(DeskMarks.pinnedKind, "path-wordmark")
        XCTAssertEqual(DeskMarks.pinnedLettering, "Fraunces")
        XCTAssertEqual(DeskMarks.pinnedVoiceOver, "Pinned")
        XCTAssertFalse(DeskMarks.pinnedUsesSFCaps)
        XCTAssertFalse(DeskMarks.drawsFibre)
        XCTAssertFalse(DeskMarks.greetingHomemade)
        XCTAssertEqual(LibraryLook.pinnedHeaderKind, DeskMarks.pinnedKind)
        let metaNow = Date(timeIntervalSince1970: 1_725_000_000)
        XCTAssertTrue(DeskMetaCopy.isLive(label: DeskMetaCopy.dateLabel(now: metaNow), now: metaNow))
        XCTAssertTrue(DeskMetaCopy.spoken(count: 3, now: metaNow).contains("3 pages"))
        XCTAssertTrue(DeskMetaCopy.spoken(count: 1, now: metaNow).contains("1 page"))
        XCTAssertTrue(
            DeskMetaCopy.spoken(count: 3, now: metaNow)
                .contains(DeskMetaCopy.dateLabel(now: metaNow))
        )
        XCTAssertEqual(LibraryLook.deleteKind, "swipe-and-menu")
        XCTAssertFalse(LibraryLook.deleteConfirms)
        XCTAssertTrue(LibraryLook.deleteAllowsFullSwipe)
        XCTAssertEqual(LibraryLook.pinKind, "swipe-and-menu")
        XCTAssertFalse(LibraryLook.showsFaceChip)
        XCTAssertFalse(LibraryLook.showsRecencyHeaders)
        XCTAssertFalse(LibrarySection.today.showsHeader)
        XCTAssertFalse(LibrarySection.yesterday.showsHeader)
        XCTAssertTrue(LibrarySection.pinned.showsHeader)
    }

    func testLibraryPinLeadsAndDeleteHasNoConfirm() {
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
        XCTAssertFalse(DeleteDecision.confirms, "confirm dialog is a fail")
        XCTAssertTrue(DeleteDecision.shouldDelete(confirmed: false), "press/swipe deletes; cancel alert is gone")
        XCTAssertTrue(DeleteDecision.shouldDelete(confirmed: true))
        XCTAssertEqual(DeleteDecision.undoKind, "snackbar")
        XCTAssertEqual(DeleteDecision.undoCopy, "Removed page")
        XCTAssertEqual(DeleteDecision.undoAction, "Undo")
        XCTAssertEqual(DeleteDecision.animationKind, "spring")
        XCTAssertTrue(DeleteDecision.reduceMotionIsInstant)
        XCTAssertEqual(DeskMotion.kind, "spring")
        XCTAssertEqual(DeskMotion.response, 0.42)
        XCTAssertEqual(DeskMotion.damping, 0.84)
        XCTAssertTrue(DeskMotion.reduceMotionIsInstant)
        XCTAssertTrue(DeskMotion.insertionMoves)
        XCTAssertTrue(DeskMotion.pinUsesMotion)
        XCTAssertTrue(DeskMotion.focusUsesMotion)
        XCTAssertFalse(DeskMotion.focusHidesNavBar)
        XCTAssertFalse(DeskMotion.focusRestylesPaper)
        XCTAssertEqual(DeleteDecision.animationKind, DeskMotion.kind)
        XCTAssertFalse(EditorLook.focusHidesNavBar)
        XCTAssertTrue(EditorLook.focusEyeStays)
        XCTAssertEqual(LibraryEmpty.markKind, "paper-stamp")
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
        XCTAssertTrue(sheet.face.isEmpty, "typeface is the writing face, not a Hand chip")
        XCTAssertFalse(LibraryLook.showsFaceChip)
        XCTAssertEqual(sheet.footer, "Yesterday  ·  Sage")
        XCTAssertFalse(sheet.footer.localizedCaseInsensitiveContains("Hand"))
        XCTAssertFalse(sheet.footer.localizedCaseInsensitiveContains("word"))
        for chip in LibraryLook.forbiddenFaceChips {
            XCTAssertFalse(sheet.face.localizedCaseInsensitiveContains(chip))
            XCTAssertFalse(sheet.footer.localizedCaseInsensitiveContains(chip))
        }
        XCTAssertEqual(sheet.typeface.familyName, "Caveat")
        XCTAssertEqual(Typeface.book.familyName, "Literata")
    }

    func testPaperHasNoFibreAndDeskFollowsSystem() {
        XCTAssertFalse(PaperLook.drawsFibreStrokes)
        XCTAssertEqual(PaperLook.forbiddenFibreStep, 18)
        XCTAssertTrue(PaperLook.keepsGrainSpeckle)
        XCTAssertTrue(PaperLook.keepsHorizontalRules)
        XCTAssertTrue(DeskLook.followsSystemColorScheme)
        XCTAssertTrue(DeskLook.hasSettingsToggle)
        XCTAssertFalse(DeskLook.remapsCatalogPaper)
        XCTAssertEqual(DeskLook.lightDesk, "cream")
        XCTAssertEqual(DeskLook.darkDesk, "night")
        XCTAssertEqual(DeskLook.emptyMarkPaper, "cream")
        XCTAssertTrue(DeskLook.emptyMarkStaysLight)
        XCTAssertEqual(DeskLook.editorSurface, "page-paper")
        XCTAssertNil(DeskLook.preferredColorScheme)
        XCTAssertTrue(DeskLook.usesBackdrop)
        XCTAssertTrue(DeskLook.hasTooth)
        XCTAssertTrue(DeskLook.hasVignette)
        XCTAssertEqual(DeskLook.vignetteKind, "edge-darken")
        XCTAssertFalse(DeskLook.forbiddenVignettes.contains(DeskLook.vignetteKind))
        XCTAssertFalse(DeskLook.drawsFibreStrokes)
        XCTAssertEqual(DeskToothLook.kind, "random-ellipse")
        XCTAssertFalse(DeskToothLook.drawsFibre)
        XCTAssertEqual(DeskToothLook.lightSpacing, 26)
        XCTAssertEqual(DeskToothLook.lightInkCap, 0.30)
        XCTAssertEqual(DeskToothLook.lightLiftCap, 0.36)
        XCTAssertEqual(DeskToothLook.darkSpacing, 36)
        XCTAssertEqual(DeskToothLook.darkInkCap, 0.22)
        XCTAssertEqual(DeskToothLook.darkLiftCap, 0.16)
        XCTAssertEqual(LibraryEmpty.markPaper, "cream")
        XCTAssertFalse(LibraryEmpty.markDrawsRuling)
        XCTAssertNotEqual(Paper.cream.rawValue, Paper.night.rawValue)
        XCTAssertFalse(Paper.cream.isDark)
        XCTAssertTrue(Paper.night.isDark)
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

    func testDeleteHasNoConfirmAndUndoRestoresThePage() {
        XCTAssertFalse(DeleteDecision.confirms)
        XCTAssertTrue(DeleteDecision.shouldDelete(confirmed: false))
        XCTAssertEqual(DeleteDecision.undoKind, "snackbar")
        let id = UUID(uuidString: "A11CE001-0000-4000-8000-00000000DE01")!
        let gone = DeletedPage(
            pageID: id,
            title: "River",
            body: "pewter",
            createdAt: now,
            updatedAt: now,
            fontId: Typeface.book.rawValue,
            paperId: Paper.cream.rawValue,
            inkId: Ink.charcoal.rawValue,
            sizeId: TypeSize.m.rawValue,
            isPinned: nil
        )
        let back = Page.restored(from: gone)
        XCTAssertEqual(back.pageID, id)
        XCTAssertEqual(back.title, "River")
        XCTAssertEqual(back.body, "pewter")
        XCTAssertFalse(back.pinOn)
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
        XCTAssertEqual(DebugForceWelcome.environmentKey, "VELLUM_FORCE_WELCOME")
        XCTAssertFalse(DebugForceWelcome.shouldForce(environment: [:], debugBuild: true))
        XCTAssertTrue(DebugForceWelcome.shouldForce(environment: ["VELLUM_FORCE_WELCOME": "1"], debugBuild: true))
        XCTAssertFalse(
            DebugForceWelcome.shouldForce(environment: ["VELLUM_FORCE_WELCOME": "1"], debugBuild: false),
            "Release must ignore VELLUM_FORCE_WELCOME"
        )
        let forceSuite = UserDefaults(suiteName: "vellum.hammer.force-welcome")!
        forceSuite.removePersistentDomain(forName: "vellum.hammer.force-welcome")
        WelcomeGate.finish(in: forceSuite)
        XCTAssertTrue(
            WelcomeGate.shouldPresent(
                in: forceSuite,
                environment: ["VELLUM_FORCE_WELCOME": "1"],
                debugBuild: true
            ),
            "FORCE_WELCOME roots welcome even after seen"
        )
        XCTAssertFalse(
            WelcomeGate.shouldPresent(
                in: forceSuite,
                environment: ["VELLUM_OPEN_FIRST": "1"],
                debugBuild: true
            ),
            "OPEN_FIRST hides welcome only when Mini asked for the editor"
        )
        XCTAssertTrue(
            WelcomeGate.shouldPresent(
                in: forceSuite,
                environment: ["VELLUM_FORCE_WELCOME": "1", "VELLUM_OPEN_FIRST": "1"],
                debugBuild: true
            ),
            "FORCE_WELCOME wins over OPEN_FIRST"
        )
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

    func testImportBackdatesAndSkipsDuplicates() {
        XCTAssertFalse(ImportLook.isLiveSync)
        XCTAssertFalse(ImportLook.hasAccounts)
        XCTAssertFalse(ImportLook.hasSettingsScreen)
        XCTAssertFalse(ImportLook.usesPrivateNotesKit)
        XCTAssertFalse(ImportLook.usesNotionOAuth)
        XCTAssertTrue(ImportLook.writesBothDates)
        XCTAssertEqual(ImportLook.storeName, "vellum-pages")
        XCTAssertEqual(ImportLook.displayName, "Velin")
        XCTAssertEqual(LibraryLook.bringInSystemImage, "square.and.arrow.down")
        XCTAssertEqual(LibraryLook.bringInKind, "connections")
        XCTAssertEqual(LibraryLook.bringInPlacement, "settings")
        XCTAssertEqual(LibraryLook.bringInTitle, "Import")
        XCTAssertEqual(ImportLook.bringInTitle, "Import")
        XCTAssertTrue(ImportLook.presentsFileImporter)
        XCTAssertEqual(ImportLook.fileImporterHost, "connections")
        XCTAssertEqual(ImportLook.pickHint, "Pick an exported file.")
        XCTAssertTrue(ImportLook.hasSourceMarks)
        XCTAssertEqual(ImportLook.sourceMarkKind, "app-icon")
        XCTAssertEqual(ImportMarkLook.kind, "app-icon")
        XCTAssertFalse(ImportMarkLook.usesSF)
        XCTAssertFalse(ImportMarkLook.usesGenericCircle)
        XCTAssertFalse(ImportMarkLook.usesDrawnPaths)
        XCTAssertEqual(ImportMarkLook.notes, "notes")
        XCTAssertEqual(ImportMarkLook.journal, "journal")
        XCTAssertEqual(ImportMarkLook.notion, "notion")
        XCTAssertEqual(ImportMarkLook.imagesets, ["notes", "journal", "notion"])
        XCTAssertEqual(ImportSource.notes.markKind, "notes")
        XCTAssertEqual(ImportSource.journal.markKind, "journal")
        XCTAssertEqual(ImportSource.notion.markKind, "notion")
        XCTAssertNotEqual(ImportMarkLook.notes, "yellow-pad")
        XCTAssertNotEqual(ImportMarkLook.journal, "brown-book")
        XCTAssertNotEqual(ImportMarkLook.notion, "n")
        XCTAssertEqual(LibraryLook.settingsSystemImage, "gearshape")
        XCTAssertEqual(LibraryLook.settingsPlacement, "topBarTrailing")
        XCTAssertTrue(ImportLook.livesInConnections)
        XCTAssertFalse(ImportLook.hasSettingsScreen)
        XCTAssertFalse(ImportLook.hasShareExtension)

        XCTAssertEqual(SettingsLook.sections, ["Connections", "Desk", "About"])
        XCTAssertFalse(SettingsLook.hasAccounts)
        XCTAssertFalse(SettingsLook.hasICloud)
        XCTAssertTrue(SettingsLook.hasThemePicker)
        XCTAssertTrue(SettingsLook.followsSystemAppearance)
        XCTAssertEqual(AppearanceLook.tiles, ["System", "Light", "Dark"])
        XCTAssertEqual(AppearanceLook.key, "vellum.settings.appearance")
        XCTAssertEqual(SettingsLook.aboutCopy, "Pages stay on this iPhone.")
        XCTAssertEqual(SettingsLook.versionLabel, "1.0.0 (31)")
        XCTAssertEqual(SettingsLook.buildNumber, "31")
        XCTAssertTrue(SettingsLook.chromeFollowsColorScheme)
        XCTAssertTrue(SettingsChromeLook.followsColorScheme)
        XCTAssertFalse(SettingsChromeLook.usesCatalogIvory)
        XCTAssertFalse(SettingsChromeLook.usesCatalogInk)
        XCTAssertFalse(SettingsChromeLook.remapsCatalogPaper)
        XCTAssertEqual(SettingsChromeLook.darkFill, "night")
        XCTAssertEqual(SettingsChromeLook.darkFillHex, "1C1915")
        XCTAssertTrue(SettingsChromeLook.isNight(scheme: "dark"), "Dark appearance → settings chrome is night")
        XCTAssertTrue(SettingsChromeLook.isDay(scheme: "light"), "Light appearance → settings chrome is day desk")
        XCTAssertFalse(SettingsChromeLook.usesUIColorTraitCallback)
        XCTAssertEqual(SettingsChromeLook.resolver, "swiftui-colorScheme")
        XCTAssertEqual(SettingsChromeLook.darkRowHex, "27231E")
        XCTAssertEqual(SettingsChromeLook.darkTypeHex, "F3EBDD")
        XCTAssertEqual(
            SettingsChromeLook.resolvedScheme(appearanceRaw: "dark", system: "light"),
            "dark",
            "Dark override restyles chrome even if sheet UIKit traits stayed light"
        )
        XCTAssertEqual(
            SettingsChromeLook.resolvedScheme(appearanceRaw: "light", system: "dark"),
            "light"
        )
        XCTAssertFalse(DeskLook.remapsCatalogPaper, "catalog paper/ivory stay cream")
        XCTAssertEqual(SettingsLook.welcomeRow, "Welcome")
        XCTAssertFalse(SettingsLook.welcomeDefault)
        XCTAssertFalse(SettingsLook.lockDefault)
        XCTAssertFalse(DeskSettings.lockDesk(in: UserDefaults(suiteName: "vellum.hammer.lock")!))
        XCTAssertTrue(SettingsLook.hapticsDefault)

        let suite = "vellum.hammer.welcome"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        XCTAssertNil(defaults.object(forKey: WelcomeLook.defaultsKey), "first-open key is absent")
        XCTAssertTrue(WelcomeGate.shouldShow(in: defaults), "first launch shows welcome")
        XCTAssertTrue(
            WelcomeGate.shouldPresent(in: defaults, environment: [:], debugBuild: true),
            "unseen key presents welcome — Debug does not skip by default"
        )
        XCTAssertTrue(WelcomeGate.rootUsesShouldPresent)
        XCTAssertFalse(WelcomeGate.usesAppStorageCopies)
        XCTAssertFalse(WelcomeLook.stampCallsFinish)
        XCTAssertFalse(WelcomeGate.stampCallsFinish)
        WelcomeGate.skip(in: defaults)
        XCTAssertFalse(WelcomeGate.shouldShow(in: defaults), "skip sets the flag")
        XCTAssertFalse(WelcomeGate.shouldShow(in: defaults), "second launch does not show welcome")
        XCTAssertFalse(DeskSettings.replayWelcome(in: defaults))
        WelcomeGate.startReplay(in: defaults)
        XCTAssertTrue(DeskSettings.replayWelcome(in: defaults), "replay persists before dismiss")
        XCTAssertTrue(
            WelcomeGate.shouldPresent(in: defaults, environment: [:], debugBuild: true),
            "toggle on presents welcome when seen is already true"
        )
        WelcomeGate.skip(in: defaults)
        XCTAssertFalse(DeskSettings.replayWelcome(in: defaults), "skip/done clears the toggle")
        XCTAssertTrue(defaults.bool(forKey: WelcomeLook.defaultsKey), "skip/done sets seen")
        WelcomeGate.startReplay(in: defaults)
        XCTAssertTrue(
            WelcomeGate.shouldPresent(in: defaults, environment: [:], debugBuild: true),
            "replay still works after seen is true"
        )
        XCTAssertEqual(WelcomeCopy.pages.count, 3)
        XCTAssertTrue(WelcomeCopy.kicker.isEmpty)
        XCTAssertEqual(WelcomeCopy.pages[0].title, "Pages you keep.")
        XCTAssertTrue(WelcomeCopy.pages[0].line.isEmpty)
        XCTAssertEqual(WelcomeCopy.pages[1].title, "Write on paper.")
        XCTAssertEqual(WelcomeCopy.pages[1].line, "Type and ink live on the page.")
        XCTAssertEqual(WelcomeCopy.pages[2].title, "Import.")
        XCTAssertEqual(WelcomeCopy.pages[2].line, "They keep their date.")
        for text in WelcomeCopy.userFacing {
            XCTAssertFalse(WelcomeCopy.containsAppNameOrDesk(text), text)
        }
        XCTAssertFalse(WelcomeLook.blankSheets)
        XCTAssertTrue(WelcomeLook.teachesProduct)
        XCTAssertEqual(WelcomeLook.miniCardTextProperty, "snippet")
        XCTAssertNotEqual(WelcomeLook.miniCardTextProperty, "body")
        XCTAssertTrue(WelcomePreview.teachesProduct)
        XCTAssertFalse(WelcomePreview.blankSheets)
        XCTAssertTrue(WelcomePreview.usesSampleCopy)
        XCTAssertEqual(WelcomePreview.libraryTitles, [
            SampleDeskCopy.typeTitle,
            SampleDeskCopy.bookTitle,
            SampleDeskCopy.handTitle,
        ])
        XCTAssertEqual(WelcomePreview.libraryBodies, [
            SampleDeskCopy.typeBody,
            SampleDeskCopy.bookBody,
            SampleDeskCopy.handBody,
        ])
        XCTAssertEqual(WelcomePreview.editorTitle, SampleDeskCopy.bookTitle)
        XCTAssertTrue(WelcomePreview.editorBody.contains(SampleDeskCopy.bookBody))
        XCTAssertTrue(WelcomePreview.editorBody.contains(SampleDeskCopy.handBody))
        XCTAssertTrue(WelcomePreview.editorBody.contains("\n\n"))
        XCTAssertEqual(WelcomePreview.importSources, ["Notes", "Journal", "Notion"])
        XCTAssertEqual(WelcomePreview.importKeepsDate, "A page keeps the date it was written.")
        XCTAssertEqual(WelcomePreview.staysLocal, "Pages stay on this iPhone.")
        XCTAssertEqual(WelcomeLook.defaultsKey, "vellum.welcome.seen")
        XCTAssertEqual(WelcomeLook.kind, "brand-root")
        XCTAssertTrue(WelcomeLook.isRoot)
        XCTAssertTrue(WelcomeLook.coversLibrary)
        XCTAssertFalse(WelcomeLook.libraryBehind)
        XCTAssertTrue(WelcomeLook.hasStamp)
        XCTAssertFalse(WelcomeLook.showsAppName)
        XCTAssertEqual(WelcomeLook.stampLetter, "V")
        XCTAssertFalse(WelcomeLook.stampWritesName)
        XCTAssertEqual(WelcomeLook.openingBeat, "stamp-bounce")
        XCTAssertEqual(WelcomeLook.bounceResponse, DeskMotion.response)
        XCTAssertEqual(WelcomeLook.bounceDamping, DeskMotion.damping)
        XCTAssertEqual(WelcomeLook.bounceSettle, 0.95)
        XCTAssertTrue(WelcomeLook.autoAdvanceAfterStamp)
        XCTAssertTrue(WelcomeLook.cardsArrive)
        XCTAssertTrue(WelcomeLook.typesWriting)
        XCTAssertEqual(WelcomeLook.typeInterval, 0.045)
        XCTAssertFalse(WelcomeLook.typeShowsCursor)
        XCTAssertEqual(
            WelcomeTypewriter.visible(full: "Sam", revealed: 2),
            "Sa"
        )
        XCTAssertEqual(WelcomeTypewriter.visible(full: "Sam", revealed: 0), "")
        XCTAssertEqual(WelcomeTypewriter.visible(full: "Sam", revealed: 8), "Sam")
        XCTAssertFalse(WelcomeTypewriter.showsCursor)
        XCTAssertTrue(WelcomeTypewriter.reduceMotionShowsFull)
        XCTAssertEqual(WelcomeInkLook.sheetInk, "charcoal")
        XCTAssertFalse(WelcomeInkLook.sheetUsesPrimary)
        XCTAssertFalse(WelcomeInkLook.sheetUsesOnDesk)
        XCTAssertFalse(WelcomeInkLook.sheetInkFlipsWithScheme)
        XCTAssertTrue(WelcomeInkLook.headlineUsesOnDesk)
        XCTAssertTrue(WelcomeInkLook.creamSheetsStayCream)
        XCTAssertEqual(WelcomeLook.motionKind, "page-turn")
        XCTAssertTrue(WelcomeLook.reduceMotionIsInstant)
        XCTAssertTrue(WelcomeLook.skipOnEveryPage)
        XCTAssertFalse(WelcomeLook.stampCallsFinish)
        XCTAssertTrue(AppearanceLook.retintsWholeApp)
        XCTAssertTrue(AppearanceLook.appliesPreferredColorSchemeAtRoot)
        XCTAssertTrue(AppearanceLook.appliesPreferredColorSchemeOnSheets)
        XCTAssertFalse(AppearanceLook.usesLocalSheetState)
        XCTAssertTrue(AppearanceLook.catalogSheetsStayCream)
        XCTAssertFalse(DeskLook.usesUIColorTraitCallback)
        XCTAssertEqual(DeskLook.resolver, "swiftui-colorScheme")

        let appearanceSuite = "vellum.hammer.appearance"
        let appearance = UserDefaults(suiteName: appearanceSuite)!
        appearance.removePersistentDomain(forName: appearanceSuite)
        XCTAssertEqual(AppearanceLook.raw(in: appearance), AppearanceLook.defaultRaw)
        XCTAssertNil(AppearanceLook.preferredColorScheme(in: appearance), "default System follows the device")
        AppearanceLook.setRaw(AppearanceLook.lightRaw, in: appearance)
        XCTAssertTrue(AppearanceLook.lightForcesLight(in: appearance), "Light forces light")
        AppearanceLook.setRaw(AppearanceLook.darkRaw, in: appearance)
        XCTAssertTrue(AppearanceLook.darkForcesNightDesk(in: appearance), "Dark forces night desk")
        XCTAssertEqual(DeskLook.darkDesk, "night")
        XCTAssertFalse(DeskLook.remapsCatalogPaper)

        let yesterday = now.addingTimeInterval(-1 * 24 * 60 * 60)
        let threeDays = now.addingTimeInterval(-3 * 24 * 60 * 60)
        let twentyDays = now.addingTimeInterval(-20 * 24 * 60 * 60)
        XCTAssertEqual(LibraryGrouping.section(for: yesterday, now: now), .yesterday)
        XCTAssertEqual(LibraryGrouping.section(for: threeDays, now: now), .thisWeek)
        XCTAssertEqual(LibraryGrouping.section(for: twentyDays, now: now), .earlier)
        XCTAssertEqual(LibraryGrouping.section(for: now, now: now), .today, ".now is Today — a fail for backdate")
        XCTAssertNotEqual(LibraryGrouping.section(for: yesterday, now: now), .today)

        switch ImportDating.bind(created: yesterday, updated: yesterday, fileDate: nil, now: now) {
        case .failure:
            XCTFail("sourced date should bind")
        case .success(let dates):
            XCTAssertEqual(dates.created, yesterday)
            XCTAssertEqual(dates.updated, yesterday)
            XCTAssertFalse(ImportDating.usesNow(dates.updated, now: now))
            XCTAssertEqual(LibraryGrouping.section(for: dates.updated, now: now), .yesterday)
        }
        if case .success = ImportDating.bind(created: nil, updated: nil, fileDate: nil, now: now) {
            XCTFail("missing date must not invent .now")
        }

        let csv = """
        Name,Created time,Last edited time,Text
        "River light","April 10, 2026 9:00 AM","April 11, 2026 3:15 PM","pewter water"
        """
        switch ImportRead.csv(Data(csv.utf8), fileDate: nil, source: .notion, now: now) {
        case .failure(let error):
            XCTFail("Notion CSV should parse: \(error)")
        case .success(let drafts):
            XCTAssertEqual(drafts.count, 1)
            XCTAssertEqual(drafts[0].title, "River light")
            XCTAssertEqual(drafts[0].body, "pewter water")
            XCTAssertEqual(drafts[0].createdAt, ImportDating.parse("April 10, 2026 9:00 AM"))
            XCTAssertEqual(drafts[0].updatedAt, ImportDating.parse("April 11, 2026 3:15 PM"))
            XCTAssertFalse(ImportDating.usesNow(drafts[0].updatedAt, now: now))
            XCTAssertEqual(LibraryGrouping.section(for: drafts[0].updatedAt, now: now), .earlier)
        }

        let sourced = ImportDraft(
            title: "River",
            body: "pewter",
            createdAt: yesterday,
            updatedAt: yesterday,
            source: .notes
        )
        let batch = ImportDecision.plan(drafts: [sourced, sourced], existing: [])
        XCTAssertEqual(batch.keep.count, 1)
        XCTAssertEqual(batch.skipped, 1)
        let again = ImportDecision.plan(drafts: [sourced], existing: [("River", "pewter")])
        XCTAssertTrue(again.keep.isEmpty)
        XCTAssertEqual(again.skipped, 1)

        switch ImportRead.file(name: "empty.txt", data: Data(), fileDate: now, source: .notes, now: now) {
        case .failure(let error):
            XCTAssertEqual(error, .empty)
            XCTAssertEqual(error.copy, "Nothing to import.")
        case .success:
            XCTFail("empty file must not crash or succeed")
        }
        switch ImportRead.file(name: "blank.txt", data: Data("   \n".utf8), fileDate: now, source: .journal, now: now) {
        case .failure(let error):
            XCTAssertEqual(error, .empty)
        case .success:
            XCTFail("whitespace file must not become a page")
        }
        switch ImportRead.file(name: "Export.zip", data: Data([0x50, 0x4B, 0x03, 0x04]), fileDate: now, source: .notion, now: now) {
        case .failure(let error):
            XCTAssertEqual(error, .needsUnzip)
        case .success:
            XCTFail("zip must not parse as a page")
        }
    }
}
