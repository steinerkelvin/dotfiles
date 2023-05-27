{ lib, config, pkgs, nixos-wsl, ... }:

{
  imports = [
    ../common.nix
    nixos-wsl.nixosModules.wsl  # TODO: causing infinite recursion
  ];

  config = {
    k.name = "ryuko";
    k.kind = "bare";

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # wsl = {
    #   enable = true;
    #   automountPath = "/mnt";
    #   defaultUser = "nixos";
    #   startMenuLaunchers = true;

    #   # Enable native Docker support
    #   # docker-native.enable = true;

    #   # Enable integration with Docker Desktop (needs to be installed)
    #   # docker-desktop.enable = true;
    # };

    system.stateVersion = "22.05";
  };
}
