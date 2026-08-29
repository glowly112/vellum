# Feature
Job: Phone 20 video — glyphs stack above the word-count while the keyboard is open. Remove the per-keystroke park. Let the system TextEditor scroll. Bump to build 22.
Non-goals: Guessing 34 / 120, pinning at rest, merging, a 44pt caption, another ruling, moving caption/keyboard y, shifting type origin
Touched: EditorView writing column + KeyboardChrome flags + hammer + pbxproj build
Reuse: Caption on the keys, layout-guide pad, paper-full, Velin
Risk: Last-line flush is secondary. Lined rules stay viewport-fixed while the body scrolls.
Done: No scrollTo / caret-rect chase. No lagged measure height. TextEditor fills the field. Closed origin stays. Build 22.
Not done: Mini / phone pixels on this worker. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests: follow / per-keystroke / caret-rect / measured-height cap are off; target is system
2. Writing column is date + title + a filling TextEditor. Word-count stays on the live guide.
3. prove.sh — linux-hammer green
Status: system-editor-scrolls this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker. Jamie’s Mini / phone is the launch pass.
