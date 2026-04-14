{ pkgs, config, lib, inputs, ... }:

{
  # Nix is managed by Determinate Nix
  nix.enable = false;

  system.stateVersion = 6;
}
