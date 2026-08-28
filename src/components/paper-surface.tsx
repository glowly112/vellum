import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import { getFont, getInk, getPaper, type FontId, type InkId, type PaperId, type SizeId } from "@/lib/catalog";

type PaperSurfaceProps = {
  paperId: PaperId | string;
  fontId?: FontId | string;
  inkId?: InkId | string;
  size?: SizeId | string;
  className?: string;
  children: ReactNode;
  ruledOffset?: string;
  compact?: boolean;
};

export function PaperSurface({
  paperId,
  fontId = "book",
  inkId,
  size = "m",
  className,
  children,
  ruledOffset,
  compact = false,
}: PaperSurfaceProps) {
  const paper = getPaper(paperId);
  const font = getFont(fontId);
  const ink = getInk(inkId ?? paper.defaultInk);

  return (
    <div
      className={cn(
        "paper-sheet",
        compact ? "paper-sheet-compact" : "paper-gutter",
        paper.surface,
        font.className,
        ink.color,
        className,
      )}
      data-paper={paper.id}
      data-font={font.id}
      data-size={size}
      style={ruledOffset ? { ["--rule-offset" as string]: ruledOffset } : undefined}
    >
      <div className="paper-fiber" aria-hidden />
      {paper.ruling === "lines" ? (
        <>
          <div className="paper-rules" aria-hidden />
          {compact ? null : <div className="paper-margin" aria-hidden />}
        </>
      ) : null}
      {paper.ruling === "dots" ? <div className="paper-dots" aria-hidden /> : null}
      <div className="relative z-10 flex h-full min-h-0 flex-col">{children}</div>
    </div>
  );
}
