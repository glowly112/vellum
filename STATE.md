# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 13, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s Mini sim of build 12 — same caption Y as 11. Gap ~42pt is the pad (full keyboardLayoutGuide is one home-indicator too tall). Open lift is guide minus resting. Closed stays on the resting home-indicator pad. No guessed 34 / 42 / 44. Caption is still a caption. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 13. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
