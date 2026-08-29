# STATE
Shipped: web desk on Vercel. Native SwiftUI project in ios/VellumPad (1.0.0 build 3). Not Capacitor. Not App Review.
This turn: just-works pass on the native target — TextEditor keyboard layout, Size-last style sheet, compose debounce, stamp+row library, XCTest hammer, glare list.
Production bar: false. Proving command `xcodebuild -project ios/VellumPad/VellumPad.xcodeproj -scheme VellumPad -destination 'generic/platform=iOS' -configuration Debug build` exited 127 on this Linux worker (xcodebuild not found). No Simulator. Do not treat a plan as a ship.
Live web: https://vellum-ib7s.vercel.app/
