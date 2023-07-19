{ k-shared, config, pkgs, ... }:

let
  ports = k-shared.ports;
in
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  config = {
    k.host.name = "kazuma";

    system.stateVersion = "22.11";

    # Modules
    k.modules.graphical.enable = false;

    # Services
    k.services.syncthing.enable = true;

    # Disable temporary addresses
    networking.tempAddresses = "disabled";

    # Docker / Podman
    virtualisation.docker.enable = true;
    virtualisation.podman.enable = true;
    # virtualisation.podman.dockerSocket.enable = true;
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

    # Firewall
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        ports.mosquitto_1
        ports.mosquitto_2
        ports.home-assistant
        ports.headscale
        ports.zigbee2mqtt
        ports.smokeping
      ];
    };

    # DDNS
    age.secrets.dynv6-token-kelvin.file = ../../../secrets/dynv6-token-kelvin.age;
    k.services.k-ddns = {
      enable = true;
      tokenFile = config.age.secrets.dynv6-token-kelvin.path;
      domain = "steinerkelvin-${config.k.host.name}.dynv6.net";
      ipv6 = true;
    };

    services.headscale = {
      enable = true;
      port = ports.headscale;
      address = "0.0.0.0";
      # TODO: refactor deprecated options
      settings.dns_config = {
        magic_dns = true;
        base_domain = "hs.steinerkelvin.dev";
        domains = [];
        nameservers =
          [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      };
    };

    environment.systemPackages = [
      pkgs.arion
      pkgs.docker-client
      pkgs.docker-compose
    ];

    virtualisation.arion = {
      backend = "docker";

      projects = {

        smokeping = {
          settings.services."smokeping".service = { # Smokeping
            image = "lscr.io/linuxserver/smokeping:latest";
            restart = "unless-stopped";
            ports = [
              "${toString ports.smokeping}:80"
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
              "${toString ports.mosquitto_1}:1883"
              "${toString ports.mosquitto_2}:9001"
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
              "${toString ports.zigbee2mqtt}:8080"
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
    boot.loader.systemd-boot.enable = true;
  };
}
