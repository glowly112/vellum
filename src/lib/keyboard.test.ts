import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { keyboardInset } from "./keyboard.ts";

describe("keyboardInset", () => {
  it("uses visualViewport, not 100vh", () => {
    assert.equal(keyboardInset(844, 500, 0), 344);
  });

  it("subtracts visualViewport.offsetTop", () => {
    assert.equal(keyboardInset(844, 500, 47), 297);
  });

  it("never goes negative", () => {
    assert.equal(keyboardInset(800, 900, 0), 0);
  });
});
