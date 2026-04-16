# DOTFILES AGENTS GUIDE

## Repository Structure Index

See [INDEX.md](./INDEX.md) for a complete map of this repository's structure.

## Documentation Roles

- `README.md` is the human-facing entrypoint and quick command reference.
- `INDEX.md` is the current structure map.
- `AGENTS.md` is the main repo instruction file for coding agents and automation.
- `CLAUDE.md` should stay minimal and only hold Claude Code-specific notes when needed.

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
- In this repo, target entrypoints under `modules/home/targets/` are parts; deeper Home Manager profile composition should either live under an ignored `/_...` path or outside `modules/`.
- Use `import-tree.withLib ... .leafs` or `.files` only when you explicitly want file discovery outside module evaluation; do not use that as a workaround for mixed responsibilities in `modules/`.

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
