# Feature
Job: Whole editor is paper. Drop the desk-grain frame (`deskPeek` 6). Type origin stays.
Non-goals: Library changes, merging PR #4, claiming keyboard-open or the editor done, shifting date / title / body
Touched: EditorLook + EditorView + hammer/linux-hammer + docs
Reuse: Writing column, word-count `safeAreaInset`, system chrome, `VELLUM_OPEN_FIRST`, `VELLUM_FOCUS_BODY`
Risk: Shifting type; putting desk grain back; calling the editor done
Done: Paper is the view background, edge to edge. `grainReveal` is `none`. Type paddings stay 24 / 56 lined / 24, date top 8.
Not done: Mini keyboard-open pixels. `keyboardOpenProven` stays false.
Steps:
1. Tests first: `paper-full`, `grainReveal == none`, `deskPeek == 0`, type origin locked, keyboard undone
2. Drop `DeskBackdrop` / rounded sheet / `deskPeek` on EditorView. `PaperBackdrop` ignores container safe area
3. prove.sh
Status: paper-full this turn. Keyboard-open and editor-done stay false.
Verified this turn: prove.sh after the paper fill.
