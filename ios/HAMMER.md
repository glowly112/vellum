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
| 6 | Keyboard cover | Editor uses `TextEditor` (not a nested `ScrollView`) so the caret stays in the keyboard safe area. Opening Page dismisses the keyboard. Style sheet last row is **Size**, with 120pt scroll padding. Fail if `KB_COVER`. |
| 7 | Delete confirm | Cancel leaves the page. Confirm deletes and pops. |
| 8 | Share `.txt` | System share sheet. Empty title → `Untitled page.txt`. |
