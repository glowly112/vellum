# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 5). Not Capacitor. Not App Review.
This turn: the whole editor is paper — edge to edge, no desk-grain frame, no rounded sheet on grain. Date / title / body origin unchanged (24 / 56 lined / 24, date top 8). Library cards on the desk stay. Debug flags stay. PR #4 not merged. Editor is not done. `keyboardOpenProven` stays false until Mini pixels exist.
Launch (Debug install):
`SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad`
Do not use `simctl launch --setenv` (Invalid device).
Production bar: logic tests on this VM. Simulator pixels still false until Jamie’s Mini. This worker has no iOS Simulator.
Live web: https://vellum-ib7s.vercel.app/
