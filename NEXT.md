# NEXT

Running handoff for the next dotfiles session. Keep only pending work here.

## Immediate next step

- Decide whether shell-specific profile code should get its own subtree now that app-specific config lives under `profiles/kelvin/apps/`.

## Most likely next refactor

- `profiles/kelvin/` is flatter than ideal; shell/runtime-specific modules are still mixed together at the top level.
- A reasonable next pass would be:
  - move `zsh.nix` and any shell-owned helpers into a `shell/` subtree
  - decide whether `packages.nix` should stay top-level as profile composition or move under a clearer `core/` or `runtime/` split

## Useful check

- Search for remaining flat Kelvin profile files with:
  - `find profiles/kelvin -maxdepth 1 -type f | sort`
