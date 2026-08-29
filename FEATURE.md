# Feature
Job: Debug-only `VELLUM_OPEN_FIRST=1` so Mini can launch straight into EditorView without a tap.
Non-goals: Release shipping, layout change, web wrap, custom chrome
Touched: DebugOpenFirst, LibraryView (`#if DEBUG`), GLARE.md, hammer
Reuse: existing NavigationStack path, first `@Query` page
Risk: Opening the editor in Release. Guard is `#if DEBUG` + `debugBuild == false` ignores env.
Done: Env flag pushes the first page after the library appears. Documented simctl one-liner.
Steps:
1. Failing test first: `cannot find 'DebugOpenFirst' in scope`
2. Smallest pass: DebugOpenFirst helper + LibraryView `#if DEBUG` onAppear
3. Run prove.sh
Status: logic gate this turn. Editor pixels still Mini (now launchable without a tap).
Verified this turn: linux-hammer DebugOpenFirst cases + prove.sh.
