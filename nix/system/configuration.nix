{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # <home-manager/nixos>
      ../modules
    ];

  modules.radeon.enable = true;

  modules.services.syncthing.enable = true;
  # modules.services.n8n.enable = true;

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader = {
    # boot.loader.systemd-boot.enable = true;
    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
    timeout = 7;
  };

  networking.hostName = "nixia"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  services.resolved = {
    enable = true;
    domains = [ "m.steinerkelvin.dev" ];
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  # services.keyd.enable = true;
  # services.keyd.config.default = ''
  #   [ids]
  #   *
  #   [main]
  #   # capslock = layer(custom_caps)
  #   capslock = overload(custom_caps, esc)
  #   [custom_caps:M]
  # '';

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.xserver = {
    enable = true;

    displayManager = {
      sddm.enable = true;
      defaultSession = "none+i3";
      sessionCommands = ''
        ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      '';
    };

    desktopManager.plasma5.enable = true;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        rofi
        i3status
        i3blocks
        i3lock
      ];
    };

    layout = "us";
    xkbVariant = "";
    xkbOptions = "compose:rctrl";
  };

  programs.xwayland.enable = true;
  programs.sway.enable = true;

  xdg.portal.extraPortals = with pkgs; [
    gnome3.gnome-keyring
    xdg-desktop-portal-wlr
  ];

  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kelvin = {
    isNormalUser = true;
    description = "Kelvin";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      kate
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    tree
    i3
  ];

  programs.mtr.enable = true;

  # GnuPG
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
  };
  security.pam.services.login.gnupg.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  # Enable the Mosh
  programs.mosh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    57621  # spotifyd
  ];
  networking.firewall.allowedUDPPorts = [
    5353  # spotifyd
    57621 # spotifyd
  ];

  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # SSH agent
  programs.ssh.startAgent = true;

  # Gnome Keyring

  services.gnome.gnome-keyring.enable = true;

  # services.dbus = {
  #   packages = with pkgs; [
  #     gnome3.gnome-keyring
  #     gcr
  #   ];
  # };

  # xdg.portal.extraPortals = [ pkgs.gnome3.gnome-keyring ];

  # security.wrappers.gnome-keyring-daemon = {
  #   source = "${pkgs.gnome3.gnome-keyring}/bin/gnome-keyring-daemon";
  #   capabilities = "cap_ipc_lock=ep";
  # };

  # security.pam.services.login.enableGnomeKeyring = true;
  # security.pam.services.kelvin.enableGnomeKeyring = true;
  # security.pam.services.kelvin.enableKwallet = true;
}
