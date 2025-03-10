# DOTFILES REPOSITORY GUIDE

## Essential Directives

- When you see "RMB" in a message, the information is meant to be persisted to this CLAUDE.md file or equivalent persistent method/file specific for that kind of information
- "RMB" is a clear signal that the associated information must be remembered
- Always check for NEXT.md at the beginning of sessions and delete after reading
- Critical abbreviations: RMB (Remember), MK (Missclick), DUMP (Create transcript summary)
- Proactively search for context-specific CLAUDE.md files in the current directory and subdirectories
- CRITICAL: NEVER reference private files in public-facing content like PR descriptions or commit messages

## File Relationships
- This file contains dotfiles-specific information and guidelines
- See ~/CLAUDE.md for system-wide instructions and guidelines

## Repository Structure Index

See [INDEX.md](./INDEX.md) for a complete map of this repository's structure.

## System Configuration

### Path Configuration

- PATH entries should be added to `home.sessionPath` array in `nix/users/kelvin/hm/common.nix`

### NPM Global Packages

- NPM global packages are installed to ~/.npm-global (configured in home-manager)
- This setting is defined in dotfiles/nix/users/kelvin/hm/common.nix
- LOG.md in home directory tracks system configuration changes

### Session Restoration

- Try to read NEXT.md to restart a session, then delete the file
- This helps preserve context between Claude sessions when needed

## Assistant Directives

- When told to "Remember" something, update this CLAUDE.md file to persist the information
- This ensures important instructions, workflows, and guidelines persist between sessions
- This file contains information specific to dotfiles management
- See ~/CLAUDE.md for general home directory information
- Maintain the INDEX.md file when the repository structure changes
- Proactively search for inner CLAUDE.md files in subdirectories when working on a project
- Ask clarifying questions when uncertain about file locations or when encountering inconsistencies

## Important Files

