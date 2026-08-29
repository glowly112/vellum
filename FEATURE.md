# Feature
Job: Stop the 92% / 14pt postcard (`86453bd`). Editor is a writing column, not a library card.
Non-goals: Library changes, merging PR #4, custom chrome, web wrap, claiming the editor done
Touched: EditorLook + EditorView + hammer/linux-hammer look tests + docs
Reuse: System toolbar, StyleSheet `.sheet`, VELLUM_OPEN_FIRST, DeskBackdrop
Risk: Another fraction card (0.76 / 0.92) or full-bleed Notes; guessed 34 / 120 keyboard pads
Done: Paper fills toolbar-to-inset. Word-count is `safeAreaInset`. Grain is edge-only. Several paragraphs do not clip.
Not done: Keyboard-open on a Mini. Do not call the editor done from a closed-keyboard shot.
Steps:
1. Tests first: column-plus-inset, fills toolbar-to-inset, several paragraphs, grain edge-only, keyboard undone
2. Discard `sheetMaxHeightFraction` / `sheetHeight`. EditorView is the column + inset
3. prove.sh
Status: writing-column logic this turn. Keyboard-open and editor-done stay false.
Verified this turn: prove.sh after the column change.
