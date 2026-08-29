# Feature
Job: Pass-gate the library paper-sheet merge (just-works, ui-thrift, tdd-one, hammer, unlazy, verify-done).
Non-goals: Simulator pixels (Jamie’s Mini), Capacitor, WKWebView, custom + New page pill
Touched: PageLogic (LibrarySheetCopy), PaperSheet, LibraryView, HammerTests, linux-hammer, prove.sh
Reuse: PaperBackdrop, PaperGrain.seed, OFL faces, system searchable + compose
Risk: Claiming done from a plan. Test target on Linux is linux-hammer, not xcodebuild.
Done: Seven library hammer cases exist and were run this turn (0 failures). Cell is a paper-sheet. Compose stays system. Grain seed stays unsigned.
Steps:
1. Failing test first: `LibrarySheetCopy` missing (`cannot find 'LibrarySheetCopy' in scope`)
2. Smallest pass: LibrarySheetCopy + LibraryEmpty; PaperSheet reads that copy
3. Run test target: `swiftc` + linux-hammer → 0 failures
Status: logic gate passed this turn. Visual / Liquid Glass still Mini.
Verified this turn: linux-hammer exit 0 (see HAMMER.md library table). No PaperRow leftover. PaperGrain.seed unchanged.
