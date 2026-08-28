import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { format, isToday, isYesterday, differenceInCalendarDays } from "date-fns";
import { Plus, Search } from "lucide-react";
import { useMemo, useState } from "react";
import { LibraryCard } from "@/components/library-card";
import { Button } from "@/components/ui/button";
import { useWritingStore, type Page } from "@/lib/store";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/")({ component: Library });

function greeting() {
  const h = new Date().getHours();
  if (h < 12) return "Good morning";
  if (h < 18) return "Good afternoon";
  return "Good evening";
}

function sectionFor(ts: number) {
  const d = new Date(ts);
  if (isToday(d)) return "Today";
  if (isYesterday(d)) return "Yesterday";
  if (differenceInCalendarDays(new Date(), d) < 7) return "This week";
  return "Earlier";
}

function Library() {
  const navigate = useNavigate();
  const pages = useWritingStore((s) => s.pages);
  const createPage = useWritingStore((s) => s.createPage);
  const [query, setQuery] = useState("");

  const grouped = useMemo(() => {
    const q = query.trim().toLowerCase();
    const filtered = [...pages]
      .filter((p) => {
        if (!q) return true;
        return `${p.title}\n${p.body}`.toLowerCase().includes(q);
      })
      .sort((a, b) => b.updatedAt - a.updatedAt);

    const order = ["Today", "Yesterday", "This week", "Earlier"] as const;
    const map = new Map<string, Page[]>();
    for (const page of filtered) {
      const key = sectionFor(page.updatedAt);
      const list = map.get(key) ?? [];
      list.push(page);
      map.set(key, list);
    }
    return order
      .filter((key) => (map.get(key) ?? []).length > 0)
      .map((key) => ({ key, pages: map.get(key) ?? [] }));
  }, [pages, query]);

  const startPage = () => {
    const id = createPage();
    navigate({ to: "/write/$pageId", params: { pageId: id } });
  };

  return (
    <div className="flex h-full min-h-0 flex-col bg-desk text-ink">
      <main className="min-h-0 flex-1 overflow-y-auto overscroll-y-contain">
        <header className="pt-safe px-5">
          <p
            className="font-ui text-[11px] font-medium uppercase tracking-[0.18em] text-ink-soft"
            suppressHydrationWarning
          >
            {format(new Date(), "EEEE d MMMM")}
          </p>
          <h1
            className="mt-1 font-display text-[2.15rem] leading-none tracking-tight italic"
            suppressHydrationWarning
          >
            {greeting()}
          </h1>
          <p className="mt-2 font-display text-lg text-ink-soft">Vellum</p>

          <label className="relative mt-5 block">
            <span className="sr-only">Search pages</span>
            <Search
              className="pointer-events-none absolute top-1/2 left-3.5 size-4 -translate-y-1/2 text-ink-faint"
              strokeWidth={1.75}
            />
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search pages"
              suppressHydrationWarning
              className="h-11 w-full rounded-full bg-paper/80 pr-4 pl-10 font-ui text-base text-ink shadow-[var(--shadow-page)] placeholder:text-ink-faint focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent"
            />
          </label>
        </header>

        <div className="px-5 pt-6 pb-6">
          {grouped.length === 0 ? (
            <EmptyState query={query} onCreate={startPage} />
          ) : (
            <div className="space-y-7">
              {grouped.map((group) => (
                <section key={group.key}>
                  <h2 className="mb-3 font-ui text-[11px] font-medium uppercase tracking-[0.16em] text-ink-soft">
                    {group.key}
                  </h2>
                  <div className="space-y-3">
                    {group.pages.map((page, i) => (
                      <LibraryCard key={page.id} page={page} index={i} />
                    ))}
                  </div>
                </section>
              ))}
            </div>
          )}
        </div>
      </main>

      <div className="shrink-0 border-t border-ink/8 bg-desk px-5 pt-3 pb-safe">
        <Button type="button" className="w-full" onClick={startPage}>
          <Plus className="size-4" strokeWidth={2.2} />
          New page
        </Button>
      </div>
    </div>
  );
}

function EmptyState({ query, onCreate }: { query: string; onCreate: () => void }) {
  return (
    <div className={cn("flex flex-col items-center px-6 pt-16 text-center")}>
      <div className="h-36 w-28 rounded-sm bg-paper shadow-[var(--shadow-page)]" />
      <p className="mt-6 font-display text-2xl tracking-tight">
        {query ? "Nothing matches" : "The desk is clear"}
      </p>
      <p className="mt-2 max-w-xs font-ui text-sm leading-relaxed text-ink-soft">
        {query
          ? "Try a different word, or start a new page."
          : "A blank sheet, waiting. Start whenever you like."}
      </p>
      {!query ? (
        <Button type="button" className="mt-6" onClick={onCreate}>
          Start a page
        </Button>
      ) : null}
    </div>
  );
}
