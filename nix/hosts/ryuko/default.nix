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

  k.host.name = "ryuko";

  system.stateVersion = "22.11";
  nixpkgs.hostPlatform = "x86_64-linux";

  k.modules.graphical.enable = false;

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
}
