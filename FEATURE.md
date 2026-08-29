# Feature
Job: 1.0.0 (8) crashes on phones that already had 7. Jamie also expected the home-screen name Velin. Fix the store and the display name on PR #4. Bump to build 9.
Non-goals: Wiping pages, changing the bundle id, store listing, web, claiming Simulator proof
Touched: Page.isPinned → optional + PageStoreOpen + pbxproj display name / build + hammer
Reuse: Swipe pin/delete, Focus eye, Page style medium, words-only inset, paper sheets
Risk: In-memory fallback that hides the desk; VersionedSchema that cannot open an unversioned store
Done: Optional pin so a build-7 `vellum-pages` row opens and stays. Display name Velin. Build 9. Pre-pin store test fails on required Bool, passes on optional.
Not done: Mini / Simulator pixels. `keyboardOpenProven` stays false on Linux.
Steps:
1. Test that a pre-pin store (no isPinned) opens and keeps the page
2. Store pin as optional Bool (nil → unpinned). Display name Velin. Build 9
3. prove.sh — linux-hammer green. Do not claim Simulator proof
Status: crash + name this turn. Editor-done stays false.
Verified this turn: linux-hammer. No Simulator on this worker.
