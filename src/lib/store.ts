import { create } from "zustand";
import { persist } from "zustand/middleware";
import type { FontId, InkId, PaperId, SizeId } from "./catalog";
import { resolveInk } from "./catalog";

export type Page = {
  id: string;
  title: string;
  body: string;
  createdAt: number;
  updatedAt: number;
  fontId: FontId;
  paperId: PaperId;
  inkId: InkId;
  size: SizeId;
};

export type Prefs = {
  fontId: FontId;
  paperId: PaperId;
  inkId: InkId;
  size: SizeId;
};

type WritingState = {
  pages: Page[];
  prefs: Prefs;
  createPage: () => string;
  updatePage: (id: string, patch: Partial<Pick<Page, "title" | "body">>) => void;
  setPageStyle: (
    id: string,
    patch: Partial<Pick<Page, "fontId" | "paperId" | "inkId" | "size">>,
  ) => void;
  deletePage: (id: string) => void;
  getPage: (id: string) => Page | undefined;
};

const hour = 60 * 60 * 1000;

function sampleStamp(hoursAgo: number) {
  return Math.floor(Date.now() / hour) * hour - hoursAgo * hour;
}

const SAMPLE_PAGES: Page[] = [
  {
    id: "sample-river",
    title: "Late light on the river",
    body: "The Thames is the colour of pewter this evening. I walked home with my headphones in but nothing playing — I just wanted the city a little quieter than it is.\n\nI keep meaning to write more, and then the day is gone. So here: the light on the water, the smell of rain that never quite arrived, the page waiting.",
    createdAt: sampleStamp(2),
    updatedAt: sampleStamp(2),
    fontId: "book",
    paperId: "cream",
    inkId: "charcoal",
    size: "m",
  },
  {
    id: "sample-margin",
    title: "things I noticed",
    body: "rain on warm pavement\na blank page is never actually blank\nthe way a good sentence feels before it is written\ncall mum\nleave the phone in the other room",
    createdAt: sampleStamp(26),
    updatedAt: sampleStamp(26),
    fontId: "hand",
    paperId: "sage",
    inkId: "forest",
    size: "m",
  },
  {
    id: "sample-notes",
    title: "Notes",
    body: "- send the draft before Monday\n- oat milk, lemons, too many lemons\n- do not open email after nine\n- the opening line is still wrong\n- walk at lunch",
    createdAt: sampleStamp(90),
    updatedAt: sampleStamp(90),
    fontId: "typewriter",
    paperId: "ruled",
    inkId: "navy",
    size: "s",
  },
];

const DEFAULT_PREFS: Prefs = {
  fontId: "book",
  paperId: "cream",
  inkId: "charcoal",
  size: "m",
};

export const useWritingStore = create<WritingState>()(
  persist(
    (set, get) => ({
      pages: SAMPLE_PAGES,
      prefs: DEFAULT_PREFS,
      createPage: () => {
        const id =
          typeof crypto !== "undefined" && crypto.randomUUID
            ? crypto.randomUUID()
            : `p-${Date.now()}`;
        const prefs = get().prefs;
        const page: Page = {
          id,
          title: "",
          body: "",
          createdAt: Date.now(),
          updatedAt: Date.now(),
          fontId: prefs.fontId,
          paperId: prefs.paperId,
          inkId: resolveInk(prefs.paperId, prefs.inkId),
          size: prefs.size,
        };
        set((s) => ({ pages: [page, ...s.pages] }));
        return id;
      },
      updatePage: (id, patch) => {
        set((s) => ({
          pages: s.pages.map((p) =>
            p.id === id ? { ...p, ...patch, updatedAt: Date.now() } : p,
          ),
        }));
      },
      setPageStyle: (id, patch) => {
        set((s) => {
          const current = s.pages.find((p) => p.id === id);
          if (!current) return s;
          const nextPaper = patch.paperId ?? current.paperId;
          const nextInk = resolveInk(nextPaper, patch.inkId ?? current.inkId);
          const next = {
            ...current,
            ...patch,
            paperId: nextPaper,
            inkId: nextInk,
            updatedAt: Date.now(),
          };
          return {
            pages: s.pages.map((p) => (p.id === id ? next : p)),
            prefs: {
              fontId: next.fontId,
              paperId: next.paperId,
              inkId: next.inkId,
              size: next.size,
            },
          };
        });
      },
      deletePage: (id) => {
        set((s) => ({ pages: s.pages.filter((p) => p.id !== id) }));
      },
      getPage: (id) => get().pages.find((p) => p.id === id),
    }),
    { name: "vellum-pages-v1" },
  ),
);
