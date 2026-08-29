# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 5). Not Capacitor. Not App Review.
This turn: DEBUG-only `VELLUM_FOCUS_BODY` focuses the body TextEditor on appear so Mini can raise the keyboard without a tap. Writing column, deskPeek 6, library, chrome unchanged. PR #4 not merged. Editor is not done. `keyboardOpenProven` stays false until Mini pixels exist.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
