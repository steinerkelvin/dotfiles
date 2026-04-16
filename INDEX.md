# Dotfiles Repository Index

## Directory Structure

### Core Directories

- `/home/` - Dotfiles mirrored into the home directory
- `/modules/` - Flake-parts modules loaded automatically from the root flake
- `/modules/features/` - Reusable `flake.homeModules.*` building blocks
- `/modules/home/` - Concrete Home Manager configuration entrypoints
- `/modules/hosts/` - Host-level system configurations
- `/profiles/` - Kelvin-specific Home Manager profile composition kept outside the dendritic part tree
- `/mac/` - macOS-specific configuration and setup notes
- `/packages/` - Related package workspaces
- `/old/` - Legacy configurations and archived reference material

### Configuration Files

- `flake.nix` - Nix flake entry point
- `bootstrap-home-manager.sh` - Bootstraps Nix if needed, then activates the repo-pinned Home Manager config
- `justfile` - Task definitions for the `just` command runner

## Nix Configuration

### Reusable Feature Modules (`modules/features/`)

- `base-dev.nix` - Shared developer baseline
- `ai-skills.nix` - AI tooling skill layer
- `shell.nix`, `git.nix`, `nix.nix`, etc. - Feature-scoped Home Manager modules

### Home Manager Configurations (`modules/home/`)

- `targets/linux.nix` - Linux Home Manager activation target
- `targets/satsuki.nix` - macOS Home Manager activation target
- `dev.nix` - Minimal dev/container-oriented profile

### Kelvin-Specific Layer (`profiles/kelvin/`)

- `common.nix` - Shared personal composition
- `linux.nix` / `mac.nix` - Platform-specific user settings
- `zsh.nix`, `git.nix`, `nvim.nix`, `packages.nix` - Personal overlays on top of reusable modules

### Host Configurations (`modules/hosts/`)

- `satsuki.nix` - nix-darwin host configuration

### Shell Scripts (`home/bin/`)

- `k-*` scripts - Personal utilities
- `clip-copy`, `clip-paste` - Cross-platform clipboard helpers

## macOS Configuration

- `mac/macos-settings.sh` - macOS system preferences
- `mac/my-brew-formulae.sh` - Homebrew packages

## Raycast

- `/raycast/` - Script commands (standalone shell scripts with Raycast metadata)
- `/packages/raycast-kelvin/` - Raycast extension (TypeScript, `@raycast/api`)

## Utility Scripts (`home/bin/`)

- `clip-copy` - Copy to clipboard
- `clip-paste` - Paste from clipboard
- `docker-utils/` - Docker utilities

## Documentation

- `README.md` - Main repository documentation
- `CLAUDE.md` - Dotfiles management guidelines
- `kelvin-profile-plan.md` - Proposed reorganization plan for the Kelvin-specific HM profile layer
- `MIGRATION.md` - Historical notes from the flake-parts migration
- `TODO.md` - Planned improvements
