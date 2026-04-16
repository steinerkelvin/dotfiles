# steinerkelvin/dotfiles

Personal Nix flake for Home Manager and nix-darwin.

The repo keeps the flake-parts dendritic tree in [`modules/`](modules/) and the Kelvin-specific Home Manager composition in [`profiles/kelvin/`](profiles/kelvin/).

## Main Entry Points

- [`flake.nix`](flake.nix) - Flake entry point with the plain `import-tree` loader
- [`modules/features/`](modules/features/) - Reusable `flake.homeModules.*` building blocks
- [`modules/home/targets/`](modules/home/targets/) - Concrete Home Manager activation targets
- [`profiles/kelvin/`](profiles/kelvin/) - Kelvin-owned profile composition, with app modules under `apps/`
- [`modules/hosts/satsuki.nix`](modules/hosts/satsuki.nix) - nix-darwin host config
- [`bootstrap-home-manager.sh`](bootstrap-home-manager.sh) - Bootstrap and deploy script

## Common Commands

- `just check`
- `just check-hm-linux`
- `just check-hm-mac`
- `just lint`
- `./bootstrap-home-manager.sh`

## More Docs

- [`INDEX.md`](INDEX.md) - Current structure map
- [`AGENTS.md`](AGENTS.md) - Repo-wide instructions for coding agents
- [`CLAUDE.md`](CLAUDE.md) - Claude Code-specific notes and pointer to `AGENTS.md`
- [`mac/README.md`](mac/README.md) - macOS-specific notes
