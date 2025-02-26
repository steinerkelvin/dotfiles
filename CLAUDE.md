# DOTFILES REPOSITORY GUIDE

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

### Shell Scripts

- Include shebang (`#!/bin/sh` or `#!/bin/bash`)
- Use `set -e` for error handling
- Document purpose with header comments
- Add shellcheck directives when needed
