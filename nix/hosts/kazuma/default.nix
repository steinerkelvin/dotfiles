{ lib, config, pkgs, inputs, ... }:

let
  # TODO: move out + check duplicates
  registeredPorts = {
    headscale = 49001;
    smokeping = 49181;
  };
in
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    inputs.arion.nixosModules.arion
  ];

  config = {
    k.name = "kazuma";
    k.kind = "bare";

    system.stateVersion = "22.11";

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

    environment.systemPackages = [
      pkgs.arion

      # Do install the docker CLI to talk to podman.
      # Not needed when virtualisation.docker.enable = true;
      pkgs.docker-client
    ];

    # Arion works with Docker, but for NixOS-based containers, you need Podman
    # since NixOS 21.05.
    virtualisation.docker.enable = false;
    virtualisation.podman.enable = true;
    virtualisation.podman.dockerSocket.enable = true;
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

    virtualisation.arion = {
      backend = "podman-socket";
      projects = {
        smokeping = {
          settings.services."smokeping".service = {
            image = "lscr.io/linuxserver/smokeping:latest";
            restart = "unless-stopped";
            ports = [
              "${toString registeredPorts.smokeping}:80"
            ];
          };
        };
        # sticker-bot = {
        #   settings.services."sticker-bot".service = {
        #     image = "telegram-inline-stickers-bot-app";
        #   };
        # };
      };
    };

    # Bootloader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
  };
}
