# Glare — not visually proven this turn

Linux worker. `xcodebuild` is not installed. No iOS Simulator. No screenshots invented.

These still need a phone-width pass on Xcode 26 / iPhone:

1. **KB_COVER (editor).** `TextEditor` fills the remaining column and the word-count bar is a `safeAreaInset`. That is the Notes-shaped fix. Not watched with a keyboard up.
2. **KB_COVER (style sheet).** Keyboard is dismissed before the sheet. Size is last, with extra scroll padding. Not watched with a leftover keyboard.
3. **Liquid Glass.** Toolbar / search / compose / share / Done are system controls only. Not seen on iOS 26 glass.
4. **Library list.** Rows are a paper stamp + type, not a card wall. Stamp contrast on Night / Kraft not seen.
5. **Focus.** Hides the system nav bar. Tap the top of the sheet to return. Not tapped.
6. **Thumb hits.** 44pt minimum on style rows, ink, delete, word-count, empty-state actions. System search/compose assumed 44. Not measured.
7. **Share sheet.** `FileRepresentation` writes a `.txt`. Not presented.
8. **Delete alerts.** Cancel vs confirm not tapped.

Until those are watched on a device or Simulator, the production pass bar is **false**.
