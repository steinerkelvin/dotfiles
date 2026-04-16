# DOTFILES AGENTS GUIDE

Read [CLAUDE.md](./CLAUDE.md) for the broader repo guide. This file keeps only the automation-critical invariants.

## Critical Invariant

- `flake.nix` should keep the plain dendritic loader for repo parts:

  ```nix
  imports = [
    inputs.home-manager.flakeModules.default
    (inputs.import-tree ./modules)
  ];
  ```

- Visible `.nix` files under `modules/` are flake-parts modules.

## Placement Rules

- Put reusable flake-parts modules in:
  - `modules/features/`
  - `modules/home/targets/`
  - `modules/hosts/`
  - top-level `modules/*.nix`
- Put Kelvin-specific Home Manager composition in `profiles/kelvin/`.
- Put helper code, plain Home Manager modules, and non-module assets outside visible `modules/` paths or under an ignored `/_.../` subtree.

## Avoid

- Do not add `filterNot` or `matchNot` rules in `flake.nix` to paper over mixed responsibilities.
- Do not leave plain Home Manager modules or assets in visible `modules/` paths.
- If a file under `modules/` is not meant to be auto-imported as a flake-parts module, treat that as a structure bug and move it.
