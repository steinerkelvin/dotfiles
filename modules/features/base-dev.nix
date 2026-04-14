# Reusable home-manager module: base developer setup (shell, git, packages).
# Exposed so external consumers can import it via
# `inputs.kelvin-dotfiles.homeModules.base-dev`.
#
# The option is declared by home-manager.flakeModules.default which is
# imported in the root flake.nix.

{ ... }:

{
  flake.homeModules.base-dev = ../../nix/home/base-dev;
}
