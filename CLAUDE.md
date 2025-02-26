# DOTFILES REPOSITORY GUIDE

## Repository Structure Index

See [INDEX.md](./INDEX.md) for a complete map of this repository's structure.

## Assistant Directives

- When told to "Remember" something, update this CLAUDE.md file to persist the information
- This ensures important instructions, workflows, and guidelines persist between sessions
- This file contains information specific to dotfiles management
- See ~/CLAUDE.md for general home directory information
- Maintain the INDEX.md file when the repository structure changes

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

### Shell Scripts

- Include shebang (`#!/bin/sh` or `#!/bin/bash`)
- Use `set -e` for error handling
- Document purpose with header comments
- Add shellcheck directives when needed
