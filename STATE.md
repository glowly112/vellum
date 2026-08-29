# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 17, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s phone of build 16 (Night, keyboard open) — last line cut through the glyphs by the word-count hairline. `scrollTo("body")` parked the body on the inset; clearance after that id was ignored. One body line now lives *inside* the body target so the caret line sits fully above the divider. Closed stays at the locked origin. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 17. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
