import { cn } from "@/lib/utils";

/** Cream sheet, red margin, serif V. Decorative — name lives in sr-only nearby. */
export function Mark({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 32 32"
      className={cn("block", className)}
      aria-hidden="true"
      focusable="false"
    >
      <rect width="32" height="32" rx="6" fill="#F3EBDD" />
      <line
        x1="7.5"
        y1="5"
        x2="7.5"
        y2="27"
        stroke="#C45C4A"
        strokeWidth="1.25"
        strokeLinecap="round"
      />
      <text
        x="19.5"
        y="23"
        textAnchor="middle"
        fill="#2C2419"
        fontFamily="Fraunces, Georgia, 'Times New Roman', serif"
        fontSize="18"
        fontWeight="700"
      >
        V
      </text>
    </svg>
  );
}
