import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { command } from "cmd-ts";
import { helpFlag } from "../utils/cmd";
import { coerceError } from "../utils/errors";

/**
 * Context command - Displays CLAUDE.md files from home directory to current directory
 */
export const contextCmd = command({
  name: "context",
  description:
    "Display CLAUDE.md files from home directory to current directory",
  args: {
    help: helpFlag,
  },
  handler: async () => {
    try {
      // Get current working directory
      const cwd = process.cwd();
      // Get home directory
      const homeDir = os.homedir();

      // Ensure we're within the home directory
      if (!cwd.startsWith(homeDir)) {
        console.error(
          `Error: Current directory ${cwd} is not within the home directory ${homeDir}`,
        );
        process.exit(1);
      }

      // Find path segments from home to current directory
      const relPath = cwd.substring(homeDir.length);
      const segments = relPath.split(path.sep).filter(Boolean);

      // Build array of paths to check for CLAUDE.md
      const pathsToCheck = [
        path.join(homeDir, "CLAUDE.md"),
        ...segments.map((_, i) => {
          const subPath = segments.slice(0, i + 1).join(path.sep);
          return path.join(homeDir, subPath, "CLAUDE.md");
        }),
      ];

      let foundFiles = 0;

      // Print each CLAUDE.md file that exists
      for (const filePath of pathsToCheck) {
        if (fs.existsSync(filePath)) {
          const content = fs.readFileSync(filePath, "utf-8");
          const relativePath = filePath.replace(homeDir, "~");

          console.log(`\n\x1b[1m=== ${relativePath} ===\x1b[0m\n`);
          console.log(content);
          foundFiles++;
        }
      }

      if (foundFiles === 0) {
        console.log("No CLAUDE.md files found in the path hierarchy.");
      } else {
        // Print helpful instruction
        console.log("\n\x1b[1m=== Additional Instructions ===\x1b[0m\n");
        console.log(
          "Please review the CLAUDE.md content above before proceeding.",
        );
        console.log("You may want to check for relevant files like:\n");
        console.log("- TODO.md - Task list for the current context");
        console.log("- NEXT.md - Temporary file for session continuity");
        console.log("- INDEX.md - Directory structure and organization");
        console.log("- PLAN.md - Project implementation plan (if available)");
      }
    } catch (error) {
      const err = coerceError(error);
      console.error(`Error: ${err.message}`);
      process.exit(1);
    }
  },
});
