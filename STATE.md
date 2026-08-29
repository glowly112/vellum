# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 14, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s Mini sim of build 13 — word-count sits on the keys (~8pt air). Last line (“the page waiting.”) sat on a tall paper band above it. TextEditor was not scrolling the caret to the inset; unused field height left empty paper. Caret follows the word-count when the body is focused and the keyboard is open. Date / title / body origin unchanged. Short pages are not pinned to the bottom. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 14. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
