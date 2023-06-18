{ pkgs, config, lib, inputs, ... }:

let
  nixos-wsl = inputs.nixos-wsl;
in
{
  imports = [
    nixos-wsl.nixosModules.wsl
    ../common.nix
  ];

  system.stateVersion = "22.11";

  k.name = "ryuko";
  nixpkgs.hostPlatform = "x86_64-linux";

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "kelvin";
    startMenuLaunchers = true;
  };

  # # Enable nix flakes
  # nix.package = pkgs.nixFlakes;
  # nix.extraOptions = ''
  #   experimental-features = nix-command flakes
  # '';
}

