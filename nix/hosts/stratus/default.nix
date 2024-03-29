{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ./arion.nix
  ];

  k.host.name = "stratus";

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

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

}
