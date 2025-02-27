# Atuin History Management Process

This document outlines our approach to cleaning and maintaining Atuin shell history.

## What Atuin Stores

Atuin records:
- Commands executed
- Exit codes (success/failure)
- Timestamps and duration
- Directory where commands were run
- Host information
- Does NOT store command output (stdout)

## Cleaning Strategy

We've developed a systematic approach to cleaning Atuin history using `atuin_cleaner.py`.

### Key Categories for Cleaning

1. **Command Not Found Errors** (exit code 127)
   - Unknown commands that should be deleted
   - May contain typos or obsolete command attempts

2. **Invalid Path Operations**
   - Commands that reference non-existent directories or files
   - Often incorrect paths in mkdir, touch, cd, etc.

3. **Potential Typos**
   - Identified by comparing similar commands 
   - Commands with low success rates compared to similar ones
   - Example: "brrot" vs "brew", "clac" vs "calc"

4. **Interrupted Commands** (exit code 130)
   - Commands terminated with Ctrl+C
   - Require careful handling as interruption doesn't mean error

## Cleaning Process

The `atuin_cleaner.py` script provides three main functions:

### 1. Analysis Mode
```bash
python3 ~/dotfiles/scripts/atuin_cleaner.py analyze
```
- Generates comprehensive statistics on command history
- Identifies patterns of failures and potential typos
- Shows exit code distribution and low success rate commands
- Use this first to understand your history patterns

### 2. Interactive Mode
```bash
python3 ~/dotfiles/scripts/atuin_cleaner.py interactive
```
- Reviews commands by category for selective deletion
- Allows batch processing with confirmation
- Supports custom pattern matching for targeted cleanup
- Recommended for careful, selective cleaning

### 3. Automatic Mode
```bash
python3 ~/dotfiles/scripts/atuin_cleaner.py clean --dry-run  # Preview
python3 ~/dotfiles/scripts/atuin_cleaner.py clean            # Execute
```
- Applies predefined rules to identify cleanup candidates
- Useful for routine maintenance after establishing patterns

## Maintenance Recommendations

1. **Regular Analysis**
   - Run `analyze` monthly to identify new patterns
   - Look for commands with low success rates

2. **Configure Exclusion Filters**
   - Set up `history_filter` in `~/.config/atuin/config.toml`
   - Prevents recording of sensitive or noisy commands

3. **Scheduled Cleaning**
   - Run `clean --dry-run` periodically to check for candidates
   - Follow with `clean` to remove unwanted entries

4. **Review Command Patterns**
   - Use `atuin stats` to identify frequently used commands
   - Consider creating aliases for common typos

## Future Improvements

- Enhance similarity detection for better typo identification
- Implement command context tracking for more intelligent cleaning
- Add temporal analysis to identify obsolete commands
- Improve interactive mode with more filtering options
- Consider automatic periodic cleaning routines

---

The goal of this process is to maintain a clean, useful command history while removing noise from failed commands and typos, making Atuin's search features more effective.