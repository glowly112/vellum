# Feature
Job: Grow the editor sheet after Jamie rejected the 0.76 postcard as too small to write on.
Non-goals: Library changes, merging PR #4, custom chrome, web wrap
Touched: EditorLook sizes + hammer/linux-hammer look tests
Reuse: EditorView GeometryReader, system toolbar, VELLUM_OPEN_FIRST
Risk: Full-bleed Notes (fraction 1 / inset 0) or another postcard (24/40/0.76)
Done: Thin desk frame (14 / 8 / 14) and sheet at 92% of the keyboard-safe field.
Steps:
1. Tests first for majority page + thin frame (5 FAIL on 0.76/24/40)
2. Smallest pass: EditorLook 14 / 8 / 14 / 0.92
3. prove.sh
Status: logic gate this turn. Mini photographs again.
Verified this turn: prove.sh after the size change.
