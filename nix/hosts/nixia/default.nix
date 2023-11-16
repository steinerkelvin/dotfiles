{ config, ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  config = {
    k.host.name = "nixia";
    k.host.tags.pc = true;

    system.stateVersion = "23.05";

    # Nix
    nix.settings.auto-optimise-store = true;
    nix.extraOptions = ''
      secret-key-files = /etc/nix/private-key
    '';

    # Modules
    k.modules.graphical.enable = true;
    # k.modules.audio-prod.enable = true;

    # Services
    k.services.syncthing.enable = true;

    # Desktop Environment
    services.xserver.desktopManager.plasma5.enable = true;

    # Firewall
    networking.firewall.allowedTCPPorts = [
      80
      443
      8000
      8080
    ];

    # # Steam
    # programs.steam.enable = true;
    # programs.steam.remotePlay.openFirewall = true;
    # hardware.steam-hardware.enable = true;

    # ADB
    programs.adb.enable = true;

    # Docker
    virtualisation.docker.enable = true;

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

    # Bootloader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.loader = {
      timeout = 15;
      grub = {
        enable = true;
        default = "saved";
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };
  };
}
