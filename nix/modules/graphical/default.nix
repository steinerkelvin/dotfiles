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

  };
}
