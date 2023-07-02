{ ... }:

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

    # Modules
    k.modules.graphical.enable = true;
    k.modules.audio-prod.enable = true;

    k.services.ddns.enable = true;
    k.services.syncthing.enable = true;

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
    modules.radeon.enable = true;

    ## Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

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
