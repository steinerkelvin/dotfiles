{ pkgs, config, lib, inputs, ... }:

let
  nixos-wsl = inputs.nixos-wsl;
  vscode-server = inputs.vscode-server;
in
{
  imports = [
    nixos-wsl.nixosModules.wsl
    vscode-server.nixosModules.default
    ../common.nix
  ];

  system.stateVersion = "22.11";

  k.name = "ryuko";
  nixpkgs.hostPlatform = "x86_64-linux";

  modules.graphical.enable = true;

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "kelvin";
    startMenuLaunchers = true;
  };

  services.vscode-server = {
    enable = true;
    installPath = "~/.vscode-server-insiders";
  };

  # # Enable nix flakes
  # nix.package = pkgs.nixFlakes;
  # nix.extraOptions = ''
  #   experimental-features = nix-command flakes
  # '';
}

