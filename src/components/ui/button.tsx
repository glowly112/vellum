import { cva, type VariantProps } from "class-variance-authority";
import { Slot } from "@radix-ui/react-slot";
import * as React from "react";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 font-ui font-medium tracking-tight transition-[transform,background-color,color,opacity] duration-150 ease-out select-none disabled:pointer-events-none disabled:opacity-40 active:not-disabled:scale-[0.96] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent",
  {
    variants: {
      variant: {
        solid:
          "bg-ink text-paper shadow-[var(--shadow-chrome)] hover:bg-accent",
        ghost: "bg-transparent text-ink hover:bg-ink/6",
        chrome:
          "bg-paper/88 text-ink shadow-[var(--shadow-chrome)] backdrop-blur-[2px] hover:bg-paper",
        "chrome-dark":
          "bg-paper-night/70 text-ink-cream shadow-[var(--shadow-chrome)] hover:bg-paper-night/85",
        danger: "bg-transparent text-danger hover:bg-danger/8",
      },
      size: {
        md: "h-12 rounded-full px-5 text-[0.95rem]",
        icon: "size-11 rounded-full",
        pill: "h-9 rounded-full px-3.5 text-sm",
      },
    },
    defaultVariants: {
      variant: "solid",
      size: "md",
    },
  },
);

export function Button({
  className,
  variant,
  size,
  asChild = false,
  ...props
}: React.ComponentProps<"button"> &
  VariantProps<typeof buttonVariants> & { asChild?: boolean }) {
  const Comp = asChild ? Slot : "button";
  return (
    <Comp
      className={cn(buttonVariants({ variant, size }), className)}
      {...props}
    />
  );
}
