# Minimal flake importing `kelvin-dotfiles.homeModules.*`

A single-user home-manager configuration that pulls one feature from `github:steinerkelvin/dotfiles`. Edit `home.nix` to set your username + home directory, then:

```sh
nix flake check
nix build .#homeConfigurations.example.activationPackage --no-link
home-manager switch --flake .#example
```

To swap the single-feature import for the `base-dev` baseline, change the line in `flake.nix` from:

```nix
kelvin-dotfiles.homeModules.dep-opsec
```

to:

```nix
kelvin-dotfiles.homeModules.base-dev
```

and remove the matching `features.<x>.enable = true;` line in `home.nix`.

See [`../../docs/USING.md`](../../docs/USING.md) for the full import recipe and the list of available `homeModules.*`.
