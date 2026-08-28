import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { groupPages, matchesQuery } from "./library.ts";
import type { Page } from "./store.ts";

const now = Date.parse("2026-08-28T21:00:00Z");

function page(partial: Partial<Page> & { id: string; title: string; body: string }): Page {
  return {
    createdAt: now,
    updatedAt: now,
    fontId: "book",
    paperId: "cream",
    inkId: "charcoal",
    size: "m",
    ...partial,
  };
}

describe("matchesQuery", () => {
  it("empty query matches every page", () => {
    assert.equal(matchesQuery({ title: "River", body: "Thames" }, ""), true);
    assert.equal(matchesQuery({ title: "River", body: "Thames" }, "   "), true);
  });

  it("matches title or body, case-insensitive", () => {
    const p = { title: "Late light", body: "The Thames is pewter" };
    assert.equal(matchesQuery(p, "thames"), true);
    assert.equal(matchesQuery(p, "LIGHT"), true);
    assert.equal(matchesQuery(p, "zebra"), false);
  });
});

describe("groupPages", () => {
  it("returns no groups when nothing matches — empty search", () => {
    const pages = [page({ id: "1", title: "River", body: "water", updatedAt: now })];
    assert.deepEqual(groupPages(pages, "zebra", now), []);
  });

  it("keeps recency buckets for a matching page", () => {
    const pages = [
      page({ id: "today", title: "Now", body: "desk", updatedAt: now }),
      page({
        id: "old",
        title: "Earlier note",
        body: "last month",
        updatedAt: now - 20 * 24 * 60 * 60 * 1000,
      }),
    ];
    const groups = groupPages(pages, "", now);
    assert.deepEqual(
      groups.map((g) => g.key),
      ["Today", "Earlier"],
    );
  });
});
