# Ryuko - WSL host configuration

{ pkgs, config, lib, inputs, ... }:

let
  nixos-wsl = inputs.nixos-wsl;
in
{
  imports = [
    nixos-wsl.nixosModules.wsl
    ../common.nix
    ./user.nix
  ];

  k.host.name = "ryuko";

  system.stateVersion = "23.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  k.modules.graphical.enable = false;

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "kelvin";
    startMenuLaunchers = true;
  };
}
