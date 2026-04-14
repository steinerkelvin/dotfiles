# flake.nix dendritic migration

## Goal

Migrate `flake.nix` from a monolithic `rec { outputs... }` layout to the
**dendritic** pattern: `flake-parts` + `vic/import-tree` auto-loading every
`.nix` file under `modules/`, with the root `flake.nix` reduced to a
~15-line bootstrap. Reference:
[`mightyiam/infra`](https://github.com/mightyiam/infra).

Why now: we want to add a devcontainer module later and consume this
flake as an input from other repos. Both are cleaner when each output
lives in its own auto-loaded module instead of a central switchboard.

In scope:

- Restructure `flake.nix` and create `modules/` + `home-modules/` trees.
- Preserve every current output with byte-identical drvPaths.
- Keep `deploy-home-manager.sh` working. (Future: a `just deploy-hm`
  recipe and a `bootstrap-home-manager.sh` for unconfigured hosts is
  welcome, but the existing script must keep working as-is.)
- Move `nix/profiles/base-dev/` and `nix/profiles/dev/` to
  `home-modules/` at the repo root and expose them as
  `flake.homeModules` for external consumers.

Out of scope:

- Bumping any existing input (`flake-parts` + `import-tree` are the
  only new entries in `flake.lock`).
- Any further restructuring of `nix/users/kelvin/hm/*` or
  `nix/hosts/satsuki/`.
- A new secrets layer. (git-crypt was removed as dormant; whatever
  replaces it will be set up separately.)

## Pre-migration baseline (post-cleanup)

Captured 2026-04-14 on `satsuki` (aarch64-darwin) against master
after commits `Delete dead NixOS modules` → `Remove dormant git-crypt
apparatus` landed. The cleanup commits pruned everything that was dead
weight: the whole nixia NixOS host and its modules, the
discord-krisp-patch pkg and script, git-crypt, and the `nixos-wsl` and
`k-ddns` inputs that only existed to feed nixia.

Every drvPath below was verified to match the drvPaths captured before
any cleanup commit ran -- cleanup was lossless for the live outputs.

### `nix flake show --all-systems`

```
git+file:///Users/kelvin/code/dotfiles
├───checks
│   ├───aarch64-darwin
│   │   └───mac: CI test
│   ├───aarch64-linux
│   └───x86_64-linux
│       ├───dev: CI test
│       └───kelvin: CI test
├───darwinConfigurations
│   └───satsuki: nix-darwin configuration
├───devShells
│   ├───aarch64-darwin
│   │   └───default: development environment
│   ├───aarch64-linux
│   │   └───default: development environment
│   └───x86_64-linux
│       └───default: development environment
└───homeConfigurations
    ├───dev: Home Manager configuration
    ├───kelvin: Home Manager configuration
    └───mac: Home Manager configuration
```

No more `nixosConfigurations`, no more `nixosModules`, no more
`packages`.

### `nix flake check --no-build --keep-going` (from satsuki)

```
✅ devShells.aarch64-darwin.default (build skipped)
✅ darwinConfigurations.satsuki (build skipped)
✅ homeConfigurations.mac (build skipped)
✅ checks.aarch64-darwin.mac
warning: The check omitted these incompatible systems: aarch64-linux, x86_64-linux
```

### drvPath equivalence oracle

| Output                                        | drvPath                                                                       |
| --------------------------------------------- | ----------------------------------------------------------------------------- |
| `darwinConfigurations.satsuki.system`         | `/nix/store/y7n89sp5wvp1xxd3r6d6ckcqjb8fygn5-darwin-system-25.11.ebec37a.drv` |
| `homeConfigurations.kelvin.activationPackage` | `/nix/store/af75sh0ycpcbydmmvml23rmdbv2vb19h-home-manager-generation.drv`     |
| `homeConfigurations.mac.activationPackage`    | `/nix/store/0znv7kwkvs10zka4d6c9n4h605njmw1z-home-manager-generation.drv`     |
| `homeConfigurations.dev.activationPackage`    | `/nix/store/83c4k945j1dc3aa5y5f36qyz67m1x03i-home-manager-generation.drv`     |
| `devShells.x86_64-linux.default`              | `/nix/store/aa34klp9kjnskdh3f0nyagvriishfgji-nix-shell.drv`                   |
| `devShells.aarch64-linux.default`             | `/nix/store/qfla4fdjhmsaa6737q02nx623g3xnfby-nix-shell.drv`                   |
| `devShells.aarch64-darwin.default`            | `/nix/store/0hwddwryn9agyxz2ircdbzxnwanqq0hq-nix-shell.drv`                   |

These 7 are the post-migration equivalence oracle.

## Target module tree

Flake-parts modules live under `modules/` at the **repo root**. Shared
home-manager modules (base-dev, dev) live under `home-modules/` at the
repo root and are exposed to external consumers via
`flake.homeModules`.

```
dotfiles/
  flake.nix                  # ~15-line bootstrap
  flake.lock
  modules/                   # flake-parts modules (auto-loaded)
    systems.nix              # flake-parts systems = [...]
    overlays.nix             # _module.args.overlays.darwinDirenv
    devshell.nix             # perSystem.devShells.default
    checks.nix               # perSystem.checks (from homeConfigurations)
    home-modules.nix         # flake.homeModules.{base-dev, dev}
    hosts/
      satsuki.nix            # flake.darwinConfigurations.satsuki
    home/
      kelvin.nix             # flake.homeConfigurations.kelvin
      mac.nix                # flake.homeConfigurations.mac
      dev.nix                # flake.homeConfigurations.dev
  home-modules/              # reusable home-manager modules
    base-dev/                # (moved from nix/profiles/base-dev/)
      default.nix
      git.nix
      options.nix
      packages.nix
      shell/
        vscode-remote.sh
      zsh.nix
    dev/                     # (moved from nix/profiles/dev/)
      default.nix
      ai-skills.nix
      ai-skills/
  nix/                       # unchanged live pieces
    hosts/satsuki/           # darwin host module
    users/kelvin/
      hm/                    # common.nix, linux.nix, mac.nix, + non-graphical pieces
      shell/                 # dt.sh injected into zsh
      ssh-keys.nix           # user-scoped public keys
  deploy-home-manager.sh     # untouched
  old/                       # archived reference material
    nixia/                   # the whole Linux NixOS stack
    pkgs/discord-krisp-patch/
```

`home-manager.flakeModules.default` is imported directly from
`flake.nix` because home-manager release-25.11 ships it; it declares
`flake.homeConfigurations` as `lazyAttrsOf raw` with proper merging,
so each `modules/home/*.nix` can add its own entry cleanly.

`darwinConfigurations` has no first-party flake-parts module in
`nix-darwin` 25.11. With only one config (`satsuki`), no merging is
required, so a single `modules/hosts/satsuki.nix` sets
`flake.darwinConfigurations.satsuki = ...` directly.

## Mapping: current `flake.nix` → new module

| Current `flake.nix` binding                                         | New location                             |
| ------------------------------------------------------------------- | ---------------------------------------- |
| `inputs = { ... }`                                                  | stays in `flake.nix` (+ flake-parts + import-tree) |
| `supportedPlatforms` + `forAllPlatforms`                            | `modules/systems.nix`                    |
| `darwinDirenvWorkaround` overlay                                    | `modules/overlays.nix`                   |
| `devShells` output                                                  | `modules/devshell.nix`                   |
| `darwinConfigurations.satsuki` output                               | `modules/hosts/satsuki.nix`              |
| `homeConfigurations.kelvin` output                                  | `modules/home/kelvin.nix`                |
| `homeConfigurations.mac` output                                     | `modules/home/mac.nix`                   |
| `homeConfigurations.dev` output                                     | `modules/home/dev.nix`                   |
| `checks` output                                                     | `modules/checks.nix`                     |
| `nix/profiles/base-dev/`                                            | `home-modules/base-dev/` (moved)         |
| `nix/profiles/dev/`                                                 | `home-modules/dev/` (moved)              |
| -                                                                   | `modules/home-modules.nix` exposes them as `flake.homeModules` |

## Target root `flake.nix`

```nix
{
  description = "Kelvin's personal flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.home-manager.flakeModules.default
        (inputs.import-tree ./modules)
      ];
    };
}
```

## Commit sequence

Each commit must leave `nix flake check` passing (as observed from
satsuki).

**Cleanup (done — landed as commits `163a341` → `78398a4`)**
1. Delete dead NixOS modules and packages.
2. Archive nixia stack and prune dead home-manager aggregators.
3. Archive discord-krisp-patch and remove packages/lib infrastructure.
4. Remove dead flake inputs nixos-wsl and k-ddns.
5. Remove dormant git-crypt apparatus.

**Baseline refresh (this commit)**
6. Refresh MIGRATION.md with post-cleanup baseline + new target tree.

**Migration**
7. Add flake-parts and vic/import-tree inputs (no structural change).
8. Switch to mkFlake with a transitional `modules/_transition.nix`
   that holds all current outputs verbatim.
9. Extract systems, overlays, devshell into their own auto-loaded
   modules.
10. Extract the satsuki host.
11. Extract the three home configurations.
12. Move `nix/profiles/base-dev/` and `nix/profiles/dev/` to
    `home-modules/` and add `modules/home-modules.nix` exposing them.
13. Extract checks.
14. Delete the now-empty `_transition.nix`. Finalize
    `flake.nix`.

## Rollback

Every commit leaves `nix flake check` passing, so rollback is
`git revert <commit>`. Any drvPath drift vs the post-cleanup oracle is
a bug in that commit -- fix-forward or revert.

## Success criteria

- `nix flake show --all-systems` matches the post-cleanup tree above.
- Every drvPath in the oracle matches byte-for-byte.
- `./deploy-home-manager.sh` resolves `.#kelvin` on Linux and `.#mac`
  on Darwin to the same activation packages as before.
- Root `flake.nix` is ≤ ~25 lines of content.
- `flake.homeModules.base-dev` and `flake.homeModules.dev` are
  addressable from a consumer flake.
