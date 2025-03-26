import FirecrawlApp, { type FirecrawlDocument } from "@mendable/firecrawl-js";
import { command, flag, option, positional, subcommands } from "cmd-ts";
import { z } from "zod";
import { helpFlag, positiveIntType, urlType, zodType } from "../utils/cmd";
import { hasProperty } from "../utils/errors";

// Create format type here for Firecrawl-specific formats
export const formatSchema = z.enum(["markdown", "html"], {
  errorMap: () => ({ message: "Must be one of: markdown, html" }),
});
export type Format = z.infer<typeof formatSchema>;
export const formatType = zodType(formatSchema);

// Output mode schema
export const outputModeSchema = z.enum(["human", "raw"], {
  errorMap: () => ({ message: "Must be one of: human, raw" }),
});
export type OutputMode = z.infer<typeof outputModeSchema>;

// Metadata schema
const metadataSchema = z
  .object({
    title: z.string().optional(),
    description: z.string().optional(),
    url: z.string().url().optional(),
    sourceURL: z.string().url(),
    scrapeId: z.string(),
    statusCode: z.number(),
  })
  .catchall(z.unknown());

type Metadata = z.infer<typeof metadataSchema>;

// API response types
type ScrapeData = {
  metadata: Metadata;
  [key: string]: unknown;
};

type CrawlPage = {
  url: string;
  data?: {
    metadata?: Metadata;
    [key: string]: unknown;
  };
};

// Format metadata as YAML frontmatter
function formatFrontmatter(metadata: Metadata): string {
  const frontmatter = Object.entries(metadata)
    .map(([key, value]) => `${key}: ${JSON.stringify(value)}`)
    .join("\n");
  return `---\n${frontmatter}\n---\n\n`;
}

// Define schema for content validation
const stringContentSchema = z.string();

// Check for API key and get FirecrawlApp instance
function getFirecrawlApp() {
  const apiKey = process.env.FIRECRAWL_API_KEY;

  if (!apiKey) {
    console.error(
      "\n❌ Error: FIRECRAWL_API_KEY environment variable is not set"
    );
    console.error("\nTo get an API key:");
    console.error("1. Visit https://firecrawl.dev and sign up");
    console.error("2. Go to your dashboard and create an API key");
    console.error("\nTo set the API key for this session:");
    console.error("export FIRECRAWL_API_KEY='your-api-key'");
    console.error(
      "\nFor persistent configuration, add to your preferred environment setup"
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
    raw: flag({
      long: "raw",
      description: "Output raw JSON response",
    }),
    format: option({
      type: formatType,
      long: "format",
      description: "Output format (markdown, html)",
      defaultValue: () => formatSchema.enum.markdown,
    }),
  },
  handler: async (args) => {
    const app = getFirecrawlApp();

    console.error(`Scraping ${args.url}...`);

    // Always get both selected format and metadata
    const options = {
      formats: [args.format],
      onlyMainContent: true,
    };

    const result = await app.scrapeUrl(args.url, options);

    if (!result.success) {
      console.error("Error: Scraping failed");
      console.error(JSON.stringify(result, null, 2));
      process.exit(1);
    }

    if (args.raw) {
      // Raw mode - output JSON with requested format
      console.log(
        JSON.stringify(
          {
            success: true,
            warning: result.warning,
            error: result.error,
            [args.format]: result[args.format],
            metadata: result.metadata,
          },
          null,
          2
        )
      );
    } else {
      // Human mode (default) - output YAML frontmatter + content
      if (
        !hasProperty(result, args.format) ||
        !hasProperty(result, "metadata")
      ) {
        console.error("Error: Missing required data for human-friendly output");
        process.exit(1);
      }

      const metadata = metadataSchema.parse(result.metadata);
      const frontmatter = formatFrontmatter(metadata);
      const content = stringContentSchema.parse(result[args.format]);

      console.log(frontmatter + content);
    }
  },
});

function formatCrawlOutput(
  documents: FirecrawlDocument<undefined>[],
  format: Format,
  isRaw: boolean
): string {
  if (isRaw) {
    return JSON.stringify({ pages: documents }, null, 2);
  }

  return documents
    .map((doc) => {
      const url = doc.url || "<Unknown URL>";
      if (!doc[format]) {
        return `\n## ${url}\n\n[No content in ${format} format]\n`;
      }

      const metadata = doc.metadata
        ? formatFrontmatter(metadataSchema.parse(doc.metadata))
        : "";
      const content = stringContentSchema.parse(doc[format]);

      return `\n## ${url}\n\n${metadata}${content}\n`;
    })
    .join("\n---\n");
}

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
    raw: flag({
      long: "raw",
      description: "Output raw JSON response",
    }),
    format: option({
      type: formatType,
      long: "format",
      description: "Output format (markdown, html)",
      defaultValue: () => formatSchema.enum.markdown,
    }),
  },
  handler: async (args) => {
    const app = getFirecrawlApp();

    const options = {
      limit: args.limit,
      scrapeOptions: { formats: [args.format] },
    };

    console.error(`Crawling ${args.url} with limit ${args.limit}...`);

    const result = await app.crawlUrl(args.url, options);

    if (!result.success || !hasProperty(result, "data")) {
      console.error("Error: Invalid crawl response");
      console.error(JSON.stringify(result, null, 2));
      process.exit(1);
    }

    console.error(`Crawled ${result.completed} of ${result.total} pages`);
    console.log(formatCrawlOutput(result.data, args.format, args.raw));
  },
});

function formatMapOutput(urls: string[], isRaw: boolean): string {
  if (isRaw) {
    return JSON.stringify({ urls }, null, 2);
  }

  return urls.join("\n");
}

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
    raw: flag({
      long: "raw",
      description: "Output raw JSON response",
    }),
  },
  handler: async (args) => {
    const app = getFirecrawlApp();

    console.error(`Mapping ${args.url}...`);
    const result = await app.mapUrl(args.url);

    if (!result.success || !hasProperty(result, "links")) {
      console.error("Error: Invalid map response");
      console.error(JSON.stringify(result, null, 2));
      process.exit(1);
    }

    console.error(`Found ${result.links?.length || 0} URLs:`);
    console.log(formatMapOutput(result.links || [], args.raw));
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
