#!/usr/bin/env bun

import { subcommands } from "cmd-ts";
import { contextCmd } from "./tools/context";
import { firecrawlCmd } from "./tools/firecrawl";
import { executeCommand } from "./utils/cmd";
import { coerceError } from "./utils/errors";

// Main CLI command with subcommands
const cli = subcommands({
  name: "kelvin-tools",
  description: "Kelvin's AI tools collection",
  cmds: {
    firecrawl: firecrawlCmd,
    context: contextCmd,
  },
});

// Run the CLI
executeCommand(cli, process.argv.slice(2)).catch((err) => {
  const error = coerceError(err);
  console.error(`Fatal error: ${error.message}`);
  process.exit(1);
});
