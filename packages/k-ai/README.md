# k-ai

Kelvin's AI tools collection. A set of utilities for working with AI APIs and tools.

## Installation

```bash
# Install dependencies
cd ~/dotfiles/packages/k-ai
bun install
```

## Available Commands

### k-ai context

Display CLAUDE.md files from home directory to the current directory. This helps set up the context for a Claude Code session by showing relevant configuration files.

### k-ai firecrawl

Web scraping and crawling utilities using the Firecrawl API. Requires the `FIRECRAWL_API_KEY` environment variable to be set.

## Development

The tool is structured as follows:

- `src/index.ts` - Main entry point and command router
- `src/tools/` - Individual tools implementation
- `src/utils/` - Shared utilities