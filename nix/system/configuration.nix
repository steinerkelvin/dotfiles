{ config, pkgs, lib, ... }:

let
  machines = (import ../machines) {};
in
{
  imports =
    [ # Include the results of the hardware scan.
      # <home-manager/nixos>
      ../modules
      ../users
      machines.nixia
    ];

  k.name = "nixia";
  k.kind = "pc";

  modules.graphical.enable = true;
  modules.radeon.enable = true;

  modules.services.syncthing.enable = true;
  # modules.services.n8n.enable = true;

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # services.keyd.enable = true;
  # services.keyd.config.default = ''
  #   [ids]
  #   *
  #   [main]
  #   # capslock = layer(custom_caps)
  #   capslock = overload(custom_caps, esc)
  #   [custom_caps:M]
  # '';

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

  environment.systemPackages = with pkgs; [
    vim
    wget
    tree
  ];

  networking.firewall.enable = false;

  networking.firewall.allowedTCPPorts = [
    57621  # spotifyd
  ];
  networking.firewall.allowedUDPPorts = [
    5353  # spotifyd
    57621 # spotifyd
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
