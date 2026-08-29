# Feature
Job: Fix Jamie’s TestFlight 1.0.0 (6) fails — rules, keyboard air, Page sheet clip. Build 7.
Non-goals: Library changes, desk-frame postcard, merging PR #4, claiming the editor done
Touched: PaperRuling + EditorView + PaperBackdrop + StyleSheetView + hammer + build 7
Reuse: Paper-full editor, word-count `safeAreaInset`, system chrome, debug flags
Risk: Guessed 34 / 120 pads; shifting library cards; calling keyboard-open proven
Done: Shared rule pitch 32 for backdrop + title/body. Word-count air when keyboard lift > 0. Page sheet opens large with scroll pad. Tests for all three.
Not done: Mini keyboard-open pixels. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests first: rule alignment, word-count above keyboard, last sheet row reachable
2. Shared `PaperRuling` token; keyboard air from system keyboard safe area; large-first detent
3. prove.sh. Bump CURRENT_PROJECT_VERSION to 7
Status: TestFlight fixes this turn. Editor-done stays false.
Verified this turn: prove.sh after the three fixes.
