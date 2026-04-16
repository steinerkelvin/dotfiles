# DOTFILES AGENTS GUIDE

This repo follows the Dendritic pattern for flake-parts.

## Core Rule

- `flake.nix` should keep the plain dendritic loader for repo parts:

  ```nix
  imports = [
    inputs.home-manager.flakeModules.default
    (inputs.import-tree ./modules)
  ];
  ```

- Read that as: visible `.nix` files under `modules/` are flake-parts modules.

## What Belongs In `modules/`

- Flake-parts modules only.
- Concrete examples in this repo:
  - `modules/features/*.nix`
  - `modules/home/targets/*.nix`
  - `modules/hosts/*.nix`
  - top-level flake-parts modules like `modules/checks.nix`

## What Does Not Belong In Visible `modules/` Paths

- Plain Home Manager modules that are only imported by a target
- Helper libraries
- Non-module assets
- Internal profile composition trees

## Where To Put Non-Part Code

- Use `/_.../` under `modules/` for helper code that must stay nearby and must not be auto-imported.
- Otherwise move the tree outside `modules/`.
- Do not paper over mixed trees with `filterNot` or `matchNot` in `flake.nix` unless there is a very deliberate repo-wide reason.

## import-tree Notes

- Upstream `import-tree` ignores paths containing `/_` by default.
- `filter`, `filterNot`, `match`, and `matchNot` are real tools, but they should not replace clear directory semantics.
- `withLib`, `leafs`, and `files` are for file discovery outside module evaluation, not for weakening the part-tree boundary.

## Practical Repo Rule

- If a file lives under `modules/` and is not meant to be a flake-parts part, that is usually a structure bug.
- Fix the tree shape before adding loader exceptions.
