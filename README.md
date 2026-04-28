# steinerkelvin/dotfiles

Personal Nix flake for Home Manager and nix-darwin. The home-manager modules in `modules/features/` are written to be importable from another flake: pull a single feature, or take `base-dev` as a baseline.

## What's here

27 single-tool features (zsh, starship, git, direnv, atuin, build-tools, nix, ...) plus a few that need extra setup or have their own docs:

- `passage`: `age`-based secrets store with Secure Enclave + YubiKey recipients.
- `dep-opsec`: supply-chain release-age cooldowns across bun, npm, pnpm, yarn, uv, deno. Refuses to install package versions younger than 7 days (configurable), so you don't run yesterday's compromised publish before the registry yanks it. Doesn't help against long-running infiltration; see [`docs/dep-opsec.md`](docs/dep-opsec.md) for the threat model and per-ecosystem options.
- `claude-hooks` and `ai-skills`: Claude Code configuration.
- `age-plugin-se` and `age-plugin-yubikey`: hardware identities `passage` consumes.

One meta-module, `base-dev`, composes the team-neutral features (no AI tooling, no personal layers) into a default dev environment. It pulls in `dep-opsec` and enables it; the rest of the security-leaning features are opt-in.

The flake tracks nixpkgs `nixos-25.11` and `home-manager release-25.11`. macOS is the primary target; the Linux modules get less testing.

## Using this from your own flake

Add the input:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  home-manager = {
    url = "github:nix-community/home-manager/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  kelvin-dotfiles = {
    url = "github:steinerkelvin/dotfiles";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Pin to a revision (`url = "github:steinerkelvin/dotfiles?rev=<sha>"`) if you want reproducibility.

Import a single feature:

```nix
homeConfigurations.you = home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs { system = "aarch64-darwin"; };
  modules = [
    kelvin-dotfiles.homeModules.dep-opsec
    ({ ... }: {
      home.username = "you";
      home.homeDirectory = "/Users/you";
      home.stateVersion = "25.11";
      features.dep-opsec.enable = true;
    })
  ];
};
```

Import the `base-dev` baseline instead:

```nix
modules = [
  kelvin-dotfiles.homeModules.base-dev
  ({ ... }: {
    home.username = "you";
    home.homeDirectory = "/Users/you";
    home.stateVersion = "25.11";
  })
];
```

Deploy:

```sh
home-manager switch --flake .#you
```

A working sample lives at [`examples/minimal-flake/`](examples/minimal-flake), verifiable with `nix flake check` and `nix build .#homeConfigurations.example.activationPackage`.

For embedding inside an existing NixOS or nix-darwin host, and channel-mismatch notes, see [`docs/USING.md`](docs/USING.md).

## Available modules

Single-tool features: `npm`, `python`, `rust`, `nix`, `direnv`, `zsh`, `git`, `shell`, `editors`, `atuin`, `starship`, `scripting`, `remote`, `net`, `net-utils`, `file-utils`, `build-tools`, `sysmon`, `secrets`, `passage`, `age-plugin-se`, `age-plugin-yubikey`, `email`, `homeshick`, `claude-hooks`, `ai-skills`, `dep-opsec`.

Meta-module: `base-dev`.

For the complete list, run `nix flake show github:steinerkelvin/dotfiles`.

## Working on this repo

If you cloned to hack on it directly:

- [`flake.nix`](flake.nix): flake entry, uses `import-tree` over `modules/`.
- [`modules/features/`](modules/features/): reusable `flake.homeModules.*`.
- [`modules/home/targets/`](modules/home/targets/): concrete activation targets.
- [`profiles/kelvin/`](profiles/kelvin/): Kelvin's profile (not part of the public surface).
- [`modules/hosts/satsuki.nix`](modules/hosts/satsuki.nix): nix-darwin host config.
- [`bootstrap-home-manager.sh`](bootstrap-home-manager.sh): bootstrap + deploy.

Common commands: `just check`, `just check-hm-linux`, `just check-hm-mac`, `just lint`, `./bootstrap-home-manager.sh`.

## More docs

- [`INDEX.md`](INDEX.md): structure map
- [`AGENTS.md`](AGENTS.md): repo-wide instructions for coding agents
- [`CLAUDE.md`](CLAUDE.md): Claude Code notes
- [`docs/USING.md`](docs/USING.md): NixOS/nix-darwin embedding, channel notes
- [`docs/dep-opsec.md`](docs/dep-opsec.md): supply-chain release-age cooldowns
- [`docs/passage.md`](docs/passage.md): multi-recipient secrets store
- [`mac/README.md`](mac/README.md): macOS-specific notes
