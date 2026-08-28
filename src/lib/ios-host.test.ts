import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, it } from "node:test";
import {
  isAllowedIosNavigationUrl,
  isBlockedNavigationHost,
} from "./ios-host.ts";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

describe("isBlockedNavigationHost", () => {
  it("blocks the live Vellum Vercel host and any vercel.app host", () => {
    assert.equal(
      isBlockedNavigationHost("vellum-jamies-projects-b6f60a28.vercel.app"),
      true,
    );
    assert.equal(isBlockedNavigationHost("something.vercel.app"), true);
    assert.equal(isBlockedNavigationHost("vercel.app"), true);
  });

  it("allows local capacitor hosts", () => {
    assert.equal(isBlockedNavigationHost("localhost"), false);
  });
});

describe("isAllowedIosNavigationUrl", () => {
  it("allows the bundled Capacitor origin only", () => {
    assert.equal(isAllowedIosNavigationUrl("capacitor://localhost/"), true);
    assert.equal(isAllowedIosNavigationUrl("capacitor://localhost/write/abc"), true);
    assert.equal(isAllowedIosNavigationUrl("about:blank"), true);
  });

  it("never allows the live Vercel URL", () => {
    assert.equal(
      isAllowedIosNavigationUrl(
        "https://vellum-jamies-projects-b6f60a28.vercel.app",
      ),
      false,
    );
    assert.equal(isAllowedIosNavigationUrl("https://example.com"), false);
  });
});

describe("iOS project locks", () => {
  it("does not set Capacitor server.url to a remote host", () => {
    const config = readFileSync(join(root, "capacitor.config.ts"), "utf8");
    assert.doesNotMatch(config, /server\s*:\s*\{[^}]*url\s*:/s);
    assert.doesNotMatch(config, /vercel\.app/);
  });

  it("keeps the Swift navigation guard pointed at the local desk", () => {
    const swift = readFileSync(
      join(root, "ios/App/App/VellumBridgeViewController.swift"),
      "utf8",
    );
    assert.match(swift, /vercel\.app/);
    assert.match(swift, /@objc public override func shouldOverrideLoad/);
    assert.match(swift, /WKNavigationActionPolicy\.cancel/);
    assert.match(swift, /vellumShare/);
    assert.doesNotMatch(swift, /vellum-jamies-projects-b6f60a28\.vercel\.app/);
  });
});
