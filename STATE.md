# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 7). Not Capacitor. Not App Review.
This turn: library cards swipe/long-press to pin or delete (confirm). Editor Focus keeps a visible eye. Page style opens at medium. Word-count no longer prints Night · Book — top Page style stays. Paper-full editor and ruled pitch stay. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
