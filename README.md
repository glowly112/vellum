# Vellum

A writing app that feels like paper.

| | |
| --- | --- |
| **Code (public)** | [github.com/glowly112/vellum](https://github.com/glowly112/vellum) |
| **Brief** | [Vellum on Notion](https://app.notion.com/p/3ca2661264338157a7b9da5d8bd08d6f) |
| **Live app** | Import this repo on Vercel: [vercel.com/new](https://vercel.com/new/import?s=https://github.com/glowly112/vellum) — then turn **Deployment Protection** off so anyone can open it. |

This is a working prototype, not a notes product with accounts, sync, or folders. The point is the *feeling* of sitting down at a desk with a sheet of paper — not a document editor, not a productivity suite.

![Library](docs/library.png)

## Intention

Most writing apps are tools first: files, folders, markdown, slash commands, sync. Vellum is a **desk**. You open it, you see a small stack of pages, you write. Chrome recedes. The paper, type, ink, and size of each page are part of the writing, not a theme toggle buried in settings.

It is deliberately phone-shaped even on a laptop: a single sheet on a wooden desk, not a three-pane IDE.

### Product locks

- **Pages, not documents.** No folders, tags, or notebooks. Recency is the only organisation (Today / Yesterday / This week / Earlier).
- **Local only.** Pages live in the browser (`localStorage` key `vellum-pages-v1`). No accounts, no server, no sync. That is a choice for the prototype, not a missing feature.
- **Style belongs to the page.** Paper, typeface, ink, and size are stored per page. The last choice becomes the default for the next blank sheet.
- **Focus is a mode.** Tap Focus and the chrome fades. Tap the top of the sheet to come back.
- **Quiet chrome.** No sidebars, no toolbars of formatting, no markdown preview. Title + body. Word count lives on a thin bar at the bottom of the sheet.

### What you can do today

1. Open the library — greeting, date, search, a stack of page cards.
2. Start a new page, or tap an existing one.
3. Write a title and body. Autosaves as you type.
4. Open **Page** (type icon, or the bottom bar) and change paper / type / size / ink.
5. Tap **Focus** to hide chrome.
6. Delete a page from the style drawer (two-tap confirm).

![Editor](docs/editor.png)

![Page style](docs/styles.png)

## Stack

| Layer | Choice |
| --- | --- |
| UI | React 19 + TanStack Start / Router |
| Styling | Tailwind v4, paper textures in CSS |
| State | Zustand + `persist` (localStorage) |
| Deploy | Vercel (Nitro `vercel` preset) |
| Auth / DB | Off. Scaffolding in `src/lib/auth` and `src/lib/db` is unused. |

Node 22.

## Run it

```bash
npm install
npm run dev
```

The app listens on port 8080. Production build:

```bash
npm run build
npm run preview
```

## Where to change things

| Want | File |
| --- | --- |
| Library (home) | `src/routes/index.tsx` |
| Editor | `src/routes/write.$pageId.tsx` |
| Page cards | `src/components/library-card.tsx` |
| Paper textures | `src/components/paper-surface.tsx`, `src/styles.css` |
| Style drawer | `src/components/style-drawer.tsx` |
| Fonts, papers, inks, sizes | `src/lib/catalog.ts` |
| Pages + persistence | `src/lib/store.ts` |
| Phone-on-desk chrome | `src/components/app-frame.tsx` |
| Colour / type tokens | `src/styles.css` (`@theme`) |

Sample pages ship with the store so an empty first visit still looks like a used desk. They persist after first load; clearing site data restores them.

## Working on it

This repo is public. Fork, branch, open a pull request.

Please keep the prototype *small*. A good change makes the paper feel more like paper, or the chrome quieter. A bad change adds a sidebar, markdown toolbar, cloud sync, or a settings screen.

Suggested next slices (only if they stay in character):

- Export a page as a plain `.txt` / print-to-PDF
- Optional passcode lock (still local)
- A second sample handwriting paper
- iOS home-screen install polish

Do **not** add: folders, tags, rich text, collaboration, accounts, or a web-app sidebar.

## Status

Prototype. Built August 2026. Usable as a personal writing pad in the browser. Not a shipping product.
