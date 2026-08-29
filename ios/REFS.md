# Vellum Pad — screen map

Chrome is stock iOS 26 (Notes / Craft). Paper, type, ink, and page cards stay Vellum. Do not wrap the web app. Do not clone a second look.

| Product route | Steal chrome from | Image | Steal | Forbid |
| --- | --- | --- | --- | --- |
| Library (`LibraryView`) | [Apple Notes library](https://mobbin.com/screens/497d6ce0-454b-4f98-b8e7-15a2560b509c) | `library-notes.jpg` | Large title, recency groups, glass circular bar buttons, bottom search + compose | Folders, notebooks, a Notes thumbnail+row. The cell must be a paper sheet (colour, ruling, type, word count) |
| Editor (`EditorView`) | [Apple Notes editor](https://mobbin.com/screens/55703012-493d-4e9a-9dca-57ccc5e92433) | `editor-notes.jpg` | `NavigationStack` back, trailing glass actions (share / more / done), keyboard-aware layout | Rich-text / table / checklist / markup toolbar. Vellum has no formatting toolbar |
| Editor paper | [Apple Notes blank ruled sheet](https://mobbin.com/screens/dc7e5d8a-f469-41cc-98c7-2aff7e58b84c) | `paper-notes.jpg` | Full-bleed paper, quiet floating chrome | Heavy solid bars; a wooden desk frame (web-only) |
| Page style (`.sheet`) | [Craft paper / grid picker](https://mobbin.com/screens/30f97d2c-670f-4290-a1ee-c714b4b58772) | `style-craft.jpg` | Native sheet or popover with swatches for paper / type / ink / size | Custom web drawer; Craft’s own backgrounds, grids, or Smart Align |

Product shots of the current web desk (feel, not chrome):

| Product feel | Image | Keep |
| --- | --- | --- |
| Library cards, greeting, recency | `vellum-library.png` | The page itself is the object: cream/sage/ruled sheet, time + face stamp, title in the page’s type, snippet, word count. Greeting is a loud italic serif (Fraunces). Recency: Today / Yesterday / This week / Earlier |
| Title + body on paper | `vellum-editor.png` | Cream / ivory / ruled / etc. sheet, serif title, thin word-count bar |
| Paper / type / ink / size picker | `vellum-styles.png` | Catalogue from `src/lib/catalog.ts`, visual swatches, type samples |

Attached filenames live with the brief (`refs/vellum-ios/` in the agent workspace). They are not required in the app bundle.
