# Feature
Job: Build 15 Mini sim — last line clipped under the title, ~308pt paper band to the count. scrollTo(floor) was wrong. Park the body on the inset. Bump to build 16.
Non-goals: Guessing 34 / 120, pinning at rest, merging
Touched: caretFloor(visible, column) + scrollTo(body) + unconstrained body measure + hammer + pbxproj build
Reuse: Keyboard-only pad, caption on the keys, paper-full, Velin
Risk: Clipping the body to one line; a floor that fills the field
Done: Floor is slack under the measured column (0 if unmeasured). Scroll parks the body, not the floor. Closed origin stays. Build 16.
Not done: Mini / Simulator pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: floor is visible − column; unmeasured → 0; target is body, not floor
2. Measure body beside the editor (not inside a 32pt frame). scrollTo("body")
3. prove.sh — linux-hammer green
Status: body-on-inset this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
