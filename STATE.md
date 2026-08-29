# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 9, display name Velin). Not Capacitor. Not App Review.
This turn: phones on 7 crash on 8 because Page gained a required `isPinned` and ModelContainer `fatalError`s. Pin is optional so a pre-pin store opens and pages stay. Home screen / App Store display name is Velin. Bundle id stays `com.jamiematheson.vellumpad`. Build is 9. Swipe pin/delete, Focus eye, Page style medium, words-only inset stay. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
