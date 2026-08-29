# Feature
Job: Four chrome fixes Jamie asked for after using the native pad — library delete/pin, drop Night · Book on the word-count, Focus eye stays, Page style opens half.
Non-goals: Renaming the app, store listing, web, desk-frame postcard, claiming the editor done
Touched: LibraryView + LibraryGrouping + Page.isPinned + EditorView chrome + hammer
Reuse: Paper sheets, paper-full editor, word-count inset, system toolbar, Page style sheet
Risk: Notes-clone chrome; hiding the eye again; opening the style sheet at large
Done: Swipe + context menu delete (confirm) and pin with a Pinned section. Word-count is words only. Focus keeps a tappable eye. Style sheet starts at medium and still scrolls.
Not done: Mini keyboard-open pixels. `keyboardOpenProven` stays false on Linux.
Steps:
1. Tests first: focus eye stays, sheet starts medium, library delete/pin, footer has no paper · typeface
2. Implement swipe/menu + stored pin, keep nav bar in Focus, detent medium, inset words only
3. prove.sh
Status: chrome this turn. Editor-done stays false.
Verified this turn: prove.sh after the four fixes.
