# Feature
Job: Internal 1.0.0 (9) jank when the keyboard rises or falls. Text snaps at animation start. Keep paper filling keyboard gutters. Bump to build 10.
Non-goals: White-gutter-only theory, guessing 34 / 120, desk-frame postcard, claiming Simulator proof, merging, archiving
Touched: EditorView keyboard pad + KeyboardChrome + hammer + pbxproj build
Reuse: Paper-full editor, word-count inset, type origin 24 / 56 / 24, ruled pitch, Velin display name
Risk: Safe-area GeometryReader (jumps); paper that resizes with the keys
Done: Bottom pad follows `keyboardLayoutGuide` so text travels with the keys. Paper ignores keyboard + container (gutter fill is paper). Build 10.
Not done: Mini / Simulator pixels. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: keyboard-open gutters are paper; lift is layout-guide, not a safe-area jump
2. Ignore keyboard on the column; pad from the layout guide; paper stays behind the keys
3. prove.sh — linux-hammer green. Do not claim Simulator proof
Status: keyboard jank this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
