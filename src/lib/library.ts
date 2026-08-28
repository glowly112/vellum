import type { Page } from "./store";

export type LibrarySection = "Today" | "Yesterday" | "This week" | "Earlier";

export function matchesQuery(
  page: { title: string; body: string },
  query: string,
) {
  const q = query.trim().toLowerCase();
  if (!q) return true;
  return `${page.title}\n${page.body}`.toLowerCase().includes(q);
}

export function sectionFor(ts: number, now = Date.now()): LibrarySection {
  const startOf = (ms: number) => {
    const d = new Date(ms);
    d.setHours(0, 0, 0, 0);
    return d.getTime();
  };
  const days = Math.round((startOf(now) - startOf(ts)) / 86_400_000);
  if (days <= 0) return "Today";
  if (days === 1) return "Yesterday";
  if (days < 7) return "This week";
  return "Earlier";
}

export function groupPages(pages: Page[], query: string, now = Date.now()) {
  const filtered = [...pages]
    .filter((p) => matchesQuery(p, query))
    .sort((a, b) => b.updatedAt - a.updatedAt);

  const order: LibrarySection[] = ["Today", "Yesterday", "This week", "Earlier"];
  const map = new Map<LibrarySection, Page[]>();
  for (const page of filtered) {
    const key = sectionFor(page.updatedAt, now);
    const list = map.get(key) ?? [];
    list.push(page);
    map.set(key, list);
  }
  return order
    .filter((key) => (map.get(key) ?? []).length > 0)
    .map((key) => ({ key, pages: map.get(key) ?? [] }));
}
