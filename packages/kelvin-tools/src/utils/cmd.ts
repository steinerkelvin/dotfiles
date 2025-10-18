import { flag, run } from "cmd-ts";
import type { Runner, Type } from "cmd-ts";
import { assert } from "tsafe";
import { type ZodAnyDef, z } from "zod";
import { coerceError } from "./errors";

// Helper to create a Type from a Zod schema
export function zodType<T>(schema: z.ZodType<T>): Type<string, T> {
  return {
    async from(str: string) {
      try {
        // For simple types like string/number, parse directly
        // For complex types, try to parse as JSON first
        let parsed: unknown;
        try {
          parsed = JSON.parse(str);
        } catch {
          parsed = str;
        }

        return schema.parse(parsed);
      } catch (error) {
        throw coerceError(error);
      }
    },
  };
}

// Common schemas
export const urlSchema = z.string().url("Must be a valid URL");
export const positiveIntSchema = z.coerce
  .number()
  .int()
  .positive("Must be a positive integer");

// Create types from schemas
export const urlType = zodType(urlSchema);
export const positiveIntType = zodType(positiveIntSchema);

// Helper to create standardized help flags
export const helpFlag = flag({
  long: "help",
  short: "h",
  description: "Show help information",
});

// Execute a command and handle errors
export async function executeCommand<R extends Runner<unknown, unknown>>(
  cmd: R,
  args: string[],
) {
  try {
    await run(cmd, args);
  } catch (error) {
    const err = coerceError(error);
    if (err.message !== "HELP_FLAG") {
      // Ignore help flag errors
      console.error(`Error: ${err.message}`);
      process.exit(1);
    }
  }
}
