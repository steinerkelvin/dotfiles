# User configuration for ryuko (WSL)
# Sets up the kelvin user account and home-manager

{ inputs, ... }:

{
  config = {
    users.users.kelvin = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/p/ZbOkA/Wv4dTYbT/CJ+vndMS7xN/8J8SAnVroK0T"
      ];
    };

    home-manager.extraSpecialArgs = { inherit inputs; };
    home-manager.users.kelvin = {
      imports = [
        ../../users/kelvin/hm/common.nix
        ../../users/kelvin/hm/linux.nix
      ];

      home.stateVersion = "23.05";
    };
  };
}
