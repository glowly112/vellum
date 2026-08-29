# Hammer (cap 8)

Run on a Mac: `xcodebuild -project ios/VellumPad/VellumPad.xcodeproj -scheme VellumPad -destination 'platform=iOS Simulator,name=iPhone 16' test`

This Linux worker cannot run that. Logic cases are `VellumPadTests/HammerTests.swift` and `ios/scripts/linux-hammer.swift`.

| # | Case | What must happen |
| --- | --- | --- |
| 1 | Empty title | Library and share show first body line, or **Untitled page**. Field stays blank. |
| 2 | Back then return | Editor reads the live SwiftData page (`@Query` + `revise`). No copied `@State` title/body. |
| 3 | Double tap compose | Second tap within 0.8s on a still-blank page opens the same page. |
| 4 | First-run samples | Empty store + first launch seeds three sample pages. Later empty desk is empty. |
| 5 | Empty search | “Nothing matches” + Clear search + Start a page. |
| 6 | Keyboard cover | Editor uses `TextEditor` (not a nested `ScrollView`). Footer sits on the sheet (no guessed 34pt/120pt). Opening Page dismisses the keyboard. Style sheet last row is **Size**. Fail if `KB_COVER`. |
| 7 | Delete confirm | Cancel leaves the page. Confirm deletes and pops. |
| 8 | Share `.txt` | System share sheet. Empty title → `Untitled page.txt`. |

## Library sheets (this turn, 7)

Logic in `LibrarySheetCopy` / `LibraryEmpty` / `PaperGrain`. Run: `ios/scripts/prove.sh` (linux-hammer is the test target on this VM).

| # | Case | What must happen |
| --- | --- | --- |
| 1 | Empty desk | No sheets. Copy: **The desk is clear**. |
| 2 | One page | One **paper-sheet** (not a Notes `notes-row`, not an `Aa` stamp). Face is the type name. Height ≥ 160. |
| 3 | Long title | Title stays on the sheet, unrewritten. Still `paper-sheet`. |
| 4 | Search open | Match stays. Miss → no sheets + **Nothing matches**. |
| 5 | Compose | System `square.and.pencil`, prompt **Search pages**. Fail a custom `+ New page` pill. Greeting family is Fraunces. |
| 6 | Paper / type | Sage + Hand sheet carries those, face **Hand**, footer `N words · Sage`, Caveat family. |
| 7 | Grain seed | `PaperGrain.seed` is unsigned and distinct per paper. Fail `UInt64(hashValue)`. |

## Editor sheet on desk (this turn, 6)

Logic in `EditorLook` / `EditorSheetCopy` / `PaperGrain.seed(forToken:)`.

| # | Case | What must happen |
| --- | --- | --- |
| 1 | Sheet on desk | Large page, thin desk frame. Inset 8–20, bottom 8–24, fraction 0.88–1 (not 1). Fail a 0.76 postcard and a full-bleed Notes page. |
| 2 | Footer copy | `66 words` and `Cream · Book` live **on-sheet**. |
| 3 | Focus | Footer hides in focus. Toolbar Focus / styles stay system. |
| 4 | Chrome | System back, system `.sheet`, `textformat` — not a circular web back or custom T. |
| 5 | KB_COVER | No guessed pad. Body is `text-editor`. Style last section is **Size**. |
| 6 | Desk grain | `PaperGrain.seed(forToken: "desk")` is unsigned and not the cream paper seed. |
| 7 | Debug open-first | `VELLUM_OPEN_FIRST=1` opens the first page in Debug only. Release ignores the env. |
