# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 11, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s Mini sim of build 10 — paper in the gutters is good. “66 words” sat on a tall paper band (44pt inset + 16pt air above the keyboard pad). Air is a few points; label sits on the keys / predictive bar. Closed stays above the home indicator. Layout-guide tracking and paper-behind-keys stay. Bundle id `com.jamiematheson.vellumpad`. Build is 11. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
