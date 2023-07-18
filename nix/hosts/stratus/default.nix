{ config, pkgs, ... }:

let
  # TODO: move out + check duplicates
  k.ports = {
    mosquitto_1 = 1883;
    mosquitto_2 = 9001;
    home-assistant = 8123;
    headscale = 49001;
    zigbee2mqtt = 49081;
    smokeping = 49181;
    alfred = 49281;
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
  ];

  k.host.name = "stratus";
  k.host.kind = "bare";

  system.stateVersion = "22.11";

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

  environment.systemPackages = [
    pkgs.arion
    pkgs.docker-client
    pkgs.docker-compose
  ];

  virtualisation.arion = {
    backend = "docker";

    projects = {

    };

  };

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

}
