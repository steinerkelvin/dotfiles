# Home Directory Guide

## Assistant Directives

- When told to "Remember" something, update this CLAUDE.md file to persist the information
- This ensures important instructions, workflows, and guidelines persist between sessions
- If working in a directory with its own CLAUDE.md file, update that specific CLAUDE.md instead when appropriate
- For example, when making changes to dotfiles, update ~/dotfiles/CLAUDE.md

## Directory Structure

- `/Users/kelvin/dotfiles` - Configuration files and system setup
- `/Users/kelvin/sync/notes/obsidian` - Obsidian vault for note-taking
- `~/.homesick/repos` - Homeshick repository links
- Add more important directories as discovered

## Available Commands

Installed via Nix/home-manager (~/dotfiles/nix/users/kelvin/hm/packages.nix):

### File & Directory Tools
- `tree` - Display directory structure in tree format
- `eza` - Modern replacement for ls
- `bat` - Enhanced cat with syntax highlighting
- `ripgrep` - Fast text search (rg command)
- `silver-searcher` - Fast code search (ag command)
- `fzf` - Fuzzy finder
- `dua` - Disk usage analyzer

### Shell & Navigation
- `zoxide` - Smarter cd command with jump functionality
- `tmux` - Terminal multiplexer
- `jq` - JSON processor
- `yq` - YAML processor
- `stow` - Symlink farm manager

### Git Tools
- `gh` - GitHub CLI
- `tig` - Text-mode interface for git
- `diff-so-fancy` - Better git diff
- `difftastic` - Enhanced diffing tool

### System Tools
- `htop` - Interactive process viewer
- `bottom` - System monitor (btm command)
- `pstree` - Display process tree

## Dotfiles Management

- Dotfiles managed using homeshick (installed via Nix/home-manager)
- Re-link dotfiles: `homeshick link dotfiles`
- Check status: `homeshick status`
- Change to dotfiles repo: `homeshick cd dotfiles`

### Clipboard Utilities

Two sets of clipboard utilities are available:

1. Script-based: `clip-copy` and `clip-paste` (with hyphen)
   - Located in ~/bin
   - Cross-platform shell scripts
   - Usage: `echo "text" | clip-copy` and `clip-paste`

2. Function-based: `clipcopy` and `clippaste` (without hyphen)
   - Shell functions from Oh My Zsh's clipboard.zsh
   - Automatically selects appropriate clipboard command based on platform
   - Usage: `echo "text" | clipcopy` and `clippaste`

## Note Organization

- Obsidian notes stored in `/Users/kelvin/sync/notes/obsidian`
- Follow Obsidian markdown conventions (see obsidian/CLAUDE.md)
- Use descriptive filenames with .md extension

## Style Guidelines

### General

- Always add a newline at the end of all files
- Use descriptive filenames
- Prefer kebab-case for filenames (`meeting-notes.md`)
- Maximum line length: 100 characters when applicable

### Markdown

- Headers use # syntax (# for H1, ## for H2, etc.)
- Always surround Markdown headers with new lines
- Prefer - for bullet lists
- Use numbered lists for sequential items
- Code blocks with triple backticks