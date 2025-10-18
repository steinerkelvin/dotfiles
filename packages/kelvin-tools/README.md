# kelvin-tools

Kelvin's AI tools collection. A set of utilities for working with AI APIs and tools.

## Installation

```bash
# Install dependencies
cd ~/dotfiles/packages/kelvin-tools
bun install
```

## Available Commands

### kelvin-tools context

Display CLAUDE.md files from home directory to the current directory. This helps set up the context for a Claude Code session by showing relevant configuration files.

```bash
kelvin-tools context
```

### kelvin-tools firecrawl

Web scraping and crawling utilities using the Firecrawl API. Requires the `FIRECRAWL_API_KEY` environment variable to be set.

```bash
# Get API key from firecrawl.dev
export FIRECRAWL_API_KEY="your-api-key"

# Scrape a single URL
kelvin-tools firecrawl scrape https://example.com
kelvin-tools firecrawl scrape https://example.com --format=markdown

# Crawl multiple pages from a URL
kelvin-tools firecrawl crawl https://example.com --limit=10
kelvin-tools firecrawl crawl https://example.com --format=text

# Generate a map of URLs from a website
kelvin-tools firecrawl map https://example.com
```

## Development

The tool is structured as follows:

- `src/index.ts` - Main entry point and command router
- `src/tools/` - Individual tools implementation
- `src/utils/` - Shared utilities

### Adding a new command

1. Create a new file in `src/tools/` for your command
2. Use the cmd-ts library to define your command
3. Import and add your command to the subcommands in `src/index.ts`

Example:

```typescript
// src/tools/example.ts
import { command } from 'cmd-ts';
import { helpFlag } from '../utils/cmd';

export const exampleCmd = command({
  name: 'example',
  description: 'An example command',
  args: {
    help: helpFlag,
    // Add more arguments here
  },
  handler: async () => {
    // Command implementation
    console.log('Example command executed');
  }
});

// src/index.ts
import { exampleCmd } from './tools/example';

const cli = subcommands({
  name: 'kelvin-tools',
  description: "Kelvin's AI tools collection",
  cmds: {
    firecrawl: firecrawlCmd,
    context: contextCmd,
    example: exampleCmd // Add your new command here
  }
});
```

### Running tests

```bash
bun test
```