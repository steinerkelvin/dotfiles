{ lib, config, pkgs, ... }:

let
  cfg = config.modules.graphical;
  optionals = lib.lists.optionals;
in {

  options.modules.graphical = with lib; {
    enable = mkEnableOption "GUI";
    dm = mkOption { # TODO: define only if `cfg.enable`
      description = "Enable Display Manager";
      type = types.bool;
      default = cfg.enable;
    };
  };

  config = lib.mkIf cfg.enable {

    fonts.fonts = [
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk
      pkgs.noto-fonts-emoji
      pkgs.roboto
      pkgs.liberation_ttf
      pkgs.dejavu_fonts
      pkgs.ubuntu_font_family
      pkgs.nerdfonts
    ];

    services.xserver = {
      enable = true;

      displayManager = lib.mkIf cfg.dm {
        sddm.enable = true;
        defaultSession = "none+i3";
        sessionCommands = ''
          ${
            lib.getBin pkgs.dbus
          }/bin/dbus-update-activation-environment --systemd --all
        '';
      };

      desktopManager.plasma5.enable = true;

      windowManager.i3 = {
        enable = true;
        extraPackages = [
          pkgs.dmenu
          pkgs.rofi
          pkgs.i3status
          pkgs.i3blocks
          pkgs.i3lock
        ];
      };

      layout = "us";
      xkbVariant = "";
      xkbOptions = "compose:rctrl";
    };

    programs.xwayland.enable = true;
    programs.sway.enable = true;

    xdg.portal.extraPortals = [
      pkgs.gnome3.gnome-keyring
      pkgs.xdg-desktop-portal-wlr
    ];

    # DDC/CI — controling monitor brightness / contrast etc
    services.ddccontrol.enable = true;
  };
}
