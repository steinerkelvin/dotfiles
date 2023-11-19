{ k-shared, config, ... }:

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
        ports.yggdrasil_tcp
      ];
    };

    # DDNS
    age.secrets.dynv6-token-kelvin.file = ../../../secrets/dynv6-token-kelvin.age;
    k.services.k-ddns = {
      enable = true;
      tokenFile = config.age.secrets.dynv6-token-kelvin.path;
      domain = "steinerkelvin-${config.k.host.name}.dynv6.net";
      ipv4 = true;
      ipv6 = true;
    };

    services.yggdrasil = {
      enable = true;
      settings = {
        Listen = [
            "tcp://192.168.100.171:${toString ports.yggdrasil_tcp}"
        ];
        Peers = [
          "tcp://supergay.network:9002"
          "tcp://corn.chowder.land:9002"
          "tls://ygg.jjolly.dev:3443"
          "tls://ygg.mnpnk.com:443"
        ];
      };
    };

    # Bootloader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
    boot.loader.systemd-boot.enable = true;
  };
}
