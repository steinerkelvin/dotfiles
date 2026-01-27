# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Commands run from the parent `dotfiles/` directory:

```sh
just fmt              # Format all .nix files with nixpkgs-fmt
just check            # Run nix flake check
just update           # Update flake inputs
just test-workflow    # Test GitHub Actions locally with act
just test-pr          # Test PR workflow locally with act
```

Deployment commands:

```sh
# Home-manager (standalone, macOS/Linux)
./deploy-home-manager.sh

# NixOS system rebuild
sudo nixos-rebuild switch --flake .#hostname
```

## Architecture

### Flake Structure

The flake (`dotfiles/flake.nix`) exports:
- **nixosConfigurations**: NixOS systems (nixia, mako-wsl)
- **darwinConfigurations**: macOS systems (satsuki)
- **homeConfigurations**: Standalone home-manager (kelvin for Linux, mac for macOS)
- **packages**: Custom packages from `nix/pkgs/`
- **devShells**: Development environment with just, nixd, nixpkgs-fmt, shellcheck

### Directory Layout

```
nix/
├── hosts/           # Host-specific system configurations
│   ├── common.nix   # Shared NixOS settings (SSH, locale, networking)
│   ├── pc.nix       # Desktop-specific (audio, printing)
│   ├── server.nix   # Server-specific settings
│   └── {name}/      # Per-host: default.nix, user.nix, hardware-configuration.nix
├── modules/         # Reusable NixOS modules (graphical, services, radeon)
├── users/kelvin/    # User configurations
│   └── hm/          # Home-manager modules (common.nix, linux.nix, mac.nix, etc.)
├── lib/             # Helper functions (mkKelvinUser, filterSupportedPkgs)
├── pkgs/            # Custom packages
└── shared.nix       # Shared constants (ports, SSH keys)
```

### Host Configuration Pattern

Each host follows this structure:
- `default.nix` - Imports common.nix + user.nix, sets `k.host.name` and `k.host.tags`
- `user.nix` - User account + home-manager imports

Custom options defined in `hosts/common.nix`:
- `k.host.name` - Hostname
- `k.host.domain` - Domain (default: nyala-komodo.ts.net)
- `k.host.tags.pc` - Enable desktop features
- `k.host.tags.server` - Enable server features

### Home-Manager Modules

User config in `users/kelvin/hm/`:
- `common.nix` - Base config for all platforms (imports packages.nix, zsh.nix, git.nix, nvim.nix)
- `linux.nix` - Linux-specific (sets home directory to /home/kelvin)
- `mac.nix` - macOS-specific (imports common.nix, homebrew integration)
- `graphical.nix` - Desktop environment configs (i3, sway, hyprland)

### Helper Functions

`lib/default.nix` provides:
- `mkKelvinUser` - Creates standard user + home-manager config with options for graphical, extraGroups, hmModules
- `filterSupportedPkgs` - Filters packages by platform support

### Shared Configuration

`shared.nix` contains:
- `ports` - Port assignments for services
- `keys.users.kelvin` - SSH public keys (different from agenix encryption keys in secrets/)
- `keys.kelvinAll` - All kelvin's keys for authorized_keys

## Style

- Never use `with pkgs;` - always use explicit references
- Format with `nixpkgs-fmt`
- Module toggles use `k.modules.{name}.enable` or `k.services.{name}.enable`
