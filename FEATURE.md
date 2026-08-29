# Feature
Job: Steal web editor charm — sheet on the grain desk — into native iOS 26 chrome.
Non-goals: Capacitor, WKWebView, circular web back, custom T pill, hiding the nav bar
Touched: EditorView, DeskBackdrop, EditorLook / EditorSheetCopy, PaperGrain.seed(forToken:), hammer
Reuse: PaperBackdrop, system back / Focus / textformat / ShareLink / delete alert / .sheet
Risk: Full-bleed Notes page. Guessed keyboard pad (KB_COVER). UInt64(hashValue) grain.
Done: Editor is an inset rounded sheet on DeskBackdrop. Footer `N words` / `Cream · Book` sits on the paper. Focus and Page style are system toolbar items.
Steps:
1. Failing test first: `cannot find 'EditorLook' in scope`
2. Smallest pass: EditorLook + EditorSheetCopy; EditorView reads that copy
3. Run test target: prove.sh / linux-hammer
Status: logic gate this turn. Visual / KB_COVER pixels still Mini.
Verified this turn: see prove.sh output on the PR.
