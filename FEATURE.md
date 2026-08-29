# Feature
Job: Build 17 Mini — last line ~3 rulings above the word-count. Extra pitch stacked on leftover slack. Bump to build 18.
Non-goals: Guessing 34 / 120, pinning at rest, merging, scrolling to the floor
Touched: caretClearance (few points) + caretFloor 0 + field fill + rule offset + hammer + pbxproj build
Reuse: scrollTo(body), caption on the keys, paper-full, Velin
Risk: Re-clipping the caret line (build 16). Shifting closed origin. Type off the rules.
Done: Clearance is a few points inside the body target, not a pitch. Slack is not parked under the last line. Closed origin stays. Build 18.
Not done: Mini / Simulator pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: clearance == word-count air; not a pitch / 34 / 120; leftover + clearance < one ruling; floor is 0; fill only while following; rules travel with the column
2. Color.clear inside `.id("body")` is word-count air. Column fills the field (bottom) while following. Rules offset by the slack.
3. prove.sh — linux-hammer green
Status: caret-flush-on-hairline this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
