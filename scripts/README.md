# Scripts

This directory contains utility scripts.

## atuin_cleaner.py

A comprehensive tool for cleaning your Atuin shell history.

### Features

- Analyzes command history and provides statistics
- Identifies potential typos, invalid commands, and other issues
- Interactive cleaning mode for reviewing and selecting commands to delete
- Automatic cleaning mode based on predefined rules
- Supports dry-run mode for safe testing

### Usage

```bash
# Analyze history and get recommendations
python3 atuin_cleaner.py analyze

# Interactive cleaning session
python3 atuin_cleaner.py interactive

# Automatic cleaning
python3 atuin_cleaner.py clean --dry-run  # See what would be deleted
python3 atuin_cleaner.py clean --confirm  # Confirm before deletion
python3 atuin_cleaner.py clean            # Delete without confirmation
```

### Cleaning Criteria

The script identifies several categories of commands for cleaning:

1. Commands with exit code 127 (command not found)
2. Invalid path operations that resulted in errors
3. Potential typos based on command similarity and success rates
4. Custom patterns defined during interactive cleaning

For best results, run the analyze command first to understand your history patterns, then use interactive mode for careful cleaning.

See [ATUIN.md](ATUIN.md) for detailed documentation about the Atuin history management process.

## discord-krisp-patch.sh

Script for patching Discord's Krisp noise suppression.