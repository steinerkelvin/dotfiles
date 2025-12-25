# User configuration for nixia
# Sets up the kelvin user account and home-manager

{ inputs, pkgs, ... }:

let
  username = "kelvin";
in
{
  config = {
    users.users."${username}" = {
      isNormalUser = true;
      description = "Kelvin";
      extraGroups = [ "wheel" "networkmanager" "audio" "podman" ];
      packages = [ pkgs.git ];
    };

    services.trezord.enable = true;

    home-manager.extraSpecialArgs = { inherit inputs; };
    home-manager.users."${username}" = { pkgs, config, lib, ... }: {
      imports = [
        ../../users/kelvin/hm/common.nix
        ../../users/kelvin/hm/linux.nix
        ../../users/kelvin/hm/graphical.nix
      ];

      # Keep original stateVersion for nixia
      home.stateVersion = "22.11";

      services.keybase.enable = true;
      services.kbfs.enable = true;
    };
  };
}
