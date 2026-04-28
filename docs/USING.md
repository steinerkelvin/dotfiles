# Using this repo: advanced notes

The common cases (adding the input, single-feature import, `base-dev` import, deploy) are in the top-level [README](../README.md). This file covers what doesn't fit there.

## Embedding inside NixOS or nix-darwin

If you already have a NixOS / nix-darwin host config, wire the modules through `home-manager.users.<you>` instead of standalone home-manager:

```nix
home-manager.users.you = { ... }: {
  imports = [ inputs.kelvin-dotfiles.homeModules.dep-opsec ];
  features.dep-opsec.enable = true;
  home.stateVersion = "25.11";
};
```

The `home-manager` flake module must be loaded by the host config; see this repo's `flake.nix` for the canonical wiring.

## Channel mismatches

The flake tracks nixpkgs `nixos-25.11`. If your project pins to a different channel, override `inputs.nixpkgs.follows` and treat compatibility as best-effort. Modules occasionally use options that are stable-channel-only.

## Per-feature docs

- [`dep-opsec.md`](dep-opsec.md): supply-chain release-age cooldowns
- [`passage.md`](passage.md): multi-recipient secrets store

## Caveats

- Some features assume macOS (e.g., `age-plugin-se` for the Secure Enclave). Check the module header before importing on Linux.
- `base-dev` pulls a non-trivial closure. Importing single features is cheaper if you don't want the full baseline.
