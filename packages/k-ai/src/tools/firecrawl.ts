import FirecrawlApp from '@mendable/firecrawl-js';

export async function run(args: string[]) {
  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    showHelp();
    return;
  }

  const apiKey = process.env.FIRECRAWL_API_KEY;
  
  if (!apiKey) {
    console.error("\n❌ Error: FIRECRAWL_API_KEY environment variable is not set");
    console.error("\nTo get an API key:");
    console.error("1. Visit https://firecrawl.dev and sign up");
    console.error("2. Go to your dashboard and create an API key");
    console.error("\nTo set the API key for this session:");
    console.error("export FIRECRAWL_API_KEY='your-api-key'");
    console.error("\nFor persistent configuration, add to your preferred environment setup");
    process.exit(1);
  }

  const app = new FirecrawlApp({ apiKey });
  const command = args[0];

  try {
    switch (command) {
      case 'scrape':
        await handleScrape(app, args.slice(1));
        break;
      case 'crawl':
        await handleCrawl(app, args.slice(1));
        break;
      case 'map':
        await handleMap(app, args.slice(1));
        break;
      default:
        console.error(`Error: Unknown subcommand '${command}'`);
        showHelp();
        process.exit(1);
    }
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

// Command handlers
export async function handleScrape(app: any, args: string[]) {
  if (args.length === 0) {
    console.error("Error: URL is required for scrape command");
    showHelp();
    process.exit(1);
  }

  const url = args[0];
  const format = getFormat(args);
  const options = format ? { formats: [format] } : undefined;

  console.log(`Scraping ${url}...`);
  const result = await app.scrapeUrl(url, options);
  
  if (result?.data) {
    if (format && result.data[format]) {
      console.log(result.data[format]);
    } else {
      console.log(JSON.stringify(result, null, 2));
    }
  } else {
    console.log(result);
  }
}

export async function handleCrawl(app: any, args: string[]) {
  if (args.length === 0) {
    console.error("Error: URL is required for crawl command");
    showHelp();
    process.exit(1);
  }

  const url = args[0];
  const limit = getLimit(args);
  const format = getFormat(args);
  
  const options: any = {};
  if (limit) options.limit = limit;
  if (format) options.scrapeOptions = { formats: [format] };

  console.log(`Crawling ${url} with limit ${limit || 'default'}...`);
  const result = await app.crawlUrl(url, options);
  
  if (result?.results) {
    console.log(`Crawled ${result.results.length} pages`);
    
    if (format) {
      for (const page of result.results) {
        console.log(`\n--- ${page.url} ---`);
        if (page.data && page.data[format]) {
          console.log(page.data[format]);
        } else {
          console.log('[No data in specified format]');
        }
      }
    } else {
      console.log(JSON.stringify(result, null, 2));
    }
  } else {
    console.log(result);
  }
}

export async function handleMap(app: any, args: string[]) {
  if (args.length === 0) {
    console.error("Error: URL is required for map command");
    showHelp();
    process.exit(1);
  }

  const url = args[0];
  
  console.log(`Mapping ${url}...`);
  const result = await app.mapUrl(url);
  
  if (result?.urls) {
    console.log(`Found ${result.urls.length} URLs:`);
    for (const mapUrl of result.urls) {
      console.log(mapUrl);
    }
  } else {
    console.log(result);
  }
}

// Helper functions
export function showHelp() {
  console.log(`
Firecrawl - Web scraping and crawling utility

Usage:
  k-ai firecrawl <command> <url> [options]

Commands:
  scrape        Extract content from a single URL
  crawl         Crawl multiple pages from a starting URL
  map           Generate a list of URLs from a website

Options:
  --format=<format>   Output format (markdown, html, text)
  --limit=<number>    Maximum number of pages to crawl (for crawl command)
  --help, -h          Show this help message

Examples:
  k-ai firecrawl scrape https://example.com --format=markdown
  k-ai firecrawl crawl https://example.com --limit=10 --format=text
  k-ai firecrawl map https://example.com

Environment:
  FIRECRAWL_API_KEY   API key from https://firecrawl.dev (required)
  `);
}

export function getFormat(args: string[]) {
  const formatArg = args.find(arg => arg.startsWith('--format='));
  return formatArg ? formatArg.split('=')[1] : null;
}

export function getLimit(args: string[]) {
  const limitArg = args.find(arg => arg.startsWith('--limit='));
  return limitArg ? parseInt(limitArg.split('=')[1], 10) : null;
}