{ lib, config, pkgs, inputs, ... }:

let
  # TODO: move out + check duplicates
  k.ports = {
    mosquitto_1 = 1883;
    mosquitto_2 = 9001;
    home-assistant = 8123;
    headscale = 49001;
    zigbee2mqtt = 49081;
    smokeping = 49181;
  };
in
{
  imports = [
    ../common.nix
    ../default-bootloader.nix
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
      allowedTCPPorts = [
        k.ports.mosquitto_1
        k.ports.mosquitto_2
        k.ports.home-assistant
        k.ports.headscale
        k.ports.zigbee2mqtt
        k.ports.smokeping
      ];
    };

    services.headscale = {
      enable = true;
      port = k.ports.headscale;
      address = "0.0.0.0";
      dns = {
        magicDns = true;
        baseDomain = "hs.steinerkelvin.dev";
        domains = [];
        nameservers =
          [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      };
    };

    environment.systemPackages = with pkgs; [
      arion
      docker-client
      docker-compose
    ];

    virtualisation.docker.enable = true;
    virtualisation.podman.enable = true;
    # virtualisation.podman.dockerSocket.enable = true;
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

    virtualisation.arion = {
      backend = "docker";

      projects = {

        smokeping = {
          settings.services."smokeping".service = { # Smokeping
            image = "lscr.io/linuxserver/smokeping:latest";
            restart = "unless-stopped";
            ports = [
              "${toString k.ports.smokeping}:80"
            ];
          };
        };

        # sticker-bot = {
        #   settings.services."sticker-bot".service = {
        #     image = "telegram-inline-stickers-bot-app";
        #   };
        # };

        homeassistant = {
          settings.services.homeassistant.service = { # Home Assistant
            image = "ghcr.io/home-assistant/home-assistant:stable";
            restart = "unless-stopped";
            privileged = true;
            network_mode = "host";
            environment = {
              TZ = "America/Sao_Paulo";
            };
            volumes = [
              "/data/home-assistant/config:/config"
            ];
          };
          settings.services.mqtt.service = { # MQTT
            image = "eclipse-mosquitto:2.0";
            restart = "unless-stopped";
            volumes = [
              "/data/mosquitto/data:/mosquitto"
            ];
            ports = [
              "${toString k.ports.mosquitto_1}:1883"
              "${toString k.ports.mosquitto_2}:9001"
            ];
            command = [ "mosquitto" "-c" "/mosquitto-no-auth.conf" ];
          };
          settings.services.zigbee2mqtt.service = { # Zigbee2MQTT
            image = "koenkk/zigbee2mqtt";
            restart = "unless-stopped";
            volumes = [
              "/data/zigbee2mqtt/data:/app/data"
              "/run/udev:/run/udev:ro"
            ];
            ports = [
              "${toString k.ports.zigbee2mqtt}:8080"
            ];
            environment = {
              TZ = "America/Sao_Paulo";
            };
            devices = [
              "/dev/ttyUSB0:/dev/ttyUSB0"
            ];
          };
        };

      };
    };

    # Bootloader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
  };
}
