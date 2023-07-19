{ k-shared, config, pkgs, ... }:

let
  ports = k-shared.ports;
in
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    ./arion.nix
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

    # Bootloader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
    boot.loader.systemd-boot.enable = true;
  };
}
