# Feature
Job: Fix skill-stage fails on glowly112/vellum#3 — OFL typefaces, Liquid Glass, KB_COVER.
Non-goals: Capacitor, Vercel wrap, App Review, Simulator screenshots from Linux
Touched: Fonts/, VellumFonts, TypefaceRegistry, EditorView, StyleSheetView, Info.plist, hammer tests
Reuse: web catalogue (Literata, Fraunces, Caveat, Special Elite, Source Sans 3, IBM Plex Mono)
Risk: Linux cannot watch keyboard. Family names must match bundled TTF name tables.
Done: Faces bundled + registered. toolbarBackground hidden removed. Guessed 120pt sheet pad removed; system safeAreaPadding / safeAreaInset only.
Steps:
1. Copy OFL TTFs, register UIAppFonts + CTFontManager
2. VellumFonts.page uses family names
3. Drop hidden toolbar background; keyboard safe area only
Status: prototype — production bar false until KB_COVER is watched
Verified this turn: no Georgia/Palatino/Noteworthy stand-ins in ios/. No toolbarBackground(.hidden). No 120pt keyboard pad.
