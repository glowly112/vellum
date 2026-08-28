import type { ReactNode } from "react";

export function AppFrame({ children }: { children: ReactNode }) {
  return (
    <div className="desk flex h-dvh items-stretch justify-center overflow-hidden md:items-center md:p-6">
      <div className="relative flex h-dvh w-full max-w-sm flex-col overflow-hidden md:h-[min(52.75rem,calc(100dvh-3rem))] md:rounded-3xl md:shadow-[var(--shadow-device)]">
        {children}
      </div>
    </div>
  );
}
