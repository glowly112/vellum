# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 21, display name Velin). Not Capacitor. Not App Review.
This turn: Mini of 20 (`7d3cdd6`) was pixel-identical to 19 — last_ink y=1443, caption 1570, gap 42pt. Live-guide field was a no-op. Phone 18 still slices the last line under the hairline. Field-size / scrollTo("body") cannot move the caret line. Nudge is the live UITextInput caret bottom plus a few points minus the hairline. Caption/keyboard y unchanged (1570 / 1620) — do not re-break writingBottomPad. Closed stays at the locked origin. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 21. PR #4 not merged. `keyboardOpenProven` stays false on Linux. Jamie’s Mini / phone is the launch pass.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
