# Reusable home-manager module: developer extras on top of base-dev
# (currently AI skill definitions for claude-code and codex).
# Exposed so external consumers can import it via
# `inputs.kelvin-dotfiles.homeModules.dev`.

{ ... }:

{
  flake.homeModules.dev = ../../nix/home/dev;
}
