# Glare — not visually proven this turn

Linux worker. No iOS Simulator. No screenshots invented. A Mini `xcodebuild` generic iOS Debug already succeeded on Jamie’s Mac (exit 0, iPhoneOS 26.5). That is not a visual pass.

**Do not call the editor done.** Writing column is in. Keyboard-open is still undone. Simulator pixels still need Jamie’s Mini.

**Editor + keyboard without a tap** (Debug only; Release ignores both flags). After a Debug install. Mini cannot tap (no assistive access). Do **not** use `simctl launch --setenv` — that errors `Invalid device`. Pass env with `SIMCTL_CHILD_*`:

```
SIMCTL_CHILD_VELLUM_OPEN_FIRST=1 SIMCTL_CHILD_VELLUM_FOCUS_BODY=1 xcrun simctl launch <UDID> com.jamiematheson.vellumpad
```

`VELLUM_OPEN_FIRST=1` pushes the first page onto the `NavigationStack`. `VELLUM_FOCUS_BODY=1` focuses the body `TextEditor` on appear so the system keyboard comes up. Do not ship either in Release (`#if DEBUG`). `keyboardOpenProven` stays false until those Mini pixels exist.

These still need a phone-width watch:

1. **KB_COVER (editor).** Word-count should sit on the keyboard / predictive bar. Caret / last line should sit just above the count. Closed: above the home indicator. Type origin stays. Gutters stay paper. Not watched here. `keyboardOpenProven` stays false.
2. **KB_COVER (style sheet).** Page sheet opens large. Typewriter and Size must scroll into view. Size last. Not watched on device.
3. **Liquid Glass.** `.toolbarBackground(.hidden)` is gone. Toolbar / search / compose / Done are system controls. Not seen on device glass.
4. **OFL faces.** Literata / Fraunces / Caveat / Special Elite / Source Sans 3 / IBM Plex Mono are bundled and registered. Rendering not seen.
5. **Focus.** Eye stays on the system toolbar and turns Focus off. Not tapped.
6. **Thumb hits.** 44pt minimum on style rows, ink, delete, word-count. Not measured.
7. **Share sheet.** `FileRepresentation` writes a `.txt`. Not presented.
8. **Delete + undo.** Press/swipe removes the sheet (spring; Reduce Motion instant). “Removed page” + Undo. Confirm is a fail. Pin / unpin should move into the Pinned section on the same spring. Focus chrome eases away / back; nav bar and paper stay. Not watched.
9. **Library sheets.** `PaperSheet` should read as a page (cream/sage/ruled, catalog face on the paper), not a Notes row. No BOOK/HAND/TYPEWRITER chip. No loud TODAY/YESTERDAY section if the card already has a when. PINNED is a desk-drawn mark (path pin + Fraunces), not SF caption caps. Empty desk: paper stamp (cream, rust margin, serif V) on the desk, then Fraunces **Empty** only — no second poetic line, not a stacked empty-state card. Greeting should be Fraunces italic. Search + compose must still be system Liquid Glass. Not watched.
10. **Editor is paper.** The whole editor is paper, edge to edge (under the toolbar, down to the word-count inset, out to the screen edges). No desk-grain frame. No rounded sheet on grain. Date / title / body origin unchanged. Closed-keyboard shot is not a pass. Not watched.
11. **Rule alignment.** Title and body baselines should sit on `PaperRuling` lines/dots (pitch 32). Cream + Book and Ruled + Typewriter. Not watched.
12. **TEXT_OVERLAP (wrap-while-typing).** Keyboard open: wrapping lines must sit below the previous line, not paint on top. Dismiss-keyboard cleaning the page is the tell (phone 20). Mini cannot inject typing (`simctl ui send-text` hangs; osascript keystroke paste is blocked). A still of the sample page is not wrap proof. Phone check of 22 is extra, not a substitute for Mini pixels. Not watched.

13. **GREETING_CLIP.** First paint of the library (empty and with pages): the full Fraunces italic greeting is visible — no slice by the status bar / Dynamic Island (phone 23). Stock large title; not a homemade draw; not a guessed 34pt pad. Extra air is `safeAreaPadding(.top)` (system default) so it does not hug the island (phone 24). Greeting + date · pages read as one block (tight title-to-subtitle, shared leading — not a 16pt extra line, not glued into descenders). Date line is a Path lockup (live Fraunces, drawn middot, tiny paper-stamp count). PINNED is a path wordmark, not SF caps. Not watched.
14. **Blank Untitled.** A page with no title and 0 words is the empty desk, not an Ivory / 0-word postcard. Not watched.
15. **Fibre / pinstripe.** EmptyDeskMark and desk have no near-vertical fibre strokes. Compact empty mark is not lined. Ruled sheets keep horizontal rules. Not watched.
16. **Dark desk.** System colorScheme: night desk (warm wood, not system gray). Greeting / Empty / meta invert. Cream/ivory/kraft/sage sheets stay those fills on the night desk. Empty mark stays a light sheet. Editor is still the page’s paper. Not watched.
17. **Light desk surface.** Library field (behind cards and empty) should read as a desk — tooth + quiet vignette — not a painted cream wall. Cards rest on it. Not Notes gray / starfield / wellness. Not watched.
18. **Bound-edge rail.** Long editor page: rust wash + cream paper thumb only while scrolling or the thumb is held; gone at rest. No system chevron-pill. Dragging the page should not glitch. Short page stays quiet. TextEditor still owns scrolling. Not watched.

Until 1–2 are watched on a phone, the production pass bar stays **false**. Phone 22 / 23 do not replace Mini pixels.
