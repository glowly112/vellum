# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 22, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s phone video of TestFlight 20 (Night paper, keyboard open) stacked new lines into an illegible pile above the word-count. Dismissing the keyboard cleaned the text. Build 21’s caret-rect nudge (`185a48a`) is not a pass until that is gone. Per-keystroke `scrollTo("body")` / caret chase and a lagged `frame(height:)` froze TextEditor’s offset so height grew and glyphs composited on top of each other. The system editor now fills the field and scrolls. Caption stays ~8pt above the keys (do not re-break writingBottomPad). Closed stays at the locked origin. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 22. PR #4 not merged. `keyboardOpenProven` stays false on Linux. Jamie’s Mini / phone is the launch pass.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
