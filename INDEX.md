# Dotfiles Repository Index

## Directory Structure

### Core Directories

- `/home/` - Dotfiles to be symlinked to home directory
- `/nix/` - Nix configuration files for NixOS and home-manager
- `/mac/` - macOS-specific configurations
- `/scripts/` - Utility scripts
- `/old/` - Legacy configurations (archived)

### Configuration Files

- `flake.nix` - Nix flake entry point
- `deploy-hm.sh` - Script to deploy home-manager configuration
- `justfile` - Task definitions for the `just` command runner

## Nix Configuration

### Home Manager Modules (`nix/users/kelvin/hm/`)

- `zsh.nix` - ZSH shell configuration
- `nvim.nix` - Neovim configuration
- `packages.nix` - User packages
- `i3.nix` - i3 window manager config
- `direnv.nix` - direnv configuration
- `git.nix` - Git configuration

### Shell Scripts (`nix/users/kelvin/shell/`)

- `dt.sh` - Dotfiles management utility

### NixOS Host Configurations (`nix/hosts/`)

- `common.nix` - Shared configuration
- `nixia/` - Configuration for 'nixia' host
- `ryuko/` - Configuration for 'ryuko' host
- `kazuma/` - Configuration for 'kazuma' host
- `stratus/` - Configuration for 'stratus' host

## macOS Configuration

- `mac/macos-settings.sh` - macOS system preferences
- `mac/my-brew-formulae.sh` - Homebrew packages

## Utility Scripts (`home/bin/`)

- `clip-copy` - Copy to clipboard
- `clip-paste` - Paste from clipboard
- `docker-utils/` - Docker utilities

## Documentation

- `README.md` - Main repository documentation
- `CLAUDE.md` - Dotfiles management guidelines
- `TODO.md` - Planned improvements
