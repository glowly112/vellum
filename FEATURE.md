# Feature
Job: Native iOS 26 Vellum Pad just-works pass — first tap, persist, keyboard, hammer, prove.
Non-goals: Capacitor, WKWebView, Vercel wrap, App Review, folders, markdown toolbar
Touched: ios/VellumPad (library, editor, style sheet, SwiftData, XCTest), ios/HAMMER.md, ios/GLARE.md, ios/scripts/prove.sh, README/STATE
Reuse: src/lib/catalog.ts, sample pages, recency rules
Risk: Linux worker has no xcodebuild / Simulator. KB_COVER cannot be watched here.
Done: Logic hammer in XCTest + linux-hammer. Editor is TextEditor + safeAreaInset. Style Size last. Compose debounce. Library is stamp+row, not a card wall.
Steps:
1. Extract Foundation contracts (title, seed, compose, share, delete, recency)
2. Fix editor keyboard layout and style-sheet Size row
3. Library list + 44pt hits
4. Prove: run xcodebuild (expect 127 on Linux), write glare
Status: prototype — production bar false until a Simulator/device pass
Verified this turn: xcodebuild exit 127 (command not found). No sim screenshots.
