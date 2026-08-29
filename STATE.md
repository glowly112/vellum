# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 15, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s Mini sim of build 14 — last-line Y unchanged vs 13. nearestTextView() never found SwiftUI’s TextEditor, so apply() no-oped. A top inset would shift origin. Extra room is now under the body; the column scrolls so the last line sits on the word-count when the body is focused and the keyboard is open. Closed stays at the locked origin. Not pinned to the bottom. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 15. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
