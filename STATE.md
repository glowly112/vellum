# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 10, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s 1.0.0 (9) clip — keyboard is edge to edge, word-count tracks, text snaps when the keys start moving. Pad follows `keyboardLayoutGuide` so text travels with the keyboard. Paper stays behind / beside the keys (not system-white). Type origin and ruled pitch unchanged. Bundle id stays `com.jamiematheson.vellumpad`. Build is 10. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
