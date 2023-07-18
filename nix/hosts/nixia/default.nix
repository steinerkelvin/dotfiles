{ config, ... }:

{
  imports = [
    ../common.nix
    ../default-bootloader.nix
    ./hardware-configuration.nix
  ];

  config = {
    k.host.name = "nixia";
    k.host.kind = "pc";

    system.stateVersion = "23.05";

    nix.settings.auto-optimise-store = true;
    nix.extraOptions = ''
      secret-key-files = /etc/nix/private-key
    '';

    # Modules
    k.modules.graphical.enable = true;
    k.modules.audio-prod.enable = true;

    # Services
    k.services.syncthing.enable = true;

    # services.xserver.desktopManager.gnome.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    networking.firewall.allowedTCPPorts = [
      80
      443
      8000
      8080
    ];

    # Steam
    programs.steam.enable = true;
    programs.steam.remotePlay.openFirewall = true;
    hardware.steam-hardware.enable = true;

    # Docker
    virtualisation.docker.enable = true;

    # Bootloader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";

    # Hardware
    k.modules.radeon.enable = true;

    ## Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # DDNS
    age.secrets.dynv6-token-kelvin.file = ../../../secrets/dynv6-token-kelvin.age;
    k.services.k-ddns = {
      enable = true;
      tokenFile = config.age.secrets.dynv6-token-kelvin.path;
      domain = "steinerkelvin-${config.k.host.name}.dynv6.net";
      ipv6 = true;
    };

    # TODO: extract
    # services.smokeping = {
    #   enable = true;
    #   targetConfig = ''
    #     probe = FPing
    #     menu = Top
    #     title = Network Latency Grapher
    #     remark = Welcome to the SmokePing website of Kelvin's Network.

    #     + Local
    #     menu = Local
    #     title = Local Network
    #     ++ LocalMachine
    #     menu = Local Machine
    #     title = This host
    #     host = localhost

    #     + DNS
    #     menu = DNS
    #     title = DNS
    #     ++ Cloudflare_DNS_1
    #     host = 1.1.1.1
    #     ++ Cloudflare_DNS_2
    #     host = 1.0.0.1
    #     ++ Google_DNS_1
    #     host = 8.8.8.8
    #     ++ Google_DNS_2
    #     host = 8.4.4.8

    #     + Sites
    #     menu = Sites
    #     title = Sites
    #     ++ Google
    #     host = google.com
    #   '';
    # };

  };
}
