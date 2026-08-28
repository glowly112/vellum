/** Hosts the bundled desk may never navigate to. Live Vercel is login-walled. */
export const BLOCKED_REMOTE_HOSTS = [
  "vellum-jamies-projects-b6f60a28.vercel.app",
] as const;

export function isBlockedNavigationHost(host: string) {
  const h = host.trim().toLowerCase().replace(/\.$/, "");
  if (!h) return false;
  if (h === "vercel.app" || h.endsWith(".vercel.app")) return true;
  return (BLOCKED_REMOTE_HOSTS as readonly string[]).includes(h);
}

export function isAllowedIosNavigationUrl(url: string) {
  let parsed: URL;
  try {
    parsed = new URL(url);
  } catch {
    return false;
  }

  if (isBlockedNavigationHost(parsed.hostname)) return false;

  const scheme = parsed.protocol.replace(/:$/, "");
  if (scheme === "capacitor" || scheme === "ionic") {
    return parsed.hostname === "localhost" || parsed.hostname === "";
  }
  if (scheme === "http" && parsed.hostname === "localhost") return true;
  if (scheme === "about" || scheme === "blob" || scheme === "data") return true;
  // Resource loads (Google Fonts) are not navigations; keep page-nav tight.
  return false;
}
