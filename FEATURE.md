# Feature
Job: Vellum writing pad works on a phone — first tap path, keyboard does not cover caret or sheet actions, empty/error designed, library cards do not eat preview text, still feels like paper on a desk.
Non-goals: folders, accounts, export, extra papers, redesign, sync, sidebars
Touched: library cards, editor, style drawer, keyboard inset, empty/missing states, app frame
Reuse: glowly112/vellum (catalog, store, paper textures, routes)
Risk: visualViewport vs 100vh; ruled overlay on cards; drawer last section under keyboard; Vercel login wall is out of this preview
Done: Phone-width (~390): open library, new page, type with keyboard up, caret and word-count/actions visible; style sheet last section reachable; empty search is a sentence + way back; missing page is a sentence + way back; card previews readable
Steps:
1. Bring Vellum into this preview (keep grok shell)
2. Fix library card ruling overlay
3. Pin composer/sheet to visualViewport; scroll focused line into view
4. Empty search + missing page
5. Thumb targets, inputmode, safe area
6. Hammer + verify on phone-width this turn
Status: accepted
Verified this turn: phone-width library, empty search, missing page, type-on-page, style sheet last action, keyboard inset (barBottom 512 ≤ usable 524 with 320px keyboard).
