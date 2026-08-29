# Feature
Job: Mini 20 pixel-identical to 19 (42pt high). Phone 18 still clips. Park the live caret rect on the hairline. Bump to build 21.
Non-goals: Guessing 34 / 120, pinning at rest, merging, a 44pt caption, another pitch, moving caption/keyboard y
Touched: caretNudge(caretBottom, hairline) + CaretHairlineFollower + hammer + pbxproj build
Reuse: Caption on the keys, layout-guide pad, hug body, paper-full, Velin
Risk: First-responder hunt missing SwiftUI’s TextEditor (build 14). Fighting SwiftUI scroll.
Done: Nudge is caret bottom + air − hairline. Mini 42pt high is a top inset; phone clip is a bottom inset. Closed origin stays. Build 21.
Not done: Mini / phone pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: Mini 481/523/4 → −38; phone 533/523/4 → +14; flush 0; not 34 / 120
2. Hairline probe finds the first-responder UITextView and nudges the outer scroll view.
3. prove.sh — linux-hammer green
Status: caret-rect-on-hairline this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker. Jamie’s Mini / phone is the launch pass.
