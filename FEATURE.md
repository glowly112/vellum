# Feature
Job: Phone 18 slices the last line through the word-count. Mini 19 still 43pt high. Live keyboard guide for the caret field. Bump to build 20.
Non-goals: Guessing 34 / 120, pinning at rest, merging, a 44pt caption, another pitch, moving caption/keyboard y
Touched: caretVisibleHeight(guide) + scroll overlap + inset measure + hammer + pbxproj build
Reuse: Slack above, hug body, few-points clearance, caption on the keys, paper-full, Velin
Risk: Re-clipping on the phone. Opening a Mini-sized gap again. Shifting closed origin.
Done: Caret field is container − live layout-guide pad − measured inset. Taller phone keyboard shrinks the field. Scroll overlap is not parked under the hairline. Closed origin stays. Build 20.
Not done: Mini / phone pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: Mini-ish guide 280 → 534; phone-ish 340 → 474; no invented 44; overlap is field − visible
2. Slack and rules use caretVisibleHeight. ScrollView content margin is the overlap. Re-scroll when the guide changes.
3. prove.sh — linux-hammer green
Status: live-guide-caret-field this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker. Jamie’s Mini / phone is the launch pass.
