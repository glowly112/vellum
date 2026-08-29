# Feature
Job: Build 14 Mini sim — last line did not move. CaretFollowsWordCount never found the TextEditor. Put extra room under the body and scroll the caret to the count. Bump to build 15.
Non-goals: contentInset.top (shifts origin), pinning to the bottom, guessing 34 / 120, merging
Touched: writingColumn ScrollView + caret-floor + hug-body height + hammer + pbxproj build
Reuse: Keyboard-only pad, caption on the keys, paper-full, Velin
Risk: Nested body ScrollView; shifting date / title origin
Done: Extra room is under the body. Keyboard open + body focused scrolls the last line to the word-count. Closed stays at the locked origin. Build 15.
Not done: Mini / Simulator pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: caret room is bottom, not top; origin stays; not pinned
2. Hug the body; floor under it; scrollTo the floor when the keyboard is open
3. prove.sh — linux-hammer green
Status: caret-floor this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
