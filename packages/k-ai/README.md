# k-ai

A collection of AI-powered tools for various tasks. Currently includes:

- `firecrawl` - Web scraping and crawling utilities powered by [Firecrawl](https://firecrawl.dev)

## Installation

### Install dependencies:

```bash
cd ~/dotfiles/packages/k-ai
bun install
```

### Install globally:

```bash
# From the home directory
cd ~
bun install ./dotfiles/packages/k-ai
```

This will make the `k-ai` command available in `~/node_modules/.bin/k-ai`.

Add the following to your PATH (already configured in dotfiles/nix/users/kelvin/hm/common.nix):
```
export PATH="$HOME/node_modules/.bin:$PATH"
```

## Usage

### Firecrawl

Requires a Firecrawl API key. Get one from [firecrawl.dev](https://firecrawl.dev).

Set the API key in your environment:
```bash
export FIRECRAWL_API_KEY="your-api-key"
```

#### Scrape a single URL:
```bash
k-ai firecrawl scrape https://example.com
k-ai firecrawl scrape https://example.com --format=markdown
```

#### Crawl multiple pages starting from a URL:
```bash
k-ai firecrawl crawl https://example.com --limit=10
k-ai firecrawl crawl https://example.com --limit=20 --format=html
```

#### Generate a map of URLs from a website:
```bash
k-ai firecrawl map https://example.com
```

## Development

This project uses [Bun](https://bun.sh) as its JavaScript runtime.

### Project Structure

- `src/index.ts` - Main CLI entry point
- `src/tools/` - Directory containing individual tools
  - `firecrawl.ts` - Firecrawl web scraping tool