- `~/dotfiles/TODO.md`: Main TODO list for dotfiles improvements and pending tasks
- `~/dotfiles/CLAUDE.md`: This file - dotfiles-specific instructions and documentation
- `~/dotfiles/INDEX.md`: Repository structure documentation
- IMPORTANT: Always run `homeshick link dotfiles` (or `dt link`) after adding new files to dotfiles/home
  - This is necessary to make new scripts and files available in the home directory
  - Reminder especially important for executable scripts added to home/bin
  - Never manually create symlinks from dotfiles/home/* to ~/; always use homeshick to manage these symlinks
  - New executables should be placed in dotfiles/home/bin/ and linked using homeshick
  - CRITICAL: New files must be committed to git before homeshick will link them
  - Workflow for adding a new file:
    1. Place the file in the appropriate location in dotfiles/home/
    2. Commit the new file to git
    3. Run homeshick link dotfiles to create the symlink
  - For renaming files: create and commit new file, remove old file, then run homeshick link
  - Always be comprehensive in commit messages, including all significant changes

## Homebrew Management

- Check package dependencies: `brew uses <package> --installed`
- Only add directly installed packages to `mac/my-brew-formulae.sh`, not dependencies
- Check all installed casks: `brew list --cask`
- Check all installed formulae: `brew list --formula`

## Homeshick Commands

- Link dotfiles: `homeshick link dotfiles` or `dt link`
- Check for updates: `homeshick check dotfiles` or `dt check`
- Pull updates: `homeshick pull dotfiles` or `dt pull`
- Add file to dotfiles: `homeshick track dotfiles <file-path>` or `dt track <file-path>`
  - File paths should be relative to your home directory
  - Example: `dt track .zshrc` to add .zshrc to dotfiles
  - Files will be tracked in the repo at `home/file-path`
- Change to dotfiles repo: `homeshick cd dotfiles` or `dt cd`
- Run `dt` without arguments to see help and usage examples

## Clipboard Utilities

Two sets of clipboard utilities are available:

1. Script-based: `clip-copy` and `clip-paste` (with hyphen)
   - Located in ~/bin
   - Cross-platform shell scripts
   - Usage: `echo "text" | clip-copy` and `clip-paste`

2. Function-based: `clipcopy` and `clippaste` (without hyphen)
   - Shell functions from Oh My Zsh's clipboard.zsh
   - Automatically selects appropriate clipboard command based on platform
   - Usage: `echo "text" | clipcopy` and `clippaste`

## Commands

- Check/lint code: `just fmt` or `nixpkgs-fmt path/to/file.nix`
- Check configurations: `just check` or `nix flake check`
- Run specific home-manager check: `just check-hm-linux` or `just check-hm-mac`
- Test workflows locally: `just test-workflow` or `just test-pr`
- Update Nix flake: `just update` or `nix flake update`
- Deploy NixOS: `sudo nixos-rebuild switch --flake .#hostname`
- Deploy home-manager: `./bootstrap-hm.sh`
- Apply macOS settings: `./mac/macos-settings.sh`

## JavaScript Runtime Environments

### Bun.js

- Installed via Nix/home-manager (packages.nix)
- Shell aliases in zsh.nix:
  - `b` - Run bun
  - `br` - Run scripts with bun run
  - `bx` - Execute packages with bun x
- Common commands:
  - `bun init` - Initialize a new project
  - `bun install` - Install dependencies
  - `bun add <package>` - Add a package
  - `bun remove <package>` - Remove a package
  - `bun run <script>` - Run a script from package.json
  - `bun test` - Run tests
  - `bun build` - Bundle source code

## Style Guidelines

### General

- Always add a newline at the end of a file
- Use 2-space indentation for all files
- Maximum line length: 100 characters
- Use kebab-case for filenames (`bootstrap-hm.sh`)
- Prefix personal utility scripts with `k-`
- Use descriptive variable/attribute names
- Annotate TODOs in comments

### Nix Configuration

- Never use `with pkgs;` syntax - always use explicit imports
- Group related configurations in modular files
- Add development tools to devShells in flake.nix
- Follow functional programming patterns
- Store sensitive data using agenix
- Use let/in blocks for local variables

### Shell Scripts Organization

- Simple/small shell functions can be defined directly in `nix/users/kelvin/hm/zsh.nix`
- Larger or more complex shell functions should go in `nix/users/kelvin/shell/` directory:
  1. Create a new .sh file for each script or related group of functions
  2. Add the file to `shell/default.nix` using the pattern:
     ```nix
     {
       script-name = readFile ./script-name.sh;
     }
     ```
  3. The scripts will be automatically included in zsh configuration
- Executable scripts that should be available in $PATH should go in `home/bin/`
  - Especially scripts that might be used non-interactively or in other scripts
  - Use proper shebangs (#!/bin/sh, #!/usr/bin/env python3, etc.)
  - Scripts in home/bin are automatically linked to ~/bin via homeshick

### Shell Utility Functions

- `try-echo` - Run a command and print a custom message only if it fails
  - Example: `try-echo "Build failed!" npm run build`
  - Located at `~/dotfiles/nix/users/kelvin/shell/try-echo.sh`
  - Includes completion support for command arguments

### Shell Script Guidelines

- Place utility functions in `nix/users/kelvin/shell/` directory
- Register in `shell/default.nix` using the pattern: `name = readFile ./name.sh`
- Use kebab-case for function and file names
- Include shell completion when appropriate
- For shell completion, use `_init_completion` and `_command_offset` helpers
- Documentation should be concise and non-redundant
- Don't assume how users manage their configurations (avoid instructions like "add to .zshrc")

### Shell Scripts

- Include shebang (`#!/bin/sh` or `#!/bin/bash`)
- Use `set -e` for error handling
- Document purpose with header comments
- Add shellcheck directives when needed

### Python Scripts

- Keep documentation close to code (in docstrings) rather than separate files
- Use PEP 723 with uv run for dependencies:
  ```python
  #!/usr/bin/env -S uv run --script
  # /// script
  # requires-python = ">=3.8"
  # dependencies = ["typer>=0.9.0", "rich>=13.4.2"]
  # ///
  ```
- Place executables in `home/bin/` with `k-` prefix
- Prefer typer+rich for CLI interfaces
