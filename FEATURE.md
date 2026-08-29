# Feature
Job: Editor sheet is an object on the desk, not a tall full-screen card with a 12pt gutter.
Non-goals: Library changes, custom back, web wrap, Release open-first
Touched: EditorLook (deskInset 24, deskBottom 40, sheetMaxHeightFraction 0.76, sheetHeight), EditorView GeometryReader
Reuse: DeskBackdrop, PaperBackdrop, system chrome, VELLUM_OPEN_FIRST
Risk: KB_COVER if sheet height ignores the keyboard-safe field. sheetHeight(inField:) uses the current field (no guessed pad).
Done: Sheet is shorter than the safe-area field. Desk shows on sides and below. Long body still scrolls inside the sheet.
Steps:
1. Failing test first: EditorLook had no isFullBleed / sheetHeight / deskBottom
2. Smallest pass: look constants + GeometryReader height, not maxHeight infinity
3. prove.sh
Status: logic gate this turn. Mini still photographs pixels.
Verified this turn: linux-hammer E1/E5 sheetHeight + KB_COVER; prove.sh.
