# Home Directory Guide

## Assistant Directives

- When told to "Remember" something, update this CLAUDE.md file to persist the information
- This ensures important instructions, workflows, and guidelines persist between sessions
- If working in a directory with its own CLAUDE.md file, update that specific CLAUDE.md instead when appropriate
- For example, when making changes to dotfiles, update ~/dotfiles/CLAUDE.md
- After completing tasks, proactively update the relevant CLAUDE.md file with new information
- Keep information in the most appropriate CLAUDE.md file based on context and relevance
- Proactively build and maintain directory indexes in CLAUDE.md files or separate INDEX.md files
- Review and rebuild indexes when repositories/folders change significantly
- When completing tasks from TODO.md files, remember to update those files to reflect completed work

## Directory Structure

- `/Users/kelvin/dotfiles` - Configuration files and system setup
- `/Users/kelvin/sync/notes/obsidian` - Obsidian vault for note-taking
- `~/.homesick/repos` - Homeshick repository links
- Add more important directories as discovered

## Available Commands

### Using Nix Shell for Temporary Access

- Access commands without installing: `nix shell nixpkgs#package-name`
- Run a command once: `nix-shell -p package-name --run "command"`
- Example: `nix shell nixpkgs#dtach` or `nix-shell -p dtach --run "dtach --help"`

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
- `abduco` - Terminal session manager (lightweight alternative to tmux/screen)
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
- `difft` - Structural diff tool that understands syntax

## Dotfiles Management

- Dotfiles managed using homeshick (installed via Nix/home-manager)
- See ~/dotfiles/CLAUDE.md for detailed dotfiles commands and guidelines
- Contains documentation for homeshick commands, clipboard utilities, and more

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