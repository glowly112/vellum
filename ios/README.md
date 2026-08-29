# Vellum Pad (native iOS)

SwiftUI app for iOS 26. Not Capacitor, not WKWebView, not a clone of the web desk chrome.

Open `ios/VellumPad/VellumPad.xcodeproj` in **Xcode 26**. Deployment target is iOS 26. Bundle ID `com.jamiematheson.vellumpad`, version `1.0.0` (5). Team `M3V2YYMTV6` is set on the target. Catalogue faces are the OFL files in `VellumPad/Fonts/`.

Prove (Mac / Xcode 26):

```bash
xcodebuild -project ios/VellumPad/VellumPad.xcodeproj -scheme VellumPad -destination 'generic/platform=iOS' -configuration Debug build
xcodebuild -project ios/VellumPad/VellumPad.xcodeproj -scheme VellumPad -destination 'platform=iOS Simulator,name=iPhone 16' test
```

This Linux worker cannot run those. `ios/scripts/prove.sh` still invokes `xcodebuild` so the exit code is recorded. Hammer: [HAMMER.md](HAMMER.md). Unwatched glare: [GLARE.md](GLARE.md). Screen map: [REFS.md](REFS.md).
