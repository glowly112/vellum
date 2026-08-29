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
        expect(LibraryEmpty.headline(searching: false) == "The desk is clear", "1 empty desk copy")

        let onePage = [
            LibraryPage(title: "Late light on the river", body: "pewter water", updatedAt: now, paper: .cream, typeface: .book),
        ]
        let oneSheet = LibrarySheetCopy.sheets(pages: onePage, query: "", now: now)
        expect(oneSheet.count == 1, "2 one page yields one sheet")
        expect(oneSheet[0].kind == "paper-sheet", "2 cell is paper-sheet not notes-row")
        expect(oneSheet[0].kind != "notes-row", "2 forbid Notes thumbnail row")
        expect(oneSheet[0].face == "Book", "2 face stamp is the type name")
        expect(oneSheet[0].face != "Aa", "2 face stamp is not Aa")
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

        expect(LibraryLook.composeKind == "system", "5 compose is system")
        expect(LibraryLook.composeSystemImage == "square.and.pencil", "5 compose is square.and.pencil not a pill")
        expect(LibraryLook.searchablePrompt == "Search pages", "5 searchable prompt")
        expect(LibraryLook.composeKind != "custom-pill", "5 forbid custom + New page pill")
        expect(LibraryLook.greetingFamily == "Fraunces", "5 greeting is Fraunces not SF")

        let sageHand = LibrarySheetCopy.cell(
            title: "things I noticed",
            body: "rain on warm pavement",
            updatedAt: now.addingTimeInterval(-26 * 60 * 60),
            paper: .sage,
            typeface: .hand,
            now: now
        )
        expect(sageHand.paper == .sage && sageHand.typeface == .hand, "6 sheet carries paper and type")
        expect(sageHand.face == "Hand", "6 face stamp is Hand")
        expect(sageHand.footer == "7 words  ·  Sage", "6 word count and paper name")
        expect(sageHand.typeface.familyName == "Caveat", "6 Hand is Caveat")

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
        expect(editorFooter.style == "Cream · Book", "E2 footer Cream · Book")
        expect(editorFooter.placement == "safeAreaInset", "E2 footer uses safeAreaInset")
        expect(EditorSheetCopy.showsFooter(focus: false), "E3 footer shows when not focused")
        expect(!EditorSheetCopy.showsFooter(focus: true), "E3 focus hides footer")

        expect(EditorLook.backKind == "system", "E4 system back")
        expect(EditorLook.focusKind == "system-toolbar", "E4 toolbar Focus")
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

        let deskSeed = PaperGrain.seed(forToken: "desk")
        expect(deskSeed != 0, "E6 desk grain seed is unsigned and non-zero")
        expect(deskSeed != PaperGrain.seed(for: .cream), "E6 desk seed is not cream paper")

        expect(DeleteDecision.shouldDelete(confirmed: false) == false, "delete cancel")
        expect(DeleteDecision.shouldDelete(confirmed: true) == true, "delete confirm")

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
