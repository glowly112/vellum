import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { exportFilename, exportTxtContents } from "./export-page.ts";

describe("exportFilename", () => {
  it("slugifies the title and adds .txt", () => {
    assert.equal(exportFilename("Late light on the river", ""), "late-light-on-the-river.txt");
  });

  it("falls back to the first body line, then untitled-page.txt", () => {
    assert.equal(exportFilename("  ", "The Thames is pewter\nnext"), "the-thames-is-pewter.txt");
    assert.equal(exportFilename("", ""), "untitled-page.txt");
  });
});

describe("exportTxtContents", () => {
  it("writes title, blank line, body, trailing newline", () => {
    assert.equal(
      exportTxtContents("Notes", "oat milk\nlemons"),
      "Notes\n\noat milk\nlemons\n",
    );
  });

  it("omits the blank line when there is no body", () => {
    assert.equal(exportTxtContents("Title only", "  "), "Title only\n");
  });

  it("omits the heading when the title is empty", () => {
    assert.equal(exportTxtContents("", "just the body"), "just the body\n");
  });
});
