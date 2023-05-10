{ lib, config, pkgs, ... }:

let
  registeredPorts = {
    headscale = 49001;
  };
in
{
  imports = [ ../common.nix ./hardware-configuration.nix ];

  config = {
    k.name = "kazuma";
    k.kind = "bare";

    system.stateVersion = "22.11";

    virtualisation.podman.enable = true;

    modules.graphical.enable = true;

    modules.services.syncthing.enable = true;
    # modules.services.n8n.enable = true;

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ registeredPorts.headscale ];
    };

    services.headscale = {
      enable = true;
      port = registeredPorts.headscale;
      address = "0.0.0.0";
      dns = {
        magicDns = true;
        baseDomain = "hs.steinerkelvin.dev";
        domains = [];
        nameservers =
          [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      };
    };

    # Bootloader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
  };
}
