# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 20, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s phone of build 18 — last line sliced in half by the word-count hairline (“71 words” fully below the cut). Mini of 19 (`47e62f7`) — last ink y=1443, caption 1572, gap 43pt / 1.3 rules. Caption/keyboard y unchanged (1572 / 1620) — do not re-break writingBottomPad. Slack was using a ScrollView field that can miss a taller phone keyboard + suggestion bar. Caret field is now container − live `keyboardLayoutGuide` pad − measured inset. Closed stays at the locked origin. Ruled type still sits on the rules. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 20. PR #4 not merged. `keyboardOpenProven` stays false on Linux. Jamie’s Mini / phone is the launch pass.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
