import { pageTitle } from "./utils.ts";

export type ExportVia = "native" | "web-share" | "download";

type NativeSharePayload = {
  filename: string;
  text: string;
};

declare global {
  interface Window {
    webkit?: {
      messageHandlers?: {
        vellumShare?: { postMessage: (msg: NativeSharePayload) => void };
      };
    };
  }
}

export function exportFilename(title: string, body: string) {
  const raw = pageTitle(title, body)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 48);
  return `${raw || "page"}.txt`;
}

export function exportTxtContents(title: string, body: string) {
  const heading = title.trim();
  const text = body.replace(/\s+$/g, "");
  if (heading && text) return `${heading}\n\n${text}\n`;
  if (heading) return `${heading}\n`;
  return text ? `${text}\n` : "";
}

export function isNativeIosShareAvailable() {
  return Boolean(
    typeof window !== "undefined" &&
      window.webkit?.messageHandlers?.vellumShare?.postMessage,
  );
}

export async function exportPageAsTxt(
  title: string,
  body: string,
): Promise<ExportVia> {
  const filename = exportFilename(title, body);
  const text = exportTxtContents(title, body);

  if (isNativeIosShareAvailable()) {
    window.webkit!.messageHandlers!.vellumShare!.postMessage({
      filename,
      text,
    });
    return "native";
  }

  if (typeof File !== "undefined" && typeof navigator !== "undefined") {
    const file = new File([text], filename, { type: "text/plain" });
    const nav = navigator as Navigator & {
      canShare?: (data: ShareData) => boolean;
    };
    if (
      typeof nav.share === "function" &&
      (!nav.canShare || nav.canShare({ files: [file] }))
    ) {
      try {
        await nav.share({ files: [file], title: filename });
        return "web-share";
      } catch (err) {
        if (err instanceof DOMException && err.name === "AbortError") {
          throw err;
        }
      }
    }
  }

  const blob = new Blob([text], { type: "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.rel = "noopener";
  a.click();
  URL.revokeObjectURL(url);
  return "download";
}
