{ lib, config, pkgs, ... }:
let
  cfg = config.modules.graphical;
  optionals = lib.lists.optionals;
in {
  options.modules.graphical = { enable = lib.mkEnableOption { }; };

  config = lib.mkIf cfg.enable {

    services.xserver = {
      enable = true;

      displayManager = {
        sddm.enable = true;
        defaultSession = "none+i3";
        sessionCommands = ''
          ${
            lib.getBin pkgs.dbus
          }/bin/dbus-update-activation-environment --systemd --all
        '';
      };

      desktopManager.plasma5.enable = true;

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
