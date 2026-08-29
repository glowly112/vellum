# Feature
Job: DEBUG-only `VELLUM_FOCUS_BODY=1` so Mini can raise the system keyboard without a tap.
Non-goals: Library changes, merging PR #4, claiming keyboard-open or the editor done, changing the writing column
Touched: DebugFocusBody + EditorView onAppear + hammer/linux-hammer + launch docs
Reuse: DebugOpenFirst gate, writing column, deskPeek 6, system chrome
Risk: Shipping the flag in Release; `simctl launch --setenv` (Invalid device)
Done: DEBUG true + flag focuses the body `TextEditor`. Release never focuses.
Not done: Mini keyboard-open pixels. `keyboardOpenProven` stays false.
Steps:
1. Tests first: DEBUG + flag focuses body; release never focuses; keyboardOpenProven false
2. Same `#if DEBUG` + env gate as `VELLUM_OPEN_FIRST`. EditorView focuses `.body` on appear
3. prove.sh. Docs use `SIMCTL_CHILD_*`, not `--setenv`
Status: launch flag this turn. Keyboard-open and editor-done stay false.
Verified this turn: prove.sh after the flag.
