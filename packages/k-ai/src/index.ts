#!/usr/bin/env bun

import * as firecrawl from './tools/firecrawl';

// Main function
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    showHelp();
    return;
  }

  const command = args[0];

  try {
    switch (command) {
      case 'firecrawl':
        await firecrawl.run(args.slice(1));
        break;
      // Other tools can be added here in the future
      default:
        console.error(`Error: Unknown command '${command}'`);
        showHelp();
        process.exit(1);
    }
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

// Helper functions
function showHelp() {
  console.log(`
k-ai - Kelvin's AI tools collection

Usage:
  k-ai <command> [options]

Commands:
  firecrawl   Web scraping and crawling utilities

Options:
  --help, -h  Show this help message

Examples:
  k-ai firecrawl scrape https://example.com
  k-ai firecrawl --help
  `);
}

// Run the main function
main().catch(err => {
  console.error(`Fatal error: ${err.message}`);
  process.exit(1);
});