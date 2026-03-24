# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`kelvin-tools` is a TypeScript CLI application built with Bun, providing utilities for working with AI tools and APIs. The project uses:

- **Bun** as the JavaScript runtime (required for development and execution)
- **cmd-ts** for CLI command parsing and routing
- **Biome** for linting and formatting
- **Vitest** for testing
- **Zod** for runtime validation

## Essential Commands

```sh
# Install dependencies
bun install

# Development commands
bun test                # Run tests in watch mode
bun run typecheck       # Type-check without emitting
bun run lint            # Lint source code
bun run format          # Format source code
bun run check           # Check code (lint + format)
bun run fix             # Fix linting and formatting issues

# Run the CLI locally
bun src/index.ts <command>
```

## Architecture

### Command Structure

The CLI follows a subcommand pattern where each tool is a separate subcommand:

1. **Entry Point** (`src/index.ts`): Defines the main CLI using `subcommands()` and routes to individual tool commands
2. **Tool Commands** (`src/tools/`): Each file exports a command or nested subcommands
3. **Utilities** (`src/utils/`): Shared helpers for CLI parsing, error handling, and type validation

### Adding New Commands

To add a new command:

1. Create a new file in `src/tools/your-command.ts`
2. Define your command using `command()` or `subcommands()` from cmd-ts
3. Import and register it in `src/index.ts` within the `cmds` object

Example structure:

```typescript
import { command } from 'cmd-ts';
import { helpFlag } from '../utils/cmd';

export const yourCmd = command({
  name: 'your-command',
  description: 'Description of your command',
  args: {
    help: helpFlag,
    // Add more arguments using positional() or option()
  },
  handler: async (args) => {
    // Implementation
  }
});
```

### Validation Pattern

The project uses Zod schemas with cmd-ts types for validation:

1. Define a Zod schema (e.g., `z.string().url()`)
2. Convert it to a cmd-ts Type using `zodType()` helper
3. Use the Type in command args for automatic parsing and validation

See `src/utils/cmd.ts` for `urlType` and `positiveIntType` examples.

### Error Handling

- Use `coerceError()` from `src/utils/errors.ts` to normalize errors to Error objects
- Use `hasProperty()` type guard for safe property access on unknown objects
- The `executeCommand()` wrapper in utils handles top-level errors and exits gracefully

## Code Style

- **Format**: 2-space indentation, 80-character line width, double quotes (enforced by Biome)
- **TypeScript**: Strict mode enabled, bundler module resolution
- **Imports**: Organize imports automatically via Biome
- **Node APIs**: Use `node:` prefix for built-in modules (e.g., `import fs from "node:fs"`)

## Current Tools

### context

Displays CLAUDE.md files from home directory to current working directory. Useful for setting up Claude Code context by showing relevant configuration files in the path hierarchy.

### firecrawl

Web scraping utilities using the Firecrawl API. Requires `FIRECRAWL_API_KEY` environment variable.

Subcommands:
- `scrape <url>` - Extract content from a single URL
- `crawl <url>` - Crawl multiple pages from a starting URL
- `map <url>` - Generate a list of URLs from a website

All firecrawl commands support `--format` option (markdown or html).
