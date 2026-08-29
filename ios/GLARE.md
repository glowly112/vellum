# Glare — not visually proven this turn

Linux worker. No iOS Simulator. No screenshots invented. A Mini `xcodebuild` generic iOS Debug already succeeded on Jamie’s Mac (exit 0, iPhoneOS 26.5). That is not a visual pass.

**Do not call the editor done.** Writing-column logic ran this turn (`linux-hammer`). Keyboard-open is still undone. Simulator pixels still need Jamie’s Mini.

**Editor pixels without a tap** (Debug only; Release ignores this). After a Debug install:

```
xcrun simctl launch --setenv VELLUM_OPEN_FIRST=1 <UDID> com.jamiematheson.vellumpad
```

The library appears, then the first page is pushed onto the `NavigationStack` so `EditorView` shows immediately. Do not ship this in Release (`#if DEBUG`).

These still need a phone-width watch:

1. **KB_COVER (editor).** `TextEditor` fills the column. Word-count is a `safeAreaInset` in the **system** keyboard safe area (no 34pt / 120pt guess). Not watched with a keyboard up.
2. **KB_COVER (style sheet).** Keyboard dismissed before present. Size last. Scroll uses `.safeAreaPadding(.bottom)`. Not watched with a leftover keyboard.
3. **Liquid Glass.** `.toolbarBackground(.hidden)` is gone. Toolbar / search / compose / Done are system controls. Not seen on device glass.
4. **OFL faces.** Literata / Fraunces / Caveat / Special Elite / Source Sans 3 / IBM Plex Mono are bundled and registered. Rendering not seen.
5. **Focus.** Hides the system nav bar. Tap the top of the sheet to return. Not tapped.
6. **Thumb hits.** 44pt minimum on style rows, ink, delete, word-count. Not measured.
7. **Share sheet.** `FileRepresentation` writes a `.txt`. Not presented.
8. **Delete alerts.** Cancel vs confirm not tapped.
9. **Library sheets.** `PaperSheet` should read as a page (cream/sage/ruled, stamps, page type), not a Notes row. Greeting should be Fraunces italic. Search + compose must still be system Liquid Glass. Not watched.
10. **Editor writing column.** Paper should fill under back / share / Focus / Aa down to the word-count inset. Several paragraphs visible without clipping. Desk grain peeking at the edges only — not a 0.92 / 14pt postcard, not full-bleed Notes. Closed-keyboard shot is not a pass. Not watched.

Until 1–2 are watched on a phone, the production pass bar stays **false**.
