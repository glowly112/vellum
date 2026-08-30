# Vellum Pad — screen map

Chrome is stock iOS 26 (Notes / Craft). Paper, type, ink, and page cards stay Vellum. Do not wrap the web app. Do not clone a second look.

| Product route | Steal chrome from | Image | Steal | Forbid |
| --- | --- | --- | --- | --- |
| Library (`LibraryView`) | [Apple Notes library](https://mobbin.com/screens/497d6ce0-454b-4f98-b8e7-15a2560b509c) | `library-notes.jpg` | Large title with air, bottom search + compose | Folders, notebooks, a white list, SF as the product face. The cell must be a paper sheet |
| Editor (`EditorView`) | [Apple Notes editor](https://mobbin.com/screens/55703012-493d-4e9a-9dca-57ccc5e92433) | `editor-notes.jpg` | `NavigationStack` back, trailing glass actions (share / more / done), keyboard-aware layout | Rich-text / table / checklist / markup toolbar. Vellum has no formatting toolbar |
| Editor paper | [Apple Notes blank ruled sheet](https://mobbin.com/screens/dc7e5d8a-f469-41cc-98c7-2aff7e58b84c) | `paper-notes.jpg` | Quiet floating chrome, keyboard-aware `TextEditor` | A cream card with a desk-grain frame, or a Notes page that lost the paper. The whole editor is paper, edge to edge. Type origin stays. |
| Page style (`.sheet`) | [Craft paper / grid picker](https://mobbin.com/screens/30f97d2c-670f-4290-a1ee-c714b4b58772) | `style-craft.jpg` | Native sheet or popover with swatches for paper / type / ink / size | Custom web drawer; Craft’s own backgrounds, grids, or Smart Align |

Product shots of the current web desk (feel, not chrome):

| Product feel | Image | Keep |
| --- | --- | --- |
| Library cards, greeting, recency | `vellum-library.png` | The page itself is the object: cream/sage/ruled sheet, title in the page’s type, snippet, one quiet when · paper line. Greeting is the one loud italic serif (Fraunces). Date line is quiet meta. No typeface chip. No loud TODAY/YESTERDAY stamp |
| Title + body on paper | `vellum-editor.png` | Writing-surface charm: cream paper, date, title, body. Native: the whole editor is that paper, edge to edge. Word-count is a bottom `safeAreaInset`. Paper · typeface is the top Page style control, not the inset. |
| Paper / type / ink / size picker | `vellum-styles.png` | Catalogue from `src/lib/catalog.ts`, visual swatches, type samples |

Attached filenames live with the brief (`refs/vellum-ios/` in the agent workspace). They are not required in the app bundle.

Empty + delete (library polish). Copy composition only. Files in `ios/refs/`.

| Product route | Steal from | Image | Steal | Forbid |
| --- | --- | --- | --- | --- |
| Empty desk / empty search | [Apple Journal empty](https://mobbin.com/screens/edd2d9ad-9dac-4851-a078-f6b1b79abf03) | `empty-chrome-journal.jpg` | Composition: mark, title, one line; compose stays in chrome | Butterfly, purple FAB, SF `doc` |
| Empty mark | [Grab drafts empty](https://mobbin.com/screens/83c0a32d-65e3-441d-9d8a-c532c338105e) | `empty-charm-paper.jpg` | Paper as the object (a small sheet / stack) | Yellow stickies, Grab type |
| Empty is paper | [Craft empty canvas](https://mobbin.com/screens/b878c0d0-a1cf-4255-a8cc-bb1ef5b02ce0) | `empty-charm-craft-paper.jpg` | Grain / ruling on the sheet, not an icon on white | Notes empty-folder art |
| Library swipe delete | Letterboxd films swipe | `delete-swipe.jpg` | System swipe reveals Delete; the row is gone | Second confirm |
| Delete undo | [Wanderlog removed note](https://mobbin.com/flows/8314e492-162e-4281-8852-84f72255f64e) | `delete-undo-snackbar.jpg` | “Removed …” + Undo | Raycast “Permanently Delete?” modal |

Type placement (library only). Copy composition — steal space, not the other product.

| Product route | Steal from | Image | Steal | Forbid |
| --- | --- | --- | --- | --- |
| Library title air | Apple Notes folders | `type-chrome-notes-title.jpg` | Large title with island air; search + compose at the bottom | White list, SF folders as the product face |
| Greeting + date | 5 Minute Journal | `type-charm-5mj-greeting.jpg` | Date as quiet small-caps meta, one serif greeting, then the page | Yellow buttons, gratitude prompts, a second serif headline |
| Card hierarchy | Alma journal | `type-charm-alma-cards.jpg` | Serif title, one quiet timestamp | Typeface stamp, category pills as chrome |
