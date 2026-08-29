# Feature
Job: Build 13 Mini sim — word-count is on the keys. Tall paper band between the last line and the caption. Caret / last line should sit just above the count. Bump to build 14.
Non-goals: Shifting type origin, pinning the page to the bottom, guessing 34 / 120, merging
Touched: CaretFollowsWordCount + KeyboardChrome.caretScrollPad + hammer + pbxproj build
Reuse: Keyboard-only pad, caption on the keys, paper-full, layout-guide, Velin
Risk: Pinning short pages to the bottom; moving date / title / body origin
Done: When the body is focused and the keyboard is open, the caret line sits on the word-count. Short pages still start at the locked origin. Build 14.
Not done: Mini / Simulator pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: caret follows word-count; page is not pinned to the bottom; origin 24 / 8
2. TextEditor scroll room is visible height minus one line. Scroll the caret there.
3. prove.sh — linux-hammer green
Status: caret-to-count this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
