import { describe, expect, it } from "vitest";
import { z } from "zod";
import { coerceError, hasProperty } from "./errors";

describe("coerceError", () => {
  it("should pass through Error objects", () => {
    const error = new Error("test error");
    expect(coerceError(error)).toBe(error);
  });

  it("should convert string to Error", () => {
    const result = coerceError("string error");
    expect(result).toBeInstanceOf(Error);
    expect(result.message).toBe("string error");
  });

  it("should convert non-string non-Error to Error with string representation", () => {
    const obj = { code: 404, message: "not found" };
    const result = coerceError(obj);
    expect(result).toBeInstanceOf(Error);
    expect(result.message).toBe(String(obj));
  });

  it("should handle null/undefined", () => {
    const result1 = coerceError(null);
    expect(result1).toBeInstanceOf(Error);
    expect(result1.message).toBe("null");

    const result2 = coerceError(undefined);
    expect(result2).toBeInstanceOf(Error);
    expect(result2.message).toBe("undefined");
  });

  it("should handle Zod errors", () => {
    const schema = z.string().email();
    let zodError: unknown = null;
    try {
      schema.parse("not-an-email");
    } catch (error) {
      zodError = error;
    }

    const result = coerceError(zodError);
    expect(result).toBeInstanceOf(Error);
    expect(result.message).toContain("Invalid");
  });
});

describe("hasProperty", () => {
  it("should return true for objects with the specified property", () => {
    expect(hasProperty({ name: "test" }, "name")).toBe(true);
    expect(hasProperty({ deep: { prop: true } }, "deep")).toBe(true);
  });

  it("should return false for objects without the specified property", () => {
    expect(hasProperty({ name: "test" }, "age")).toBe(false);
  });

  it("should return false for non-objects", () => {
    expect(hasProperty(null, "prop")).toBe(false);
    expect(hasProperty(undefined, "prop")).toBe(false);
    expect(hasProperty("string", "length")).toBe(false); // Not an object in the sense we're testing
    expect(hasProperty(42, "toString")).toBe(false); // Not an object in the sense we're testing
  });

  it("should work as a type guard", () => {
    const obj: unknown = { name: "test", value: 42 };

    if (hasProperty(obj, "name")) {
      // TypeScript should now know that obj.name exists
      expect(typeof obj.name).toBe("string");
    } else {
      // This branch should not be reached
      expect(true).toBe(false);
    }
  });
});
