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

- `default.nix` - Shared personal composition entrypoint
- `identity.nix` - Username, Git identity, and profile-wide identity defaults
- `apps/` - App-specific Kelvin-owned modules and adjacent assets
- `apps/claude-code.nix` - Claude Code enablement and local feature toggles
- `apps/nvim/` - Neovim module and adjacent Lua config
- `platform/` - Platform-only profile settings
- `zsh.nix`, `packages.nix` - Personal overlays on top of reusable modules
- `vscode-remote.sh` - Helper script referenced by the Kelvin profile layer

### Host Configurations (`modules/hosts/`)

- `satsuki.nix` - nix-darwin host configuration

### Shell Scripts (`home/bin/`)

- `k-*` scripts - Personal utilities
- `k-shell-helper` - Shell wrapper re-entry for kitty (see
  `home/.config/kitty/shell-reentry.md` for the protocol)
- `clip-copy`, `clip-paste` - Cross-platform clipboard helpers

### Kitty

- `home/.config/kitty/kitty.conf` - Kitty config
- `home/.config/kitty/shell_reentry.py` - Custom kitten that re-enters wrapped
  shells on new-tab / new-window keybinds
- `home/.config/kitty/shell-reentry.md` - `K_SHELL_REENTRY` protocol doc

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

- `README.md` - High-level entrypoints and common commands
- `INDEX.md` - This structure map
- `AGENTS.md` - Repo-wide instructions for coding agents
- `CLAUDE.md` - Minimal Claude Code-specific pointer file
- `TODO.md` - Current backlog and longer-lived cleanup ideas
