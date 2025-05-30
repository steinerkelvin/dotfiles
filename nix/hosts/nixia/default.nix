{ config, inputs, ... }:
let vscode-server = inputs.vscode-server;
in {
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    # vscode-server.nixosModules.default

    ../../cachix/agicommies.nix
  ];

  config = {
    k.host.name = "nixia";
    k.host.tags.pc = true;

    system.stateVersion = "23.05";

    # Nix
    nix.settings.auto-optimise-store = true;

    # # runs unpatched dynamic binaries
    # programs.nix-ld.enable = true;

    # Modules
    k.modules.graphical.enable = true;
    # k.modules.audio-prod.enable = true;

    # Utility services
    k.services.syncthing.enable = true;

    # Networking services
    # services.mullvad-vpn.enable = true;
    # services.yggdrasil.enable = true;
    services.tailscale.enable = true;

    # Storage devices management
    services.udisks2.enable = true;

    # # Desktop Environment
    # services.desktopManager.plasma6.enable = true;

    # Firewall
    networking.firewall.allowedTCPPorts = [ 80 443 8000 8080 ];

    # # Steam
    # programs.steam.enable = true;
    # programs.steam.remotePlay.openFirewall = true;
    # hardware.steam-hardware.enable = true;

    # Bitcoin
    services.bitcoind.node = {
      enable = true;
      rpc.users.kelvin.passwordHMAC =
        "c880536af7d967bf96b757da514749e6$ddf326ed804b86bb42d2311b633cbe9110521264c0d2f1d421fa3b497665cf1e";
      prune = 1024 * 128; # 128 GB
      # extraConfig = ''
      #   rpcbind=100.83.90.117
      # '';
    };

    # networking.firewall = {
    #   interfaces."tailscale0" = { allowedTCPPorts = [ 8332 ]; };
    # };

    # ADB
    programs.adb.enable = true;

    # Docker
    virtualisation.docker.enable = true;

    # # Hardware
    # k.modules.radeon.enable = true;

    ## Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # DDNS
    #age.secrets.dynv6-token-kelvin.file = ../../../secrets/dynv6-token-kelvin.age;
    #k.services.k-ddns = {
    #  enable = true;
    #  tokenFile = config.age.secrets.dynv6-token-kelvin.path;
    #  domain = "steinerkelvin-${config.k.host.name}.dynv6.net";
    #  ipv4 = true;
    #  ipv6 = true;
    #};

    # # VSCode Server Support
    # services.vscode-server = {
    #   enable = true;
    #   installPath = "$HOME/.vscode-server";
    #   # installPath = "$HOME/.vscode-server-insiders";
    # };

    # KDE Connect
    programs.kdeconnect.enable = true;

    # Nvidia

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia-container-toolkit.enable = true;

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      nvidiaSettings = true;
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to
      # fail. Enable this if you have graphical corruption issues or application
      # crashes after waking up from sleep. This fixes it by saving the entire
      # VRAM memory to /tmp/ instead of just the bare essentials.
      powerManagement.enable = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;
    };

    # Sysreq
    boot.kernel.sysctl."kernel.sysrq" = 502;

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
