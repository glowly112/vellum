export const FONTS = [
  {
    id: "book",
    name: "Book",
    sample: "The page waits quietly.",
    className: "font-book",
  },
  {
    id: "editorial",
    name: "Editorial",
    sample: "A wider, slower sentence.",
    className: "font-display",
  },
  {
    id: "hand",
    name: "Hand",
    sample: "as if written in the margin",
    className: "font-hand",
  },
  {
    id: "typewriter",
    name: "Typewriter",
    sample: "NOTES FROM THE DESK",
    className: "font-type",
  },
  {
    id: "sans",
    name: "Sans",
    sample: "Clear, unadorned thought.",
    className: "font-ui",
  },
  {
    id: "mono",
    name: "Mono",
    sample: "draft.txt — keep going",
    className: "font-mono",
  },
] as const;

export const PAPERS = [
  {
    id: "cream",
    name: "Cream",
    ruling: "none",
    dark: false,
    surface: "bg-paper text-ink",
    muted: "text-ink-soft",
    defaultInk: "charcoal",
  },
  {
    id: "ivory",
    name: "Ivory",
    ruling: "none",
    dark: false,
    surface: "bg-paper-ivory text-ink",
    muted: "text-ink-soft",
    defaultInk: "charcoal",
  },
  {
    id: "ruled",
    name: "Ruled",
    ruling: "lines",
    dark: false,
    surface: "bg-paper-ruled text-ink",
    muted: "text-ink-soft",
    defaultInk: "navy",
  },
  {
    id: "dotted",
    name: "Dotted",
    ruling: "dots",
    dark: false,
    surface: "bg-paper-fog text-ink",
    muted: "text-ink-soft",
    defaultInk: "charcoal",
  },
  {
    id: "kraft",
    name: "Kraft",
    ruling: "none",
    dark: false,
    surface: "bg-paper-kraft text-ink",
    muted: "text-ink/70",
    defaultInk: "charcoal",
  },
  {
    id: "sage",
    name: "Sage",
    ruling: "none",
    dark: false,
    surface: "bg-paper-sage text-ink-forest",
    muted: "text-ink-forest/70",
    defaultInk: "forest",
  },
  {
    id: "fog",
    name: "Fog",
    ruling: "none",
    dark: false,
    surface: "bg-paper-fog text-ink",
    muted: "text-ink-soft",
    defaultInk: "navy",
  },
  {
    id: "night",
    name: "Night",
    ruling: "none",
    dark: true,
    surface: "bg-paper-night text-ink-cream",
    muted: "text-ink-cream/55",
    defaultInk: "cream",
  },
] as const;

export const INKS = [
  { id: "charcoal", name: "Charcoal", swatch: "bg-ink-charcoal", color: "text-ink-charcoal" },
  { id: "sepia", name: "Sepia", swatch: "bg-ink-sepia", color: "text-ink-sepia" },
  { id: "navy", name: "Navy", swatch: "bg-ink-navy", color: "text-ink-navy" },
  { id: "forest", name: "Forest", swatch: "bg-ink-forest", color: "text-ink-forest" },
  { id: "cream", name: "Cream", swatch: "bg-ink-cream", color: "text-ink-cream" },
] as const;

export const SIZES = [
  { id: "s", name: "S" },
  { id: "m", name: "M" },
  { id: "l", name: "L" },
] as const;

export type FontId = (typeof FONTS)[number]["id"];
export type PaperId = (typeof PAPERS)[number]["id"];
export type InkId = (typeof INKS)[number]["id"];
export type SizeId = (typeof SIZES)[number]["id"];

export function getFont(id: string) {
  return FONTS.find((f) => f.id === id) ?? FONTS[0];
}

export function getPaper(id: string) {
  return PAPERS.find((p) => p.id === id) ?? PAPERS[0];
}

export function getInk(id: string) {
  return INKS.find((i) => i.id === id) ?? INKS[0];
}

export function inksForPaper(paperId: string): InkId[] {
  const paper = getPaper(paperId);
  if (paper.dark) return ["cream", "sepia"];
  if (paper.id === "kraft") return ["charcoal", "sepia", "navy"];
  return ["charcoal", "sepia", "navy", "forest"];
}

export function resolveInk(paperId: string, inkId: string): InkId {
  const allowed = inksForPaper(paperId);
  if (allowed.includes(inkId as InkId)) return inkId as InkId;
  return getPaper(paperId).defaultInk as InkId;
}
