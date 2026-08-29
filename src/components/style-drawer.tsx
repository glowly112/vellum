import type { ReactNode } from "react";
import { Drawer } from "vaul";
import { Check } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";
import { useKeyboardOffset } from "@/lib/keyboard";
import {
  FONTS,
  PAPERS,
  SIZES,
  getInk,
  inksForPaper,
  type FontId,
  type InkId,
  type PaperId,
  type SizeId,
} from "@/lib/catalog";
import { PaperSurface } from "@/components/paper-surface";
import { Button } from "@/components/ui/button";

type StyleValue = {
  fontId: FontId;
  paperId: PaperId;
  inkId: InkId;
  size: SizeId;
};

type StyleDrawerProps = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  value: StyleValue;
  onChange: (patch: Partial<StyleValue>) => void;
  onDelete: () => void;
  dark: boolean;
};

export function StyleDrawer({
  open,
  onOpenChange,
  value,
  onChange,
  onDelete,
  dark,
}: StyleDrawerProps) {
  const allowedInks = inksForPaper(value.paperId);
  const ring = dark ? "var(--color-ink-cream)" : "var(--color-ink)";
  const [confirmDelete, setConfirmDelete] = useState(false);
  const keyboard = useKeyboardOffset();

  return (
    <Drawer.Root
      open={open}
      onOpenChange={(next) => {
        if (!next) setConfirmDelete(false);
        onOpenChange(next);
      }}
      shouldScaleBackground={false}
    >
      <Drawer.Portal>
        <Drawer.Overlay className="fixed inset-0 z-40 bg-ink/35 motion-reduce:transition-none" />
        <Drawer.Content
          className={cn(
            "fixed inset-x-0 z-50 mx-auto flex w-full max-w-sm flex-col rounded-t-2xl outline-none",
            dark ? "bg-paper-night text-ink-cream" : "bg-paper text-ink",
          )}
          style={{
            bottom: keyboard,
            maxHeight: `min(82dvh, calc(100dvh - ${keyboard}px - 12px))`,
            paddingBottom: "max(1.5rem, env(safe-area-inset-bottom, 0px))",
          }}
        >
          <div className="mx-auto mt-2.5 h-1 w-10 shrink-0 rounded-full bg-current/20" />
          <Drawer.Title className="shrink-0 px-5 pt-3 font-display text-xl tracking-tight">
            Page
          </Drawer.Title>
          <Drawer.Description className="sr-only">
            Choose paper, typeface, size, and ink
          </Drawer.Description>

          <div className="no-scrollbar mt-1 min-h-0 flex-1 overflow-y-auto px-5 pb-4">
            <Section label="Paper">
              <div className="no-scrollbar -mx-1 flex gap-2.5 overflow-x-auto px-1 pb-1">
                {PAPERS.map((p) => {
                  const selected = p.id === value.paperId;
                  return (
                    <button
                      key={p.id}
                      type="button"
                      onClick={() => onChange({ paperId: p.id })}
                      className="flex w-[4.6rem] shrink-0 flex-col items-center gap-1.5"
                    >
                      <PaperSurface
                        paperId={p.id}
                        fontId="book"
                        size="s"
                        compact
                        className={cn(
                          "h-[4.4rem] w-full overflow-hidden rounded-lg transition-[box-shadow,transform] duration-150 ease-out",
                          selected
                            ? "shadow-[0_0_0_2px_var(--color-ink)]"
                            : "shadow-[var(--shadow-page)]",
                        )}
                      >
                        <div className="px-2 pt-3">
                          <div className="font-book text-[10px] leading-tight">Aa</div>
                          <div className="mt-1 h-px w-8 bg-current/30" />
                          <div className="mt-1 h-px w-10 bg-current/20" />
                          <div className="mt-1 h-px w-6 bg-current/15" />
                        </div>
                      </PaperSurface>
                      <span
                        className={cn(
                          "font-ui text-[11px] tracking-wide",
                          selected ? "text-current" : "text-current/55",
                        )}
                      >
                        {p.name}
                      </span>
                    </button>
                  );
                })}
              </div>
            </Section>

            <Section label="Type">
              <div
                className={cn(
                  "overflow-hidden rounded-xl",
                  dark ? "bg-ink/30" : "bg-ink/4",
                )}
              >
                {FONTS.map((font) => {
                  const selected = font.id === value.fontId;
                  return (
                    <button
                      key={font.id}
                      type="button"
                      onClick={() => onChange({ fontId: font.id })}
                      className={cn(
                        "flex min-h-11 w-full items-center gap-3 px-3.5 py-2.5 text-left transition-colors duration-150",
                        selected ? "bg-current/6" : "hover:bg-current/4",
                      )}
                    >
                      <div className="min-w-0 flex-1">
                        <div className="font-ui text-[11px] uppercase tracking-[0.14em] text-current/45">
                          {font.name}
                        </div>
                        <div className={cn("truncate text-[1.15rem] leading-snug", font.className)}>
                          {font.sample}
                        </div>
                      </div>
                      {selected ? (
                        <Check className="size-4 shrink-0" strokeWidth={2.2} />
                      ) : (
                        <span className="size-4" />
                      )}
                    </button>
                  );
                })}
              </div>
            </Section>

            <Section label="Size">
              <div
                className={cn(
                  "grid grid-cols-3 gap-1 rounded-full p-1",
                  dark ? "bg-ink/30" : "bg-ink/6",
                )}
              >
                {SIZES.map((s) => {
                  const selected = s.id === value.size;
                  return (
                    <button
                      key={s.id}
                      type="button"
                      onClick={() => onChange({ size: s.id })}
                      className={cn(
                        "h-11 rounded-full font-ui text-sm transition-[background-color,color,transform] duration-150 ease-out active:scale-[0.96]",
                        selected
                          ? dark
                            ? "bg-ink-cream text-paper-night"
                            : "bg-ink text-paper"
                          : "text-current/70",
                      )}
                    >
                      {s.name}
                    </button>
                  );
                })}
              </div>
            </Section>

            <Section label="Ink">
              <div className="flex gap-3">
                {allowedInks.map((id) => {
                  const ink = getInk(id);
                  const selected = id === value.inkId;
                  return (
                    <button
                      key={id}
                      type="button"
                      aria-label={ink.name}
                      onClick={() => onChange({ inkId: id })}
                      className={cn(
                        "size-11 rounded-full transition-[box-shadow,transform] duration-150 ease-out active:scale-[0.96]",
                        ink.swatch,
                        selected
                          ? "shadow-[0_0_0_2px_var(--color-paper),0_0_0_4px_var(--ring)]"
                          : "shadow-[0_0_0_1px_rgb(44_36_25_/_0.18)]",
                      )}
                      style={{ ["--ring" as string]: ring }}
                    />
                  );
                })}
              </div>
            </Section>

            <div className="mt-6 border-t border-current/10 pt-3">
              <Button
                type="button"
                variant="danger"
                className="h-11 w-full"
                onClick={() => {
                  if (!confirmDelete) {
                    setConfirmDelete(true);
                    return;
                  }
                  onDelete();
                }}
              >
                {confirmDelete ? "Delete this page?" : "Delete page"}
              </Button>
            </div>
          </div>
        </Drawer.Content>
      </Drawer.Portal>
    </Drawer.Root>
  );
}

function Section({
  label,
  children,
}: {
  label: string;
  children: ReactNode;
}) {
  return (
    <section className="mt-5">
      <h3 className="mb-2.5 font-ui text-[11px] font-medium uppercase tracking-[0.16em] text-current/45">
        {label}
      </h3>
      {children}
    </section>
  );
}
