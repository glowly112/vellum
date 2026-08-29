# Feature
Job: Build 18 Mini — last ink 72pt / 2.25 rules above “66 words”. Leftover still under the column. Bump to build 19.
Non-goals: Guessing 34 / 120, pinning at rest, merging, a 44pt caption, another pitch, moving caption/keyboard y
Touched: caretSlackAbove + bodyEditorHeight hug + onGeometryChange measure + hammer + pbxproj build
Reuse: Few-points clearance, scrollTo(body), caption on the keys, paper-full, Velin
Risk: Re-clipping the caret line (build 16). Filling the field when unmeasured (build 15). Shifting closed origin.
Done: Leftover sits above the column while following. Editor hugs the measured body (280 is not parked under the last line). Closed origin stays. Build 19.
Not done: Mini / Simulator pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: slack(400, 328, follow) == 72 above; floor is 0; hug measured 208; empty/unmeasured keep 280; clearance still a few points
2. Spacer above the column. TextEditor height is bodyEditorHeight. Measure via onGeometryChange.
3. prove.sh — linux-hammer green
Status: leftover-above-column this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker. Jamie’s Mini is the launch pass.
