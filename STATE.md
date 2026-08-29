# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 19, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s Mini of build 18 (`2fbd4b4`) — last ink y=1356, caption 1572, gap 72pt / 2.25 rules. Caption/keyboard y unchanged (1572 / 1620) — do not re-break writingBottomPad. `minHeight` fill left leftover under the last line; `bodyMinHeight` 280 inside `"body"` was empty paper. Slack now sits *above* the column while following. Editor hugs the measured body. Closed stays at the locked origin. Ruled type still sits on the rules. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 19. PR #4 not merged. `keyboardOpenProven` stays false on Linux. Jamie’s Mini is the launch pass.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
