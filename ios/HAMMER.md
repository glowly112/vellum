# Hammer (cap 8)

Run on a Mac: `xcodebuild -project ios/VellumPad/VellumPad.xcodeproj -scheme VellumPad -destination 'platform=iOS Simulator,name=iPhone 16' test`

This Linux worker cannot run that. Logic cases are `VellumPadTests/HammerTests.swift` and `ios/scripts/linux-hammer.swift`.

| # | Case | What must happen |
| --- | --- | --- |
| 1 | Empty title | Library and share show first body line, or **Untitled page**. Field stays blank. |
| 2 | Back then return | Editor reads the live SwiftData page (`@Query` + `revise`). No copied `@State` title/body. |
| 3 | Double tap compose | Second tap within 0.8s on a still-blank page opens the same page. |
| 4 | First-run samples | Empty store + first launch seeds three sample pages. Later empty desk is empty. |
| 5 | Empty search | “Nothing matches” + Clear search. Empty mark is a paper sheet, not SF. Compose stays in chrome. |
| 6 | Keyboard cover | Editor uses `TextEditor` (not a nested `ScrollView`). Word-count is a `safeAreaInset` (no guessed 34pt/120pt). Opening Page dismisses the keyboard. Style sheet last row is **Size**. Fail if `KB_COVER`. Fail `TEXT_OVERLAP`: wrapping lines with the keyboard open must sit below the previous line — dismiss-keyboard cleaning the page is the tell. Keyboard-open pixels are still undone. System editor scrolls — no per-keystroke park. |
| 7 | Delete | Press / swipe and the page is gone. No confirm. Spring out; Reduce Motion is instant. Undo snackbar. |
| 8 | Share `.txt` | System share sheet. Empty title → `Untitled page.txt`. |

## Library sheets (this turn, 7)

Logic in `LibrarySheetCopy` / `LibraryEmpty` / `PaperGrain`. Run: `ios/scripts/prove.sh` (linux-hammer is the test target on this VM).

| # | Case | What must happen |
| --- | --- | --- |
| 1 | Empty desk | No sheets. Copy: **The desk is clear**. Mark is a quiet cream **paper-sheet**, not SF `doc`. Compose stays in chrome. First paint: greeting fully visible (fail `GREETING_CLIP`). Empty hosts a scroll view so the large title can sit there. |
| 2 | One page | One **paper-sheet** (not a Notes `notes-row`, not an `Aa` stamp). Face is the type name. Height ≥ 160. |
| 3 | Long title | Title stays on the sheet, unrewritten. Still `paper-sheet`. |
| 4 | Search open | Match stays. Miss → no sheets + **Nothing matches**. |
| 5 | Compose | System `square.and.pencil`, prompt **Search pages**. Fail a custom `+ New page` pill. Greeting is Fraunces on the stock large-title slot (system largeTitle size, not 34). First paint empty **and** with pages: full glyphs. Fail `GREETING_CLIP`. Do not hide the nav bar. |
| 6 | Paper / type | Sage + Hand sheet carries those, face **Hand**, footer `N words · Sage`, Caveat family. |
| 7 | Grain seed | `PaperGrain.seed` is unsigned and distinct per paper. Fail `UInt64(hashValue)`. |
| 8 | Delete / pin | Swipe + context menu. Delete has **no confirm**. Undo snackbar. Pin toggles a stored flag and a **Pinned** section. |

## Editor writing column (this turn)

Logic in `EditorLook` / `EditorSheetCopy` / `PaperGrain.seed(forToken:)`.

Apple TextEditor: “A view that can display and edit long-form text.” Multiline, scrollable.
Apple `safeAreaInset`: shows specified content beside the modified view and increases the safe area by that content.

| # | Case | What must happen |
| --- | --- | --- |
| 1 | Writing column | `surfaceKind == paper-full`. `grainReveal == none` (not edge-only). `deskPeek == 0`. Paper edge to edge. Type origin 24 / 56 lined / 24, date top 8. Fail a desk-grain frame or rounded sheet on grain. Keyboard-open remains undone. |
| 2 | Footer copy | `66 words` lives in a bottom **`safeAreaInset`**. No paper · typeface on the inset (Night · Book is gone). |
| 3 | Focus | Eye stays on the system toolbar and turns Focus off. Nav bar is not hidden. Word-count hides in focus. |
| 4 | Chrome | System back, system `.sheet` starting at **medium**, `textformat` — not a circular web back or custom T. |
| 5 | KB_COVER | No guessed pad (not 34 / 42 / 44 / 120). Word-count is a caption on the keys. The **system TextEditor** fills the field and scrolls (not scrollTo(body) / a caret-rect nudge / a lagged measure height). Fail `TEXT_OVERLAP`: type wrapping lines with the keyboard open; new glyphs must not paint on top of old lines. Dismiss-keyboard cleaning the page is the tell. Closed origin stays. Not pinned to the bottom. |
| 6 | Desk grain | `PaperGrain.seed(forToken: "desk")` is unsigned and not the cream paper seed. |
| 7 | Debug open-first | `VELLUM_OPEN_FIRST=1` opens the first page in Debug only. Release ignores the env. |
| 8 | Debug focus-body | `VELLUM_FOCUS_BODY=1` focuses the body `TextEditor` in Debug only. Release never focuses. `keyboardOpenProven` stays false. |
| 9 | Rule pitch | Shared `PaperRuling.pitch` 32. Body line box is one pitch, title is two. Editor dots use the same pitch. Compact library steps stay 22 / 16. |
