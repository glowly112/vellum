import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function wordCount(...parts: string[]) {
  const text = parts.join(" ").trim();
  if (!text) return 0;
  return text.split(/\s+/).length;
}

export function pageTitle(title: string, body: string) {
  const t = title.trim();
  if (t) return t;
  const line = body
    .split("\n")
    .map((l) => l.trim())
    .find(Boolean);
  return line || "Untitled page";
}

export function pagePreview(body: string) {
  return body.replace(/\s+/g, " ").trim();
}
