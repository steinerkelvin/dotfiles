# User configuration for mako-wsl (WSL server)
# Sets up the kelvin user account and home-manager

{ inputs, ... }:

let
  shared = import ../../shared.nix;
in
{
  config = {
    users.users.kelvin = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = shared.keys.kelvinAll;
    };

    home-manager.extraSpecialArgs = { inherit inputs; };
    home-manager.users.kelvin = {
      imports = [
        ../../users/kelvin/hm/common.nix
        ../../users/kelvin/hm/linux.nix
      ];

      home.stateVersion = "25.05";
    };
  };
}
