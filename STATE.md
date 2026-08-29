# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 18, display name Velin). Not Capacitor. Not App Review.
This turn: Jamie’s Mini of build 17 (`8248874`) — last line ~98pt / 3 rules above “66 words”. One pitch inside `"body"` stacked on leftover slack under the column. Clearance is now a few points (word-count air), not a pitch. Slack is not parked under the last line; following fills the field so the caret line sits flush on the hairline. Closed stays at the locked origin. Ruled type still sits on the rules. Paper gutters and layout-guide tracking stay. Bundle id `com.jamiematheson.vellumpad`. Build is 18. PR #4 not merged. `keyboardOpenProven` stays false on Linux.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
