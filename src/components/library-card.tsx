import { Link } from "@tanstack/react-router";
import { format, isToday, isYesterday } from "date-fns";
import { PaperSurface } from "@/components/paper-surface";
import { getFont, getPaper } from "@/lib/catalog";
import type { Page } from "@/lib/store";
import { pagePreview, pageTitle, wordCount } from "@/lib/utils";

function whenLabel(ts: number) {
  const d = new Date(ts);
  if (isToday(d)) return format(d, "HH:mm");
  if (isYesterday(d)) return "Yesterday";
  return format(d, "d MMM");
}

export function LibraryCard({ page, index }: { page: Page; index: number }) {
  const paper = getPaper(page.paperId);
  const font = getFont(page.fontId);
  const title = pageTitle(page.title, page.body);
  const preview = pagePreview(page.body);
  const words = wordCount(page.title, page.body);
  const delay = Math.min(index, 5) * 50;

  return (
    <Link
      to="/write/$pageId"
      params={{ pageId: page.id }}
      className="stagger-in block rounded-xl focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent"
      style={{ animationDelay: `${delay}ms` }}
    >
      <PaperSurface
        paperId={page.paperId}
        fontId={page.fontId}
        inkId={page.inkId}
        size="s"
        compact
        className="h-44 overflow-hidden rounded-xl shadow-[var(--shadow-page)] transition-[transform,box-shadow] duration-150 ease-out active:scale-[0.96]"
      >
        <article className="flex h-44 flex-col px-5 py-4">
          <div className="flex items-baseline justify-between gap-3 font-ui text-[11px] uppercase tracking-[0.14em] text-current/45">
            <time dateTime={new Date(page.updatedAt).toISOString()} suppressHydrationWarning>
              {whenLabel(page.updatedAt)}
            </time>
            <span>{font.name}</span>
          </div>
          <h2 className="mt-3 line-clamp-2 text-[1.35rem] leading-snug tracking-tight text-pretty">
            {title}
          </h2>
          {preview && preview !== title ? (
            <p className="mt-2 line-clamp-2 text-[0.95rem] leading-relaxed text-current/85">
              {preview}
            </p>
          ) : null}
          <div className="mt-auto pt-2 font-ui text-[11px] tracking-wide text-current/40">
            {words} {words === 1 ? "word" : "words"}
            <span className="mx-1.5">·</span>
            {paper.name}
          </div>
        </article>
      </PaperSurface>
    </Link>
  );
}
