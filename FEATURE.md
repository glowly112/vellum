# Feature
Job: Build 16 phone — current line sliced by the word-count hairline. One extra body line inside the scroll target. Bump to build 17.
Non-goals: Guessing 34 / 120, pinning at rest, merging, scrolling to the floor
Touched: caretClearance(lineHeight) inside `"body"` + hammer + pbxproj build
Reuse: Slack floor, scrollTo(body), caption on the keys, paper-full, Velin
Risk: Clearance as a sibling after `"body"` (build 16 fail). A guessed pad.
Done: One ruling line of room lives inside the body target so the caret line sits fully above the divider. Closed origin stays. Build 17.
Not done: Mini / Simulator pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: clearance == body line height; sits on a rule; not 34 / 120; still scrollTo(body); unmeasured floor is 0
2. Extra Color.clear inside `.id("body")`. Height is `caretClearance(lineHeight)` only while following the caret.
3. prove.sh — linux-hammer green
Status: caret-above-hairline this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
