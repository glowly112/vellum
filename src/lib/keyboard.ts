import { useEffect, useState } from "react";

export function keyboardInset(
  innerHeight: number,
  visualViewportHeight: number,
  visualViewportOffsetTop: number,
) {
  return Math.max(
    0,
    Math.round(innerHeight - visualViewportHeight - visualViewportOffsetTop),
  );
}

export function useKeyboardOffset() {
  const [offset, setOffset] = useState(0);

  useEffect(() => {
    const vv = window.visualViewport;
    if (!vv) return;

    const sync = () => {
      setOffset(keyboardInset(window.innerHeight, vv.height, vv.offsetTop));
    };

    sync();
    vv.addEventListener("resize", sync);
    vv.addEventListener("scroll", sync);
    return () => {
      vv.removeEventListener("resize", sync);
      vv.removeEventListener("scroll", sync);
    };
  }, []);

  return offset;
}

export function scrollFocusedIntoView() {
  const el = document.activeElement;
  if (!(el instanceof HTMLElement)) return;
  if (el.tagName !== "TEXTAREA" && el.tagName !== "INPUT") return;
  el.scrollIntoView({ block: "nearest", inline: "nearest" });
}
