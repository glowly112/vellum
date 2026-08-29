# Feature
Job: Merge web-desk paper-sheet charm into the native iOS 26 library chrome.
Non-goals: Capacitor, WKWebView, wrapping the web app, custom brown “+ New page” pill, hiding nav/search
Touched: LibraryView, PaperCard (PaperSheet), VellumFonts.display, LibraryLook, hammer tests
Reuse: PaperBackdrop, PaperGrain.seed, bundled OFL faces, system .searchable + compose
Risk: UINavigationBarAppearance would flatten Liquid Glass; large title type is a ToolbarItem. Grain must stay PaperGrain.seed (unsigned).
Done: Library cells are cream/sage/ruled sheets (time + face stamp, page type, snippet, word count). Greeting is Fraunces italic. Search + compose stay system.
Steps:
1. Replace PaperRow thumbnail+Notes row with PaperSheet on PaperBackdrop
2. Style large title via ToolbarItem(.largeTitle) + VellumFonts.display (Fraunces italic)
3. Leave editor as-is; keep compose / searchable / recency sections
Status: prototype — production bar false until a phone watches the library
Verified this turn: PaperRow/PaperStamp gone; PaperSheet uses PaperBackdrop + PaperGrain.seed; compose is still system searchable + square.and.pencil. linux-hammer/xcodebuild absent on this Linux worker (no swiftc).
