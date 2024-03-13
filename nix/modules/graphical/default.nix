{ lib, config, pkgs, ... }:

let
  cfg = config.k.modules.graphical;
  # optionals = lib.lists.optionals;
in {

  options.k.modules.graphical = with lib; {
    enable = mkEnableOption "GUI";
    dm = mkOption { # TODO: define only if `cfg.enable`
      description = "Enable Display Manager";
      type = types.bool;
      default = cfg.enable;
    };
  };

  config = lib.mkIf cfg.enable {

    services.printing.enable = true;

    # DDC/CI — controling monitor brightness / contrast etc
    services.ddccontrol.enable = true;

    fonts.packages = [
      pkgs.liberation_ttf
      pkgs.noto-fonts
    ];

    services.xserver = {
      enable = true;

      # Display Manager / SDDM
      displayManager = lib.mkIf cfg.dm {
        sddm.enable = true;
        defaultSession = "none+i3";
        sessionCommands = ''
          ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
        '';
      };

      # # Plasma
      # desktopManager.plasma5.enable = true;

      # i3wm
      windowManager.i3 = {
        enable = true;
        extraPackages = [
          pkgs.dmenu
          pkgs.i3status
          pkgs.i3blocks
          pkgs.i3lock
        ];
      };

      layout = "us";
      xkbVariant = "";
      xkbOptions = "compose:rctrl";
    };

    # Wayland / Sway
    programs.xwayland.enable = true;
    programs.sway.enable = true;

    # XDG Desktop Portal
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      # pkgs.gnome3.gnome-keyring
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };
}
