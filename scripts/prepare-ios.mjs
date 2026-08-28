#!/usr/bin/env node
/**
 * Build the static SPA desk and copy it into the Xcode project.
 * Never points Capacitor at a remote URL.
 */
import { spawnSync } from "node:child_process";
import { existsSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const vite = join(root, "node_modules/.bin/vite");

function run(cmd, args, extraEnv = {}) {
  const result = spawnSync(cmd, args, {
    cwd: root,
    stdio: "inherit",
    env: { ...process.env, ...extraEnv },
  });
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

run(process.execPath, [join(root, "scripts/with-app-env.mjs"), vite, "build"], {
  VELLUM_IOS: "1",
});

const indexPath = join(root, "dist/client/index.html");
if (!existsSync(indexPath)) {
  console.error("[prepare-ios] missing dist/client/index.html");
  process.exit(1);
}

let html = readFileSync(indexPath);
html = Buffer.from(html.toString("utf8").replace(/\u0000/g, ""));
let text = html.toString("utf8");
text = text
  .replace(/<link rel="manifest"[^>]*>/g, "")
  .replace(/<link rel="apple-touch-icon"[^>]*>/g, "");
if (/vercel\.app/i.test(text)) {
  console.error("[prepare-ios] built index.html mentions vercel.app — refusing to sync");
  process.exit(1);
}
writeFileSync(indexPath, text);

for (const extra of ["__grok", "ios", "og.jpg"]) {
  const path = join(root, "dist/client", extra);
  if (existsSync(path)) {
    rmSync(path, { recursive: true, force: true });
  }
}

run(join(root, "node_modules/.bin/cap"), ["sync", "ios"]);
console.log("[prepare-ios] synced dist/client → ios/App/App/public");
