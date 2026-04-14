# Reusable home-manager modules exposed as flake outputs so external
# consumers can import them from another flake via
# `inputs.kelvin-dotfiles.homeModules.base-dev` etc.
#
# The option is declared by home-manager.flakeModules.default which is
# imported in the root flake.nix.

{ ... }:

{
  flake.homeModules = {
    base-dev = ../home-modules/base-dev;
    dev = ../home-modules/dev;
  };
}
