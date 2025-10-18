/**
 * Error handling utilities
 */

import { z } from "zod";

/**
 * Ensures an unknown error is converted to a proper Error object
 * with appropriate typing and message handling
 */
export function coerceError(error: unknown): Error {
  if (error instanceof Error) {
    return error;
  }

  if (error instanceof z.ZodError) {
    return new Error(
      error.errors.map((e) => `${e.path.join(".")}: ${e.message}`).join(", "),
    );
  }

  // Handle other specific error types here if needed

  // Convert any other type to a string-based Error
  return new Error(typeof error === "string" ? error : String(error));
}

/**
 * Type guard to check if an object has a specific property
 * Useful for checking response shapes
 */
export function hasProperty<K extends string>(
  obj: unknown,
  key: K,
): obj is { [key in K]: unknown } {
  return obj !== null && typeof obj === "object" && key in obj;
}
