{ pkgs, config, lib, inputs, ... }:

let nix-darwin = inputs.nix-darwin;
in
{
  imports = [
    nix-darwin.nixosModules.darwin-common
  ];

  # Nix is managed by Determinate Nix
  nix.enable = false;

}
