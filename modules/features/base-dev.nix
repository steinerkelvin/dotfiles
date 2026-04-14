# Reusable home-manager module: base developer kernel
# (zsh, git, direnv, atuin, packages, common sessionPath/Variables).
# Team-neutral and Kelvin-neutral by design -- personal layers like
# AI tooling live in sibling features (see ai-skills.nix).
#
# Exposed so external consumers can import it via
# `inputs.kelvin-dotfiles.homeModules.base-dev`.
#
# The option is declared by home-manager.flakeModules.default which is
# imported in the root flake.nix.

{ ... }:

{
  flake.homeModules.base-dev = ../../nix/home/base-dev;
}
