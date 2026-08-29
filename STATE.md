# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 16, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s Mini sim of build 15 — first paragraph gone, last fragment under the title, ~308pt paper to the count. `caretScrollPad(visible − line)` plus `scrollTo(floor)` parked empty paper on the keys and clipped the body. Floor is now slack under the measured column. Scroll parks the body on the inset. Unmeasured column does not fill the field. Closed stays at the locked origin. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 16. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
