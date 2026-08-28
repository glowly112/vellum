import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { ChevronLeft, Type } from "lucide-react";
import { useEffect, useLayoutEffect, useRef, useState } from "react";
import { format } from "date-fns";
import { PaperSurface } from "@/components/paper-surface";
import { StyleDrawer } from "@/components/style-drawer";
import { Button } from "@/components/ui/button";
import { getFont, getPaper } from "@/lib/catalog";
import { scrollFocusedIntoView, useKeyboardOffset } from "@/lib/keyboard";
import { useMounted } from "@/lib/hooks";
import { exportPageAsTxt } from "@/lib/export-page";
import { useWritingStore } from "@/lib/store";
import { cn, wordCount } from "@/lib/utils";

export const Route = createFileRoute("/write/$pageId")({
  component: WritePage,
});

function WritePage() {
  const { pageId } = Route.useParams();
  const navigate = useNavigate();
  const mounted = useMounted();
  const page = useWritingStore((s) => s.pages.find((p) => p.id === pageId));
  const updatePage = useWritingStore((s) => s.updatePage);
  const setPageStyle = useWritingStore((s) => s.setPageStyle);
  const deletePage = useWritingStore((s) => s.deletePage);
  const [stylesOpen, setStylesOpen] = useState(false);
  const [focus, setFocus] = useState(false);
  const keyboard = useKeyboardOffset();
  const bodyRef = useRef<HTMLTextAreaElement>(null);

  useLayoutEffect(() => {
    const el = bodyRef.current;
    if (!el) return;
    el.style.height = "auto";
    el.style.height = `${Math.max(el.scrollHeight, 240)}px`;
  }, [page?.body, page?.size, page?.fontId]);

  useEffect(() => {
    const vv = window.visualViewport;
    if (!vv) return;
    const sync = () => scrollFocusedIntoView();
    vv.addEventListener("resize", sync);
    return () => vv.removeEventListener("resize", sync);
  }, []);

  const goHome = () => navigate({ to: "/" });

  if (!mounted) {
    return <div className="h-full min-h-0 bg-paper" />;
  }

  if (!page) {
    return (
      <div className="flex h-full min-h-0 flex-col bg-paper px-5 pt-safe text-ink">
        <Button
          type="button"
          variant="chrome"
          size="icon"
          aria-label="Back to pages"
          onClick={goHome}
        >
          <ChevronLeft className="size-5" strokeWidth={1.75} />
        </Button>
        <div className="flex flex-1 flex-col items-center justify-center px-6 pb-16 text-center">
          <p className="font-display text-2xl tracking-tight">This page isn't here</p>
          <p className="mt-2 max-w-xs font-ui text-sm leading-relaxed text-ink-soft">
            It may have been deleted, or the link is old.
          </p>
          <Button type="button" className="mt-6" onClick={goHome}>
            Back to pages
          </Button>
        </div>
      </div>
    );
  }

  const paper = getPaper(page.paperId);
  const font = getFont(page.fontId);
  const words = wordCount(page.title, page.body);
  const chrome = paper.dark ? "chrome-dark" : "chrome";
  const padX = paper.ruling === "lines" ? "pl-14 pr-6" : "px-6";

  const handleDelete = () => {
    setStylesOpen(false);
    deletePage(page.id);
    navigate({ to: "/" });
  };

  return (
    <main
      className={cn("relative flex h-full min-h-0 flex-col", paper.surface)}
      style={{ paddingBottom: keyboard }}
    >
      <PaperSurface
        paperId={page.paperId}
        fontId={page.fontId}
        inkId={page.inkId}
        size={page.size}
        className="flex min-h-0 flex-1 flex-col overflow-hidden"
        ruledOffset="7.5rem"
      >
        <div
          className={cn(
            "pointer-events-none relative z-20 flex shrink-0 items-center justify-between px-3 pt-safe pb-2 transition-opacity duration-200 ease-out",
            focus ? "opacity-0" : "opacity-100",
          )}
        >
          <Button
            type="button"
            variant={chrome}
            size="icon"
            className="pointer-events-auto"
            aria-label="Back to pages"
            onClick={goHome}
            tabIndex={focus ? -1 : 0}
          >
            <ChevronLeft className="size-5" strokeWidth={1.75} />
          </Button>
          <div className="pointer-events-auto flex items-center gap-2">
            <Button
              type="button"
              variant={chrome}
              size="pill"
              className="h-11 font-ui text-[12px] tracking-wide"
              onClick={() => setFocus(true)}
            >
              Focus
            </Button>
            <Button
              type="button"
              variant={chrome}
              size="icon"
              aria-label="Page style"
              onClick={() => setStylesOpen(true)}
            >
              <Type className="size-4" strokeWidth={1.8} />
            </Button>
          </div>
        </div>

        {focus ? (
          <button
            type="button"
            aria-label="Exit focus"
            className="absolute inset-x-0 top-0 z-20 h-16"
            onClick={() => setFocus(false)}
          />
        ) : null}

        <div
          className={cn("min-h-0 flex-1 overflow-y-auto overscroll-y-contain pt-2 pb-4", padX)}
        >
          <p className="font-ui text-[11px] uppercase tracking-[0.16em] text-current/40">
            {format(new Date(page.createdAt), "EEEE d MMMM")}
          </p>
          <input
            value={page.title}
            onChange={(e) => updatePage(page.id, { title: e.target.value })}
            onFocus={() => scrollFocusedIntoView()}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                e.preventDefault();
                bodyRef.current?.focus();
              }
            }}
            placeholder="Title"
            enterKeyHint="next"
            autoCapitalize="sentences"
            className="write-title mt-3"
            aria-label="Title"
            suppressHydrationWarning
          />
          <textarea
            ref={bodyRef}
            value={page.body}
            onChange={(e) => updatePage(page.id, { body: e.target.value })}
            onFocus={() => scrollFocusedIntoView()}
            placeholder="Begin writing…"
            enterKeyHint="enter"
            autoCapitalize="sentences"
            className="write-body mt-4 min-h-[40vh]"
            aria-label="Page body"
            rows={8}
            suppressHydrationWarning
          />
        </div>

        <div
          className={cn(
            "shrink-0 px-4 pb-3 transition-opacity duration-200 ease-out",
            focus ? "pointer-events-none opacity-0" : "opacity-100",
          )}
        >
          <button
            type="button"
            onClick={() => setStylesOpen(true)}
            className={cn(
              "flex h-11 w-full items-center justify-between rounded-full px-4 font-ui text-xs tracking-wide shadow-[var(--shadow-chrome)]",
              paper.dark
                ? "bg-paper-night/80 text-ink-cream"
                : "bg-paper/90 text-ink-soft",
            )}
          >
            <span className="tabular-nums">
              {words} {words === 1 ? "word" : "words"}
            </span>
            <span>
              {paper.name}
              <span className="mx-1.5 text-current/40">·</span>
              {font.name}
            </span>
          </button>
        </div>
      </PaperSurface>

      <StyleDrawer
        open={stylesOpen}
        onOpenChange={setStylesOpen}
        value={{
          fontId: page.fontId,
          paperId: page.paperId,
          inkId: page.inkId,
          size: page.size,
        }}
        onChange={(patch) => setPageStyle(page.id, patch)}
        onDelete={handleDelete}
        onExport={() => {
          setStylesOpen(false);
          void exportPageAsTxt(page.title, page.body);
        }}
        dark={paper.dark}
      />
    </main>
  );
}
