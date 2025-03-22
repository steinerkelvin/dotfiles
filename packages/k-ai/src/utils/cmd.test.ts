import { describe, expect, it } from "vitest";
import { z } from "zod";
import { zodType } from "./cmd";

describe("zodType", () => {
  it("should validate string input with zod schema", async () => {
    const schema = z.string().email();
    const type = zodType(schema);

    // Valid email
    await expect(type.from("test@example.com")).resolves.toBe(
      "test@example.com",
    );

    // Invalid email
    await expect(type.from("not-an-email")).rejects.toThrow();
  });

  it("should validate numeric input with zod schema", async () => {
    const schema = z.number().int().positive();
    const type = zodType(schema);

    // Valid number
    await expect(type.from("42")).resolves.toBe(42);

    // Invalid number
    await expect(type.from("-1")).rejects.toThrow();
    await expect(type.from("3.14")).rejects.toThrow();
  });

  it("should validate enum values", async () => {
    const schema = z.enum(["one", "two", "three"]);
    const type = zodType(schema);

    // Valid enum value
    await expect(type.from("one")).resolves.toBe("one");

    // Invalid enum value
    await expect(type.from("four")).rejects.toThrow();
  });
});
