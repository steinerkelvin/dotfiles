import FirecrawlApp from "@mendable/firecrawl-js";
import { command, option, positional, subcommands } from "cmd-ts";
import { z } from "zod";
import { helpFlag, positiveIntType, urlType, zodType } from "../utils/cmd";
import { hasProperty } from "../utils/errors";

// Create format type here for Firecrawl-specific formats
export const formatSchema = z.enum(["markdown", "html"], {
  errorMap: () => ({ message: "Must be one of: markdown, html" }),
});
export const formatType = zodType(formatSchema);

// Check for API key and get FirecrawlApp instance
function getFirecrawlApp() {
  const apiKey = process.env.FIRECRAWL_API_KEY;

  if (!apiKey) {
    console.error(
      "\n❌ Error: FIRECRAWL_API_KEY environment variable is not set",
    );
    console.error("\nTo get an API key:");
    console.error("1. Visit https://firecrawl.dev and sign up");
    console.error("2. Go to your dashboard and create an API key");
    console.error("\nTo set the API key for this session:");
    console.error("export FIRECRAWL_API_KEY='your-api-key'");
    console.error(
      "\nFor persistent configuration, add to your preferred environment setup",
    );
    process.exit(1);
  }

  return new FirecrawlApp({ apiKey });
}

// Scrape command - Extract content from a single URL
const scrapeCmd = command({
  name: "scrape",
  description: "Extract content from a single URL",
  args: {
    help: helpFlag,
    url: positional({
      type: urlType,
      displayName: "url",
      description: "URL to scrape",
    }),
    format: option({
      type: formatType,
      long: "format",
      description: "Output format (markdown, html etc.)",
      defaultValue: () => formatSchema.enum.markdown,
    }),
  },
  handler: async (args) => {
    const app = getFirecrawlApp();

    console.log(`Scraping ${args.url}...`);
    const options = { formats: [args.format] };

    const result = await app.scrapeUrl(args.url, options);

    if (hasProperty(result, "data") && result.data) {
      if (args.format && hasProperty(result.data, args.format)) {
        console.log(result.data[args.format]);
      } else {
        console.log(JSON.stringify(result, null, 2));
      }
    } else {
      console.log(result);
    }
  },
});

// Crawl command - Crawl multiple pages from a starting URL
const crawlCmd = command({
  name: "crawl",
  description: "Crawl multiple pages from a starting URL",
  args: {
    help: helpFlag,
    url: positional({
      type: urlType,
      displayName: "url",
      description: "Starting URL to crawl from",
    }),
    limit: option({
      type: positiveIntType,
      long: "limit",
      description: "Maximum number of pages to crawl",
      defaultValue: () => 8,
    }),
    format: option({
      type: formatType,
      long: "format",
      description: "Output format (markdown, html, etc.)",
      defaultValue: () => formatSchema.enum.markdown,
    }),
  },
  handler: async (args) => {
    const app = getFirecrawlApp();

    const options: Record<string, unknown> = {};
    if (args.limit) options.limit = args.limit;
    if (args.format) options.scrapeOptions = { formats: [args.format] };

    console.log(
      `Crawling ${args.url} with limit ${args.limit || "default"}...`,
    );
    const result = await app.crawlUrl(args.url, options);

    if (hasProperty(result, "results") && Array.isArray(result.results)) {
      console.log(`Crawled ${result.results.length} pages`);

      if (args.format) {
        for (const page of result.results) {
          if (hasProperty(page, "url")) {
            console.log(`\n--- ${page.url} ---`);
            if (
              hasProperty(page, "data") &&
              page.data &&
              hasProperty(page.data, args.format)
            ) {
              console.log(page.data[args.format]);
            } else {
              console.log("[No data in specified format]");
            }
          }
        }
      } else {
        console.log(JSON.stringify(result, null, 2));
      }
    } else {
      console.log(result);
    }
  },
});

// Map command - Generate a list of URLs from a website
const mapCmd = command({
  name: "map",
  description: "Generate a list of URLs from a website",
  args: {
    help: helpFlag,
    url: positional({
      type: urlType,
      displayName: "url",
      description: "URL of the website to map",
    }),
  },
  handler: async (args) => {
    const app = getFirecrawlApp();

    console.log(`Mapping ${args.url}...`);
    const result = await app.mapUrl(args.url);

    if (hasProperty(result, "urls") && Array.isArray(result.urls)) {
      console.log(`Found ${result.urls.length} URLs:`);
      for (const mapUrl of result.urls) {
        console.log(mapUrl);
      }
    } else {
      console.log(result);
    }
  },
});

// Main firecrawl command with subcommands
export const firecrawlCmd = subcommands({
  name: "firecrawl",
  description: "Web scraping and crawling utilities using Firecrawl API",
  cmds: {
    scrape: scrapeCmd,
    crawl: crawlCmd,
    map: mapCmd,
  },
});
