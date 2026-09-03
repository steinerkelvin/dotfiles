# DOTFILES AGENTS GUIDE

## Repository Structure Index

See [INDEX.md](./INDEX.md) for a complete map of this repository's structure.

## Documentation Roles

- `README.md` is the human-facing entrypoint and quick command reference.
- `INDEX.md` is the current structure map.
- `AGENTS.md` is the main repo instruction file for coding agents and automation.
- `CLAUDE.md` should stay minimal and only hold Claude Code-specific notes when needed.

## This Repo Is Public

- Everything here is published. Nothing that lands in this repo -- code comments, docs,
  or commit messages -- may name the private downstream flake that consumes it, its
  internal module names, its host names, or absolute paths under a real home directory.
- Say "downstream", "the consuming flake", or "the consumer" instead. Describe the
  interface (`homeModules.*`, `nixosModules.*`), never the topology behind it.
- Commit messages are the worst case: they cannot be corrected after a push without
  rewriting history. Check the message as well as the diff.

## Dendritic Pattern

- This repo uses the Dendritic pattern via `import-tree` with flake-parts.
- The intended flake shape is the plain pattern from the upstream docs:

  ```nix
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.home-manager.flakeModules.default
      (inputs.import-tree ./modules)
    ];
  };
  ```

- Treat `modules/` as the dendritic part tree.
- Every auto-imported `.nix` file under `modules/` must therefore be a valid flake-parts module.
- Do not place plain Home Manager modules, helper modules, data files, or private implementation trees directly under visible paths in `modules/` unless they are meant to be imported as flake-parts parts.
- Upstream `import-tree` ignores paths containing `/_` by default.
- Use underscore-prefixed directories inside `modules/` for helper code that must live nearby but must not be auto-imported.
- If a subtree is not a flake-parts part tree, prefer moving it outside `modules/` rather than adding ad hoc `filterNot` rules in `flake.nix`.
- In this repo, target entrypoints under `modules/home/targets/` are parts. Plain Home Manager modules that need a home under `modules/` must be wrapped as `flake.homeModules.*` (see `modules/features/darwin-platform.nix`) or hidden behind an ignored `/_...` path.
- Use `import-tree.withLib ... .leafs` or `.files` only when you explicitly want file discovery outside module evaluation; do not use that as a workaround for mixed responsibilities in `modules/`.

## Deploy

- **Nothing deploys from this repo.** It is a module library. The standalone
  `homeConfigurations.linux` target and `bootstrap-home-manager.sh` were removed on
  2026-09-03: they were a second home-manager config for the same `$HOME` that no
  machine ever deployed from, diverging silently from the real one.
- Both the Darwin and the Linux machines are configured downstream, by a separate flake
  that imports `homeModules.*` (and, on Darwin, bundles home-manager via
  `home-manager.darwinModules.default`). Deploy from there, not from here.
- Dry-check that the exported modules still build: `just check-hm` (builds
  `homeConfigurations.ci-linux`, a coverage target, not something to activate).
- Downstream pins this repo as a flake input, so a change here only reaches a machine
  after push + input bump on that side.

## Style Guidelines

### Nix Configuration

- Never use `with pkgs;` syntax - always use explicit imports

### Shell Script Guidelines

- Use kebab-case for function and file names
- Include shell completion when appropriate

### Shell Scripts

- Include shebang (`#!/bin/sh` or `#!/usr/bin/env python3`)
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

- Prefer typer+rich for CLI interfaces
