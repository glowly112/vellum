# Feature
Job: Build 10 Mini sim — paper behind the keys is good. Word-count sits on a tall paper band above the keyboard. Sit it on the keys. Bump to build 11.
Non-goals: Re-breaking gutters or layout-guide tracking, guessing 34 / 120, claiming Simulator proof, merging
Touched: KeyboardAvoidance air + word-count align + column ignores keyboard + hammer + pbxproj build
Reuse: Paper-full editor, layout-guide pad, type origin, Focus eye, Velin
Risk: Second lift (pad + inset + 16pt air); label under the home indicator when the keys are down
Done: Word-count sits on the keyboard / predictive bar (few points of air). Closed stays above the home indicator. Paper still fills gutters. Build 11.
Not done: Mini / Simulator pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: air is a few points (not 16); label sits on the keys; closed pad is resting
2. Bottom-align the inset; ignore leftover keyboard safe area on the column
3. prove.sh — linux-hammer green
Status: word-count flush this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
