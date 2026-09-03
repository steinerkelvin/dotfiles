# Dotfiles Repository Index

## Directory Structure

### Core Directories

- `/home/` - Dotfiles mirrored into the home directory
- `/modules/` - Flake-parts modules loaded automatically from the root flake
- `/modules/features/` - Reusable `flake.homeModules.*` building blocks
- `/modules/home/` - Concrete Home Manager configuration entrypoints
- `/modules/hosts/` - Host-level system configurations
- `/mac/` - macOS-specific configuration and setup notes
- `/packages/` - Related package workspaces
- `/old/` - Legacy configurations and archived reference material

### Configuration Files

- `flake.nix` - Nix flake entry point
- `bootstrap-nix.sh` - Installs Nix on a bare machine (standalone; nothing in the repo calls it)
- `justfile` - Task definitions for the `just` command runner

## Nix Configuration

### Reusable Feature Modules (`modules/features/`)

- `base-dev.nix` - Shared developer baseline
- `ai-skills.nix` - AI tooling skill layer
- `dep-opsec.nix` - Supply-chain cooldown defaults across package managers (`features.dep-opsec.*`)
- `identity.nix`, `work-identity.nix` - Personal git identity, plus a directory-scoped override for work checkouts
- `darwin-platform.nix` - macOS home shape, Homebrew shellenv, GNU userland, GUI launchd PATH agent
- `shell.nix`, `git.nix`, `nix.nix`, etc. - Feature-scoped Home Manager modules
- `graphical.nix` - Wayland desktop rice (DankMaterialShell + niri + Hyprland + Discord)
- `wl-kbptr.nix` - keyboard-driven mouse pointer for Wayland

### Reusable NixOS Modules (`modules/nixos/`)

- Identity-free `flake.nixosModules.*` host building blocks (profiles `base`/`server`/`desktop`/`vm-guest`; services `ssh`, `tailscale`, `avahi`, `podman`, `libvirt`, `syncthing`, `firewall`, `zfs-maintenance`; hardware/host `yubikey`, `zfs-boot`, `esp-sync`, `microvm-bridge`, `orbstack`)
- `yubikey.nix` - `services.pcscd` + udev rules for smartcard/PIV/age-plugin-yubikey
- Host-specific values are left as stock options for the consumer to set; no host identity, secrets, or device serials live here

### Home Manager Configurations (`modules/home/`)

- `targets/ci.nix` - Build-coverage target over the exported homeModules; not deployable
- `dev.nix` - Minimal dev/container-oriented profile

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
