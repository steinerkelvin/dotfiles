{ inputs, pkgs, ... }:

let
  username = "kelvin";
in {

  config = {
    # TODO: extract
    users.users."${username}" = {
      isNormalUser = true;
      description = "Kelvin";
      extraGroups = [ "wheel" "networkmanager" "audio" "podman" ];
      # shell = pkgs.zsh;
      packages = [ pkgs.git pkgs.helix ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlD7buD+WXmzv0HW6Ns/LKPbHfqh7Va8JIxNzTY1zsV kelvin@nixia"
      ];
    };

    home-manager.extraSpecialArgs = { inherit inputs; };
    home-manager.users."${username}" = { pkgs, config, lib, ... }: {
      imports = [
        ../../hm/common.nix
        ../../hm/linux.nix
      ];

      home.stateVersion = "22.11";
    };
  };

}
