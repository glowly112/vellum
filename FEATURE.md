# Feature
Job: Build 12 Mini sim — caption Y unchanged from 11. Remaining ~42pt band is pad, not a hit box. Lift by keyboard-only. Bump to build 13.
Non-goals: Guessed 34 / 42 / 44, putting minHeight 44 back, re-breaking gutters or tracking, merging
Touched: KeyboardChrome.writingBottomPad + hammer + pbxproj build
Reuse: Layout-guide reader, resting pad, caption (no 44), paper-full, Velin
Risk: Closed caption under the home indicator; snap if we leave the layout guide
Done: Open pad is guide minus resting. Closed pad is resting. Caption should sit on the keys. Build 13.
Not done: Mini / Simulator pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: open pad is keyboard-only; closed pad is resting
2. writingBottomPad(guide, resting) — no guessed constant
3. prove.sh — linux-hammer green
Status: keyboard-only pad this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
