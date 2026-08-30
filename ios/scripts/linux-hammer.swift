import Foundation

@main
enum LinuxHammer {
    static func main() {
        var failures = 0

        func expect(_ condition: Bool, _ name: String) {
            if condition {
                print("PASS  \(name)")
            } else {
                failures += 1
                print("FAIL  \(name)")
            }
        }

        let now = Date(timeIntervalSince1970: 1_777_237_200)

        expect(PageCopy.displayTitle(title: "", body: "First line\nSecond") == "First line", "empty title uses first body line")
        expect(PageCopy.displayTitle(title: "   ", body: "") == "Untitled page", "empty title and body is Untitled page")
        expect(PageCopy.displayTitle(title: "Kept", body: "ignored") == "Kept", "explicit title wins")

        expect(
            ComposePolicy.reuseBlankPage(createdAt: now, title: "", body: "", now: now.addingTimeInterval(0.2)),
            "double tap compose reuses blank"
        )
        expect(
            !ComposePolicy.reuseBlankPage(createdAt: now, title: "", body: "", now: now.addingTimeInterval(2)),
            "compose cooldown expires"
        )
        expect(
            !ComposePolicy.reuseBlankPage(createdAt: now, title: "Named", body: "", now: now.addingTimeInterval(0.2)),
            "named page is a new sheet"
        )

        expect(SeedPolicy.shouldSeed(storeIsEmpty: true, didLaunch: false), "first-run seeds")
        expect(!SeedPolicy.shouldSeed(storeIsEmpty: true, didLaunch: true), "second launch does not reseed empty desk")
        expect(!SeedPolicy.shouldSeed(storeIsEmpty: false, didLaunch: false), "existing pages are not replaced")

        let pages = [PageRecord(title: "River", body: "water", updatedAt: now)]
        expect(LibraryGrouping.group(pages: pages, query: "zebra", now: now).isEmpty, "empty search")
        expect(!LibraryGrouping.group(pages: pages, query: "", now: now).isEmpty, "blank query keeps pages")

        let recency = [
            PageRecord(title: "Now", body: "desk", updatedAt: now),
            PageRecord(title: "Old", body: "last month", updatedAt: now.addingTimeInterval(-20 * 24 * 60 * 60)),
        ]
        let keys = LibraryGrouping.group(pages: recency, query: "", now: now).map(\.section)
        expect(keys == [.today, .earlier], "recency buckets")

        expect(StyleSheetLayout.sections.last == "Size", "style sheet last row is Size")
        expect(KeyboardAvoidance.guessedBottomPoints == nil, "no guessed keyboard pad")
        expect(Ink.allowed(on: .night) == [.cream, .sepia], "night paper inks")

        let emptySheets = LibrarySheetCopy.sheets(pages: [LibraryPage](), query: "", now: now)
        expect(emptySheets.isEmpty, "1 empty desk has no sheets")
        expect(!LibraryListing.hasInk(title: "", body: ""), "1 blank untitled has no ink")
        expect(!LibraryListing.showsInLibrary(title: "", body: ""), "1 blank untitled is not a library card")
        expect(
            LibrarySheetCopy.sheets(
                pages: [LibraryPage(title: "", body: "", updatedAt: now, paper: .ivory, typeface: .book)],
                query: "",
                now: now
            ).isEmpty,
            "1 Untitled / 0 words is the empty desk"
        )
        expect(LibraryListing.hasInk(title: "Kept", body: ""), "1 a title is ink")
        expect(LibraryListing.hasInk(title: "", body: "a line"), "1 a body is ink")
        expect(LibraryEmpty.headline(searching: false) == "Empty", "1 empty desk copy")
        expect(LibraryEmpty.detail(searching: false).isEmpty, "1 empty desk detail omitted")
        expect(LibraryEmpty.markKind == "paper-stamp", "1 empty mark is the paper stamp")
        expect(LibraryEmpty.markKind != "paper-sheet", "1 empty mark is not a stacked empty-state card")
        expect(LibraryEmpty.markLetter == "V" && !LibraryEmpty.markWritesName, "1 stamp is a serif V, not the word Vellum")
        expect(LibraryEmpty.markHasRustMargin, "1 stamp has a rust margin")
        expect(LibraryEmpty.markSystemImage == nil, "1 empty is not an SF symbol")
        expect(LibraryEmpty.forbiddenMarks.contains("doc"), "1 SF doc is a forbidden mark")
        expect(!LibraryEmpty.forbiddenMarks.contains(LibraryEmpty.markKind), "1 empty mark is not a forbidden SF icon")
        expect(LibraryEmpty.composeStaysInChrome, "1 compose stays in chrome")
        expect(!LibraryEmpty.showsStartPage(searching: false), "1 no second Start a page")

        let onePage = [
            LibraryPage(title: "Late light on the river", body: "pewter water", updatedAt: now, paper: .cream, typeface: .book),
        ]
        let oneSheet = LibrarySheetCopy.sheets(pages: onePage, query: "", now: now)
        expect(oneSheet.count == 1, "2 one page yields one sheet")
        expect(oneSheet[0].kind == "paper-sheet", "2 cell is paper-sheet not notes-row")
        expect(oneSheet[0].kind != "notes-row", "2 forbid Notes thumbnail row")
        expect(oneSheet[0].face.isEmpty, "2 no typeface chip on the sheet")
        expect(!LibraryLook.showsFaceChip, "2 face chip is off")
        expect(LibraryLook.sheetMinHeight >= 160, "2 sheet is a page not a thumbnail")

        let longTitle = String(repeating: "Late light on the river ", count: 6).trimmingCharacters(in: .whitespaces)
        let longSheet = LibrarySheetCopy.cell(
            title: longTitle,
            body: "The Thames.",
            updatedAt: now,
            paper: .cream,
            typeface: .book,
            now: now
        )
        expect(longSheet.kind == "paper-sheet", "3 long title stays a paper sheet")
        expect(longSheet.title == longTitle, "3 long title is not rewritten")
        expect(longTitle.count > 40, "3 long title is actually long")

        expect(LibrarySheetCopy.sheets(pages: onePage, query: "river", now: now).count == 1, "4 search open keeps a match")
        expect(LibrarySheetCopy.sheets(pages: onePage, query: "zebra", now: now).isEmpty, "4 search open empty match")
        expect(LibraryEmpty.headline(searching: true) == "Nothing matches", "4 search open empty copy")
        expect(LibraryEmpty.markKind == "paper-stamp", "4 search empty is the paper stamp")
        expect(LibraryEmpty.markSystemImage == nil, "4 search empty is not an SF symbol")
        expect(LibraryEmpty.showsClearSearch(searching: true), "4 search empty keeps Clear search")
        expect(!LibraryEmpty.showsStartPage(searching: true), "4 compose stays in chrome")

        expect(LibraryLook.composeKind == "system", "5 compose is system")
        expect(LibraryLook.composeSystemImage == "square.and.pencil", "5 compose is square.and.pencil not a pill")
        expect(LibraryLook.searchablePrompt == "Search pages", "5 searchable prompt")
        expect(LibraryLook.composeKind != "custom-pill", "5 forbid custom + New page pill")
        expect(LibraryLook.greetingFamily == "Fraunces", "5 greeting is Fraunces not SF")
        expect(LibraryGreeting.family == "Fraunces", "5 greeting face is Fraunces")
        expect(LibraryGreeting.usesStockLargeTitle, "5 stock NavigationStack large title")
        expect(!LibraryGreeting.hidesNavBar, "5 do not hide the nav bar")
        expect(!LibraryGreeting.homemadeDraw, "5 do not homemade-draw the greeting")
        expect(LibraryGreeting.sizeKind == "largeTitle", "5 greeting size is system largeTitle")
        expect(LibraryGreeting.guessedPoints == nil, "5 greeting is not a guessed 34")
        expect(LibraryGreeting.forbiddenGuessedPads.contains(34), "5 34pt is a forbidden greeting guess")
        expect(LibraryGreeting.firstPaintVisible, "5 GREETING_CLIP first paint must be fully visible")
        expect(LibraryGreeting.emptyUsesScrollView, "5 empty desk hosts the large title in a scroll view")
        expect(!LibraryGreeting.greetingIgnoresSafeArea, "5 greeting stays in the safe title slot")
        expect(LibraryGreeting.deskFillIgnoresSafeArea, "5 desk fill may run under the bar")
        expect(LibraryGreeting.clipFail == "GREETING_CLIP", "5 fail name is GREETING_CLIP")
        expect(LibraryGreeting.italicOvershoot(systemAscender: 28, faceAscender: 32) == 4, "5 italic overshoot is face minus system")
        expect(LibraryGreeting.italicOvershoot(systemAscender: 28, faceAscender: 28) == 0, "5 no overshoot when ascenders match")
        expect(LibraryGreeting.italicOvershoot(systemAscender: 0, faceAscender: 32) == 0, "5 unmeasured overshoot is 0")
        expect(LibraryGreeting.italicOvershoot(systemAscender: 28, faceAscender: 32) != 34, "5 overshoot is not a 34 guess")
        expect(LibraryGreeting.airKind == "safeAreaPadding", "5 greeting air is safeAreaPadding")
        expect(LibraryGreeting.airUsesSystemDefault, "5 greeting air uses the system default, not 34")
        expect(!LibraryGreeting.hugsIsland, "5 greeting must not hug the island")
        expect(LibraryGreeting.belowGreeting == 0, "5 no extra line under the greeting")
        expect(LibraryGreeting.belowGreetingKind == "tight-title-to-subtitle", "5 greeting and date are one block")
        expect(LibraryGreeting.forbiddenGuessedPads.contains(16), "5 16pt under the greeting is the old miss")
        expect(!LibraryGreeting.forbiddenGuessedPads.contains(LibraryGreeting.belowGreeting), "5 below-greeting is not a 16/34 guess")
        expect(LibraryGreeting.titleLeading == 0 && LibraryGreeting.subtitleSharesLeading, "5 date line shares the greeting leading")
        expect(LibraryGreeting.subtitleFamily == "Fraunces", "5 date line is Fraunces, not SF")
        expect(LibraryGreeting.subtitleFamily != LibraryGreeting.subtitleForbiddenFamily, "5 date line is not SF Pro")
        expect(LibraryGreeting.subtitleStyle == "roman" && !LibraryGreeting.subtitleIsItalic, "5 date line is roman, not a second italic greeting")
        expect(LibraryGreeting.subtitleSizeKind == "subheadline", "5 date line is subheadline, quieter than largeTitle")
        expect(LibraryGreeting.subtitleSizeKind != "largeTitle", "5 date line is not largeTitle size")
        expect(LibraryGreeting.subtitleUsesStockSlot, "5 date line uses the stock subtitle slot")
        expect(LibraryGreeting.subtitleMarkKind == "path-lockup", "5 date line is a path lockup")
        expect(!LibraryGreeting.homemadeDraw && !LibraryGreeting.hidesNavBar, "5 date line does not homemade-draw or hide the nav")
        expect(DeskMarks.kind == "path-ink" && !DeskMarks.usesSystemFace, "5 desk marks are path ink, not SF")
        expect(DeskMarks.forbiddenFaces.contains("SF Pro") && DeskMarks.forbiddenFaces.contains("Inter"), "5 Inter and SF are forbidden faces")
        expect(DeskMarks.dateIsLive && !DeskMarks.dateFrozenBitmap, "5 date lockup stays live")
        expect(DeskMarks.dateLettering == "Fraunces" && DeskMarks.middotKind == "path", "5 date lettering is Fraunces; middot is a path")
        expect(DeskMarks.pageMarkKind == "paper-stamp" && DeskMarks.pageMarkHasRustMargin, "5 page count sits on a paper stamp")
        expect(DeskMarks.pinnedKind == "path-wordmark" && !DeskMarks.pinnedUsesSFCaps, "5 PINNED is a path wordmark, not SF caps")
        expect(DeskMarks.pinnedLettering == "Fraunces" && DeskMarks.pinnedVoiceOver == "Pinned", "5 PINNED lettering is Fraunces; VoiceOver says Pinned")
        expect(!DeskMarks.drawsFibre && !DeskMarks.greetingHomemade, "5 marks draw no fibre; greeting stays stock")
        expect(LibraryLook.pinnedHeaderKind == DeskMarks.pinnedKind, "5 pinned header is the desk mark")
        expect(DeskMetaCopy.isLive(label: DeskMetaCopy.dateLabel(now: now), now: now), "5 date label matches now")
        expect(DeskMetaCopy.spoken(count: 3, now: now).contains("3 pages"), "5 spoken count stays live")
        expect(DeskMetaCopy.spoken(count: 1, now: now).contains("1 page"), "5 singular page stays live")
        expect(LibraryLook.deleteKind == "swipe-and-menu", "5 library delete is swipe and menu")
        expect(!LibraryLook.deleteConfirms, "5 library delete has no confirm")
        expect(LibraryLook.deleteAllowsFullSwipe, "5 swipe can finish the delete")
        expect(LibraryLook.pinKind == "swipe-and-menu", "5 library pin is swipe and menu")

        let pinned = LibraryPage(
            title: "Kept",
            body: "pin me",
            updatedAt: now.addingTimeInterval(-20 * 24 * 60 * 60),
            paper: .cream,
            typeface: .book,
            isPinned: true
        )
        let todayPage = LibraryPage(
            title: "Today",
            body: "desk",
            updatedAt: now,
            paper: .cream,
            typeface: .book
        )
        let pinKeys = LibraryGrouping.group(pages: [pinned, todayPage], query: "", now: now).map(\.section)
        expect(pinKeys == [.pinned, .today], "5 pinned section leads")
        expect(LibraryPin.isPinnedAfterToggle(false) && !LibraryPin.isPinnedAfterToggle(true), "5 pin toggles")

        expect(PageStoreOpen.requiredPinCrashesOnPrePinRow(), "8 required isPinned cannot open a build-7 row")
        do {
            let legacy = try PageStoreOpen.openPrePinStore()
            expect(legacy.title == "Kept from seven", "8 pre-pin store keeps the page title")
            expect(legacy.body == "still here", "8 pre-pin store keeps the page body")
            expect(legacy.isPinned == nil, "8 missing pin column decodes as nil")
            expect(!legacy.pinOn, "8 missing pin defaults off")
            expect(legacy.pageID.uuidString == "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA", "8 pre-pin store keeps pageID")
        } catch {
            expect(false, "8 pre-pin store opens without crashing")
        }

        let sageHand = LibrarySheetCopy.cell(
            title: "things I noticed",
            body: "rain on warm pavement",
            updatedAt: now.addingTimeInterval(-26 * 60 * 60),
            paper: .sage,
            typeface: .hand,
            now: now
        )
        expect(sageHand.paper == .sage && sageHand.typeface == .hand, "6 sheet carries paper and type")
        expect(sageHand.face.isEmpty, "6 no Hand chip")
        expect(sageHand.footer == "Yesterday  ·  Sage", "6 quiet when and paper name")
        expect(!sageHand.footer.localizedCaseInsensitiveContains("Hand"), "6 footer is not a face chip")
        expect(!sageHand.footer.localizedCaseInsensitiveContains("word"), "6 footer is not a word count")
        expect(sageHand.typeface.familyName == "Caveat", "6 Hand is Caveat")
        expect(!LibraryLook.showsRecencyHeaders, "6 recency headers stay off")
        expect(!LibrarySection.today.showsHeader && LibrarySection.pinned.showsHeader, "6 only Pinned stamps a header")
        expect(!SampleDeskCopy.containsForbiddenPhrase(SampleDeskCopy.bookBody), "6 book sample is not journal")
        expect(!SampleDeskCopy.containsForbiddenPhrase(SampleDeskCopy.handBody), "6 hand sample is not journal")
        expect(!SampleDeskCopy.containsForbiddenPhrase(SampleDeskCopy.typeBody), "6 type sample is not journal")
        expect(SampleDeskCopy.typeBody.contains("oat milk, lemons"), "6 type list keeps the human list")
        expect(SampleDeskCopy.allBodies.count == 3, "6 three first-launch pages")

        expect(Typeface.book.familyName == "Literata", "Book is Literata")
        expect(Typeface.editorial.familyName == "Fraunces", "Editorial is Fraunces")
        expect(Typeface.hand.familyName == "Caveat", "Hand is Caveat")
        expect(Typeface.typewriter.familyName == "Special Elite", "Typewriter is Special Elite")
        expect(Typeface.sans.familyName == "Source Sans 3", "Sans is Source Sans 3")
        expect(Typeface.mono.familyName == "IBM Plex Mono", "Mono is IBM Plex Mono")

        var grainSeen: Set<UInt64> = []
        var grainOK = true
        for paper in Paper.allCases {
            let seed = PaperGrain.seed(for: paper)
            if seed == 0 || !grainSeen.insert(seed).inserted { grainOK = false }
        }
        expect(grainOK, "7 paper grain seed is unsigned and distinct")
        expect(!PaperLook.drawsFibreStrokes, "7 no vertical fibre strokes")
        expect(PaperLook.forbiddenFibreStep == 18, "7 18pt fibre step is forbidden")
        expect(PaperLook.keepsGrainSpeckle, "7 grain speckle stays")
        expect(PaperLook.keepsHorizontalRules, "7 ruled paper keeps horizontal rules")
        expect(DeskLook.followsSystemColorScheme, "7 desk follows system colorScheme")
        expect(!DeskLook.hasSettingsToggle, "7 no appearance settings toggle")
        expect(!DeskLook.remapsCatalogPaper, "7 cream sheets stay cream on a night desk")
        expect(DeskLook.darkDesk == "night", "7 dark desk is night, not system gray")
        expect(DeskLook.emptyMarkStaysLight && DeskLook.emptyMarkPaper == "cream", "7 empty mark stays a cream sheet")
        expect(DeskLook.editorSurface == "page-paper", "7 editor is the page paper, not a desk frame")
        expect(DeskLook.preferredColorScheme == nil, "7 no forced preferredColorScheme")
        expect(DeskLook.usesBackdrop && DeskLook.hasTooth && DeskLook.hasVignette, "7 desk is a surface, not a flat fill")
        expect(DeskLook.vignetteKind == "edge-darken", "7 vignette is edge-darken")
        expect(!DeskLook.forbiddenVignettes.contains(DeskLook.vignetteKind), "7 no starfield / wellness / copilot")
        expect(!DeskLook.drawsFibreStrokes, "7 desk has no fibre strokes")
        expect(LibraryEmpty.markPaper == "cream" && !LibraryEmpty.markDrawsRuling, "7 empty mark is unruled cream")
        expect(LibraryEmpty.markKind == "paper-stamp" && LibraryEmpty.markHasRustMargin, "7 empty stamp is cream + rust + V")

        expect(EditorLook.surfaceKind == "paper-full", "E1 whole editor is paper")
        expect(EditorLook.surfaceKind != "sheet-on-desk", "E1 not a card on a desk")
        expect(EditorLook.layoutKind == "column-plus-inset", "E1 column plus safeAreaInset, not a fraction card")
        expect(EditorLook.layoutKind != "fraction-card", "E1 discard postcard height math")
        expect(EditorLook.isFullBleed, "E1 paper is edge to edge")
        expect(EditorLook.deskPeek == 0, "E1 no desk-grain frame")
        expect(EditorLook.sheetMaxHeightFraction == nil, "E1 no sheetMaxHeightFraction")
        expect(EditorLook.footerPlacement == "safeAreaInset", "E1 footer is safeAreaInset")
        expect(EditorLook.fillsToolbarToInset, "E1 paper fills toolbar-to-inset")
        expect(EditorLook.grainReveal == "none", "E1 grainReveal is none")
        expect(EditorLook.grainReveal != "edge-only", "E1 grain is not an edge frame")
        expect(EditorLook.typeLeading == 24 && EditorLook.typeTrailing == 24, "E1 type origin leading/trailing 24")
        expect(EditorLook.typeLeadingLined == 56 && EditorLook.dateTop == 8, "E1 lined leading 56, date top 8")
        expect(EditorLook.typeLeading(for: .cream) == 24 && EditorLook.typeLeading(for: .ruled) == 56, "E1 type leading by ruling")
        expect(EditorLook.bodyHoldsSeveralParagraphs && !EditorLook.clipsBody, "E1 several paragraphs do not clip")
        expect(EditorLook.bodyMinHeight >= 240, "E1 body is tall enough for several paragraphs")
        expect(EditorLook.writingHeight(inField: 668) == 668, "E1 paper uses the full field")
        expect(EditorLook.bodyFitsSeveralParagraphs(inFieldHeight: 668), "E1 several paragraphs fit without clipping")
        expect(!EditorLook.keyboardOpenProven, "E1 keyboard-open remains undone")
        expect(EditorLook.cornerRadius == 0, "E1 no rounded sheet")
        expect(EditorLook.wrap == "native", "E1 not a web wrap")

        let editorFooter = EditorSheetCopy.footer(wordCount: 66, paper: .cream, typeface: .book)
        expect(editorFooter.words == "66 words", "E2 footer word count")
        expect(editorFooter.style.isEmpty, "E2 footer has no paper · typeface")
        expect(!EditorLook.footerShowsStyle, "E2 word-count does not print Night · Book")
        expect(editorFooter.placement == "safeAreaInset", "E2 footer uses safeAreaInset")
        expect(EditorSheetCopy.showsFooter(focus: false), "E3 footer shows when not focused")
        expect(!EditorSheetCopy.showsFooter(focus: true), "E3 focus hides footer")

        expect(EditorLook.backKind == "system", "E4 system back")
        expect(EditorLook.focusKind == "system-toolbar", "E4 toolbar Focus")
        expect(EditorLook.focusEyeStays, "E4 focus eye stays visible")
        expect(!EditorLook.focusHidesNavBar, "E4 focus does not hide the nav bar")
        expect(EditorLook.stylesDetentStart == "medium", "E4 Page style starts at medium")
        expect(EditorLook.stylesKind == "system-sheet", "E4 styles is system .sheet")
        expect(EditorLook.stylesSystemImage == "textformat", "E4 system textformat not custom T")
        expect(EditorLook.backKind != "circular-web", "E4 forbid circular web back")

        expect(KeyboardAvoidance.guessedBottomPoints == nil, "E5 KB_COVER no guessed pad")
        expect(EditorLook.guessedKeyboardPad == nil, "E5 editor has no guessed keyboard pad")
        expect(EditorLook.bodyKind == "text-editor", "E5 body is TextEditor")
        expect(EditorLook.bodyKind != "nested-scrollview", "E5 forbid nested ScrollView")
        expect(StyleSheetLayout.sections.last == "Size", "E5 style last section reachable")
        expect(EditorSheetCopy.footer(wordCount: 1, paper: .ruled, typeface: .book).words == "1 word", "E5 singular word")
        expect(EditorLook.footerPlacement == "safeAreaInset", "E5 footer rides the system safe area")
        expect(!EditorLook.forbiddenGuessedPads.contains(34), "E5 no 34pt guess")
        expect(!EditorLook.forbiddenGuessedPads.contains(120), "E5 no 120pt guess")
        expect(EditorLook.minimumHit == 44, "E5 thumb-sized controls")
        expect(KeyboardAvoidance.wordCountAir > 0 && KeyboardAvoidance.wordCountAir < 8, "E5 word-count air is a few points")
        expect(KeyboardAvoidance.wordCountAir != 16, "E5 16pt air was the paper band")
        expect(!KeyboardChrome.forbiddenWordCountAir.contains(KeyboardAvoidance.wordCountAir), "E5 word-count air is not 16 / 34 / 120")
        expect(KeyboardAvoidance.wordCountBottomPad(keyboardLift: 0) == 0, "E5 no extra air when keyboard is down")
        expect(KeyboardAvoidance.wordCountBottomPad(keyboardLift: 280) == KeyboardAvoidance.wordCountAir, "E5 air when keyboard lift is real")

        expect(KeyboardChrome.gutterFill == "paper", "E5 keyboard-open gutters are paper")
        expect(KeyboardChrome.gutterFill != "system-white", "E5 forbid system-white beside the keys")
        expect(!KeyboardChrome.systemWhiteGutter, "E5 no system-white gutter")
        expect(KeyboardChrome.paperRegions.contains("keyboard"), "E5 paper ignores the keyboard region")
        expect(KeyboardChrome.paperRegions.contains("container"), "E5 paper still ignores the container")
        expect(EditorLook.paperIgnoresKeyboard, "E5 paper stays behind the keys")
        expect(KeyboardChrome.liftKind == "layout-guide", "E5 pad follows the keyboard layout guide")
        expect(KeyboardChrome.liftKind != "safe-area-jump", "E5 forbid a jumped safe-area pad")
        expect(!KeyboardChrome.liftJumpsAtAnimationStart, "E5 text must not jump when the keys start moving")
        expect(KeyboardChrome.textTracksKeyboard, "E5 text travels with the keyboard")
        expect(KeyboardChrome.openPadIsKeyboardOnly, "E5 open pad is keyboard-only")
        expect(KeyboardChrome.writingBottomPad(guidePad: 280, restingPad: 34) == 246, "E5 open pad is guide minus resting")
        expect(KeyboardChrome.writingBottomPad(guidePad: 34, restingPad: 34) == 34, "E5 closed pad is the home indicator")
        expect(KeyboardChrome.writingBottomPad(guidePad: 280, restingPad: 0) == 280, "E5 unknown resting keeps the guide")
        expect(KeyboardChrome.restingPad(current: 0, reported: 34) == 34, "E5 first measured inset is resting")
        expect(KeyboardChrome.restingPad(current: 34, reported: 300) == 34, "E5 rising keyboard does not rewrite resting")
        expect(KeyboardChrome.keyboardOnlyLift(guidePad: 34, restingPad: 34) == 0, "E5 no lift when the guide is at rest")
        expect(KeyboardChrome.keyboardOnlyLift(guidePad: 300, restingPad: 34) == 266, "E5 lift is guide minus resting")
        expect(KeyboardChrome.keyboardOnlyLift(guidePad: 300, restingPad: 0) == 0, "E5 no lift until resting is known")
        expect(KeyboardChrome.wordCountSitsOnKeyboard, "E5 word-count sits on the keys")
        expect(KeyboardChrome.wordCountKind == "caption", "E5 word-count is a caption, not a thumb control")
        expect(!KeyboardChrome.wordCountUsesMinimumHit, "E5 44pt minHeight was the paper band")
        expect(!KeyboardChrome.caretFollowsWordCount, "E5 per-keystroke park stacked glyphs")
        expect(!KeyboardChrome.caretParksPerKeystroke, "E5 system editor scrolls")
        expect(!KeyboardChrome.pinsPageToBottom, "E5 short pages are not pinned to the bottom")
        expect(KeyboardChrome.caretRoomEdge == "bottom", "E5 extra room is under the body, not a top inset")
        expect(KeyboardChrome.caretRoomEdge != "top", "E5 a top inset would shift origin")
        expect(KeyboardChrome.caretScrollTarget == "system", "E5 system editor keeps the caret visible")
        expect(KeyboardChrome.caretScrollTarget != "caret", "E5 caret-rect nudge stacked glyphs")
        expect(KeyboardChrome.caretScrollTarget != "body", "E5 scrollTo(body) left Mini 42pt high")
        expect(KeyboardChrome.caretScrollTarget != "floor", "E5 scrollTo(floor) tucked the last line under the title")
        expect(!KeyboardChrome.caretUsesCaretRect, "E5 do not chase the caret rect per key")
        expect(!KeyboardChrome.capsBodyToMeasuredHeight, "E5 stale measure height stacked glyphs")
        expect(KeyboardChrome.caretClearanceInsideTarget, "E5 clearance lives inside the body target")
        expect(KeyboardChrome.caretClearanceLines == 0, "E5 not an extra pitch above the hairline")
        expect(
            KeyboardChrome.caretClearance(lineHeight: PaperRuling.bodyLineHeight(bodyPoints: TypeSize.m.bodyPoints))
                == KeyboardAvoidance.wordCountAir,
            "E5 clearance is a few points, not a ruling"
        )
        expect(KeyboardChrome.caretClearance(lineHeight: PaperRuling.pitch) == KeyboardAvoidance.wordCountAir, "E5 clearance equals word-count air")
        expect(KeyboardChrome.caretClearance(lineHeight: 0) == 0, "E5 no clearance without a line height")
        expect(KeyboardChrome.caretClearance(lineHeight: PaperRuling.pitch) < PaperRuling.pitch, "E5 clearance is not a pitch")
        expect(KeyboardChrome.caretClearance(lineHeight: PaperRuling.pitch) != 34, "E5 clearance is not a 34 guess")
        expect(KeyboardChrome.caretClearance(lineHeight: PaperRuling.pitch) != 120, "E5 clearance is not a 120 guess")
        expect(
            !KeyboardChrome.clearanceStacksOnLeftover(lineHeight: PaperRuling.pitch, leftoverPad: EditorLook.bodyBottomPad),
            "E5 leftover + clearance is not a ruling of empty paper"
        )
        expect(KeyboardChrome.leftoverPad == EditorLook.bodyBottomPad, "E5 leftover pad is the editor bottom pad")
        expect(KeyboardChrome.caretFloor(visibleHeight: 400, columnHeight: 300) == 0, "E5 no slack under the last line")
        expect(KeyboardChrome.caretFloor(visibleHeight: 400, columnHeight: 500) == 0, "E5 no floor when the column is taller than the field")
        expect(KeyboardChrome.caretFloor(visibleHeight: 400, columnHeight: 0) == 0, "E5 unmeasured column does not fill the field")
        expect(
            KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 328, following: true) == 72,
            "E5 Mini 18 leftover sits above the column"
        )
        expect(KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 300, following: true) == 100, "E5 follow slack is leftover above")
        expect(KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 300, following: false) == 0, "E5 closed has no slack above")
        expect(KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 0, following: true) == 0, "E5 unmeasured column does not invent slack")
        expect(KeyboardChrome.caretSlackAbove(visibleHeight: 400, columnHeight: 500, following: true) == 0, "E5 no slack when the column is taller")
        expect(KeyboardChrome.caretFieldFill(visibleHeight: 400, following: true) == 400, "E5 follow fills the field")
        expect(KeyboardChrome.caretFieldFill(visibleHeight: 400, following: false) == 0, "E5 closed does not fill the field")
        expect(KeyboardChrome.caretFieldFill(visibleHeight: 0, following: true) == 0, "E5 unmeasured field does not fill")
        expect(KeyboardChrome.caretUsesLiveGuide, "E5 caret field follows the live layout guide")
        expect(KeyboardChrome.caretNudge(caretBottom: 481, hairlineY: 523, air: 4) == -38, "E5 Mini 20 last_ink is 42pt above the hairline")
        expect(KeyboardChrome.caretTopInset(nudge: -38) == 38, "E5 too-high caret lifts the column")
        expect(KeyboardChrome.caretBottomInset(nudge: -38) == 0, "E5 too-high caret does not sink")
        expect(KeyboardChrome.caretNudge(caretBottom: 533, hairlineY: 523, air: 4) == 14, "E5 phone clip is a positive nudge")
        expect(KeyboardChrome.caretBottomInset(nudge: 14) == 14, "E5 too-low caret sinks under the count")
        expect(KeyboardChrome.caretNudge(caretBottom: 519, hairlineY: 523, air: 4) == 0, "E5 flush caret does not nudge")
        expect(KeyboardChrome.caretNudge(caretBottom: 0, hairlineY: 523, air: 4) == 0, "E5 unmeasured caret does not nudge")
        expect(KeyboardChrome.caretNudge(caretBottom: 481, hairlineY: 523, air: 4) != 34, "E5 nudge is not a 34 guess")
        expect(KeyboardChrome.caretNudge(caretBottom: 481, hairlineY: 523, air: 4) != 120, "E5 nudge is not a 120 guess")
        expect(
            KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 280, restingPad: 34, insetHeight: 20) == 534,
            "E5 visible field is container minus live pad minus inset"
        )
        expect(
            KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 340, restingPad: 34, insetHeight: 20) == 474,
            "E5 taller phone keyboard shrinks the caret field"
        )
        expect(
            KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 340, restingPad: 34, insetHeight: 20)
                < KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 280, restingPad: 34, insetHeight: 20),
            "E5 phone keyboard is not Mini-sized"
        )
        expect(
            KeyboardChrome.caretVisibleHeight(containerHeight: 800, guidePad: 280, restingPad: 34, insetHeight: 0) == 554,
            "E5 do not invent a 44pt inset"
        )
        expect(
            KeyboardChrome.caretVisibleHeight(containerHeight: 0, guidePad: 280, restingPad: 34, insetHeight: 20) == 0,
            "E5 unmeasured container does not invent a field"
        )
        expect(KeyboardChrome.caretScrollOverlap(fieldHeight: 554, visibleHeight: 534) == 20, "E5 overlap is ScrollView behind the hairline")
        expect(KeyboardChrome.caretScrollOverlap(fieldHeight: 534, visibleHeight: 534) == 0, "E5 no overlap when the field matches")
        expect(KeyboardChrome.caretScrollOverlap(fieldHeight: 0, visibleHeight: 534) == 0, "E5 unmeasured field has no overlap")
        expect(EditorLook.bodyEditorHeight(measured: 208, empty: false) == 208, "E5 editor hugs the measured body")
        expect(EditorLook.bodyEditorHeight(measured: 208, empty: false) != EditorLook.bodyMinHeight, "E5 280 inside body was Mini 18 empty paper")
        expect(EditorLook.bodyEditorHeight(measured: 0, empty: false) == EditorLook.bodyMinHeight, "E5 unmeasured body keeps the min")
        expect(EditorLook.bodyEditorHeight(measured: 208, empty: true) == EditorLook.bodyMinHeight, "E5 empty body keeps the min")
        expect(
            KeyboardChrome.caretRuleOffset(base: 64, visibleHeight: 400, columnHeight: 300, following: true) == 164,
            "E5 rules travel with the column when the field is filled"
        )
        expect(
            KeyboardChrome.caretRuleOffset(base: 64, visibleHeight: 400, columnHeight: 300, following: false) == 64,
            "E5 closed rules stay on the locked origin"
        )
        expect(EditorLook.typeLeading == 24 && EditorLook.dateTop == 8, "E5 type origin stays locked")
        expect(StyleSheetLayout.lastSectionReachable, "E5 last sheet section reachable")
        expect(StyleSheetLayout.detentKind == "medium-first", "E5 Page sheet opens medium")
        expect(StyleSheetLayout.scrollBottomPad >= 44, "E5 sheet scroll pad lets Typewriter/Size through")
        expect(Typeface.allCases.map(\.name).contains("Typewriter"), "E5 Typewriter is in the catalogue")

        expect(PaperRuling.pitch == 32, "E7 shared rule pitch is 32")
        expect(PaperRuling.step(ruling: .lines, compact: false) == 32, "E7 editor lines use pitch")
        expect(PaperRuling.step(ruling: .dots, compact: false) == 32, "E7 editor dots use the same pitch")
        expect(PaperRuling.step(ruling: .lines, compact: true) == 22, "E7 library compact lines unchanged")
        expect(PaperRuling.step(ruling: .dots, compact: true) == 16, "E7 library compact dots unchanged")
        expect(PaperRuling.bodyLineHeight(bodyPoints: TypeSize.m.bodyPoints) == 32, "E7 body line box is one pitch")
        expect(PaperRuling.titleLineHeight(titlePoints: TypeSize.m.titlePoints) == 64, "E7 title line box is two pitches")
        expect(PaperRuling.sitsOnRule(PaperRuling.bodyLineHeight(bodyPoints: 17)), "E7 size S sits on the rule")
        expect(PaperRuling.firstRuleOffset == 64, "E7 first-line offset is one title box")
        expect(EditorLook.grainReveal == "none", "E7 still paper-full, not a desk frame")

        let deskSeed = PaperGrain.seed(forToken: "desk")
        expect(deskSeed != 0, "E6 desk grain seed is unsigned and non-zero")
        expect(deskSeed != PaperGrain.seed(for: .cream), "E6 desk seed is not cream paper")

        expect(!DeleteDecision.confirms, "delete confirm is a fail")
        expect(DeleteDecision.shouldDelete(confirmed: false), "delete press removes the page")
        expect(DeleteDecision.undoKind == "snackbar", "delete undo is a snackbar")
        expect(DeleteDecision.undoCopy == "Removed page", "delete undo copy")
        expect(DeleteDecision.undoAction == "Undo", "delete undo action")
        expect(DeleteDecision.animationKind == "spring", "delete animates out")
        expect(DeleteDecision.reduceMotionIsInstant, "delete reduce-motion is instant")
        expect(DeskMotion.kind == "spring" && DeskMotion.insertionMoves, "desk motion is a spring and insertion moves")
        expect(DeskMotion.pinUsesMotion && DeskMotion.focusUsesMotion, "pin and focus use desk motion")
        expect(DeskMotion.reduceMotionIsInstant, "desk reduce-motion is instant")
        expect(!DeskMotion.focusHidesNavBar && !DeskMotion.focusRestylesPaper, "focus keeps the nav bar and the paper")
        expect(DeleteDecision.animationKind == DeskMotion.kind, "delete shares desk motion")
        expect(!EditorLook.focusHidesNavBar && EditorLook.focusEyeStays, "focus eye stays on the system toolbar")
        expect(LibraryEmpty.markKind == "paper-stamp", "empty stamp stays after motion")
        let undone = DeletedPage(
            pageID: UUID(uuidString: "A11CE001-0000-4000-8000-00000000DE01")!,
            title: "River",
            body: "pewter",
            createdAt: now,
            updatedAt: now,
            fontId: "book",
            paperId: "cream",
            inkId: "charcoal",
            sizeId: "m",
            isPinned: nil
        )
        expect(undone.title == "River" && undone.body == "pewter", "delete undo snapshot keeps the page")

        expect(DebugOpenFirst.environmentKey == "VELLUM_OPEN_FIRST", "debug open-first env key")
        expect(!DebugOpenFirst.shouldOpenFirstPage(environment: [:], debugBuild: true), "debug open-first off without env")
        expect(
            DebugOpenFirst.shouldOpenFirstPage(environment: ["VELLUM_OPEN_FIRST": "1"], debugBuild: true),
            "debug open-first on when env is 1"
        )
        expect(
            !DebugOpenFirst.shouldOpenFirstPage(environment: ["VELLUM_OPEN_FIRST": "1"], debugBuild: false),
            "release ignores VELLUM_OPEN_FIRST"
        )
        expect(DebugOpenFirst.pageToOpen(from: [1, 2]) == 1, "debug open-first takes the first page")
        expect(DebugOpenFirst.pageToOpen(from: [Int]()) == nil, "debug open-first no-ops on empty desk")

        expect(DebugFocusBody.environmentKey == "VELLUM_FOCUS_BODY", "debug focus-body env key")
        expect(DebugFocusBody.field == "body", "debug focus-body targets the body")
        expect(!DebugFocusBody.shouldFocusBody(environment: [:], debugBuild: true), "debug focus-body off without env")
        expect(
            DebugFocusBody.shouldFocusBody(environment: ["VELLUM_FOCUS_BODY": "1"], debugBuild: true),
            "DEBUG true + flag focuses body"
        )
        expect(
            DebugFocusBody.fieldToFocus(environment: ["VELLUM_FOCUS_BODY": "1"], debugBuild: true) == "body",
            "DEBUG true + flag field is body"
        )
        expect(
            !DebugFocusBody.shouldFocusBody(environment: ["VELLUM_FOCUS_BODY": "1"], debugBuild: false),
            "release never focuses body"
        )
        expect(
            DebugFocusBody.fieldToFocus(environment: ["VELLUM_FOCUS_BODY": "1"], debugBuild: false) == nil,
            "release fieldToFocus is nil"
        )
        expect(!EditorLook.keyboardOpenProven, "keyboard-open stays unproven without Mini pixels")
        expect(EditorLook.deskPeek == 0, "no desk-grain frame")
        expect(EditorLook.grainReveal == "none", "grainReveal is none")
        expect(EditorLook.layoutKind == "column-plus-inset", "writing column unchanged")

        expect(PagePlainText.fileName(title: "", body: "") == "Untitled page.txt", "share untitled filename")
        expect(PagePlainText.fileName(title: "UI/UX", body: "") == "UI-UX.txt", "share sanitizes slash")
        expect(PagePlainText.contents(title: "Title", body: "Body") == "Title\n\nBody", "share txt body")

        if failures == 0 {
            print("linux-hammer: 0 failures")
            exit(0)
        } else {
            print("linux-hammer: \(failures) failures")
            exit(1)
        }
    }
}
