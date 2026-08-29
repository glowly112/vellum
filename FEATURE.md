# Feature
Job: Build 11 Mini sim — “66 words” still on a ~42pt paper band. That band is the 44pt minHeight on the caption. Drop it. Bump to build 12.
Non-goals: Another air constant, re-breaking gutters or layout-guide tracking, claiming Simulator proof, merging
Touched: word-count Text frame + KeyboardChrome contract + hammer + pbxproj build
Reuse: Layout-guide pad, few points of air, paper-full, Velin
Risk: Putting 44pt back on the label; label under the home indicator when the keys are down
Done: Word-count is a caption (no minimumHit). Glyphs sit on the keys / predictive bar. Closed stays above the home indicator. Build 12.
Not done: Mini / Simulator pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: word-count is a caption; it does not use minimumHit
2. Drop minHeight 44 on the label. Do not add another constant
3. prove.sh — linux-hammer green
Status: caption flush this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
