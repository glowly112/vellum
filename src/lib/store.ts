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
    title: "Sam",
    body: "Ring back after six — number is on the fridge.",
    createdAt: sampleStamp(2),
    updatedAt: sampleStamp(2),
    fontId: "book",
    paperId: "cream",
    inkId: "charcoal",
    size: "m",
  },
  {
    id: "sample-margin",
    title: "call mum",
    body: "Sunday, if I remember. Keys are in the blue bowl.",
    createdAt: sampleStamp(26),
    updatedAt: sampleStamp(26),
    fontId: "hand",
    paperId: "sage",
    inkId: "forest",
    size: "m",
  },
  {
    id: "sample-notes",
    title: "list",
    body: "- oat milk, lemons, too many lemons\n- send the draft before Monday\n- no email after nine",
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
