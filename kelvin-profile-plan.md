# Kelvin Profile Reorg Plan

## Goal

Restructure `modules/home/_kelvin-hm/` into a clearer, first-class
Kelvin-specific profile layer without changing behavior, and make Home
Manager entrypoint naming consistent.

The current directory works, but it mixes several concerns:

- profile composition
- platform identity
- personal app configuration
- shell glue and inline assets
- inline assets consumed by modules

The plan is to make those layers explicit so future edits answer one
question quickly: is this reusable feature code, an exported Home
Manager entrypoint, or Kelvin-specific policy?

It also aims to stop mixing naming axes in `homeConfigurations`. Today
`kelvin` means "user/profile" while `mac` means "platform/target". The
target state should use one axis consistently.

## Current Problems

- `_kelvin-hm` reads like a temporary or internal directory, but it is
  actually the main personal profile layer.
- `common.nix` is doing both composition and policy.
- `linux.nix` and `mac.nix` repeat identity concerns like username and
  home directory.
- `zsh.nix` still mixes personal shell preferences with auxiliary shell
  glue (`vscode-remote.sh` and similar helper content).
- Embedded assets like `nvim.lua` and `vscode-remote.sh` are
  colocated, but not grouped by the modules that own them.

## Constraints

- No user-visible behavior drift.
- Keep `flake.homeModules.*` structure intact.
- Keep exported Home Manager entrypoints in `modules/home/`.
- Keep the migration reviewable in small commits.

## Target Shape

```text
modules/
  home/
    targets/
      linux.nix
      satsuki.nix
      dev.nix
    profiles/
      kelvin/
        default.nix
        identity.nix
        platform/
          linux.nix
          mac.nix
        apps/
          git.nix
          nvim.nix
          zsh.nix
          assets/
            nvim.lua
            vscode-remote.sh
        packages.nix
  features/
    homeshick.nix
    _homeshick/
      dt.sh
```

## Naming Model

Use different naming conventions for different layers:

- `profiles/<name>`: who the configuration belongs to
- `targets/<name>`: where the configuration activates
- `homeConfigurations.<name>`: exported activation targets

Under that model:

- `profiles/kelvin` is the personal profile layer
- `homeConfigurations.linux` is the Linux activation target
- `homeConfigurations.satsuki` is the macOS host activation target
- `homeConfigurations.dev` remains a special-purpose dev target

This keeps sibling `homeConfigurations.*` attrs answering the same
question: "which target am I activating?"

## Layering Rules

- `modules/features/*`: reusable Home Manager feature modules exposed as
  `flake.homeModules.*`
- `modules/features/homeshick.nix`: dedicated Homeshick integration
  module
- `modules/home/targets/*.nix`: exported Home Manager entrypoints only
- `modules/home/profiles/kelvin/*`: Kelvin-specific composition and
  preferences
- `apps/assets/`: non-Nix payloads owned by specific app modules

## Proposed Module Responsibilities

### `default.nix`

- Main Kelvin profile composition
- Imports reusable feature modules and Kelvin-only modules
- Sets profile-wide defaults like editor/visual editor
- Enables personal tool layers like Claude/Codex skills

### `identity.nix`

- Single source of truth for:
  - username
  - home directory
  - profile-level session path additions that are identity-related

This avoids repeating `username = "kelvin";` in multiple modules.

### `platform/linux.nix` and `platform/mac.nix`

- Platform-specific home directory or platform behavior only
- No app configuration unless it is truly platform-bound

These files should be thin. If a setting is not platform-specific, it
does not belong here.

### `apps/*.nix`

- Kelvin-only overrides or preferences for specific tools
- Examples:
  - Git identity
  - Neovim plugin/config glue
  - Zsh aliases and init content

## Migration Sequence

1. Rename exported Home Manager entrypoints by target:
   - `modules/home/kelvin.nix` -> `modules/home/targets/linux.nix`
   - `modules/home/mac.nix` -> `modules/home/targets/satsuki.nix`
2. Rename flake attrs:
   - `homeConfigurations.kelvin` -> `homeConfigurations.linux`
   - `homeConfigurations.mac` -> `homeConfigurations.satsuki`
3. Update scripts and docs to use target names.
4. Rename `_kelvin-hm` to `profiles/kelvin` with no behavior change.
5. Rename `common.nix` to `default.nix`.
6. Add `identity.nix` and move duplicated username/home-directory
   concerns into it.
7. Move `linux.nix` and `mac.nix` into `platform/`.
8. Move `git.nix`, `nvim.nix`, and `zsh.nix` into `apps/`.
9. Keep Homeshick as its own feature module for now.
10. Move `nvim.lua` and `vscode-remote.sh` into app-adjacent assets
   and update consumers.
11. Update target entrypoint imports.
12. Run `nix flake check --all-systems --no-build --keep-going`.
13. Update `INDEX.md` and any path references in docs.

## Commit Plan

### Commit 1

- Rename HM entrypoints and exported attrs by target
- Update bootstrap/deploy scripts and docs

### Commit 2

- Mechanical rename of `_kelvin-hm` to `profiles/kelvin`
- No logical changes

### Commit 3

- Introduce `default.nix` and `identity.nix`
- Remove duplicated identity definitions

### Commit 4

- Create `platform/`, `apps/`
- Move modules without changing behavior

### Commit 5

- Move remaining script/Lua assets next to the modules that own them
- Update `builtins.readFile` references

### Commit 6

- Clean up docs and comments

## Explicit Non-Goals

- No redesign of `modules/features/*`
- No changes to `flake.homeModules` naming
- No removal of Homeshick in this pass
- No attempt to make Kelvin profile reusable for other users
- No app-level config refactors beyond relocation and clearer ownership

## Review Questions

- Should `packages.nix` live beside the profile root, or under `apps/`?
  - try to split packages inside
- Do you want `identity.nix` to own all `home.sessionPath` additions, or
  only username/home-directory?
  - looks good for customized e.g. `$HOME/bin/`
- Do you want `apps/assets/` centralized, or should each app module keep
  its own adjacent asset files?
  - A: Keep adjacent.
- Do you prefer target names `linux` and `satsuki`, or should Linux also
  become host-specific once there is more than one real machine?
  - let's keep like this for now.

## Success Criteria

- The Kelvin profile layer is clearly legible from the tree alone.
- `homeConfigurations.*` uses one naming axis consistently.
- Identity values are defined once.
- App config, platform config, and compatibility glue are separate.
- `nix flake check --all-systems --no-build --keep-going` still passes.
- No user-visible change in activated Home Manager profiles.
