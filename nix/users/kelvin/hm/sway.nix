{ config, lib, pkgs, ... }:

{
  # Sway

  home.packages = [
    pkgs.sway
    pkgs.wofi
    pkgs.wl-clipboard
    pkgs.slurp
    pkgs.grim
  ];

  programs.waybar.enable = true;

  # services.mako.enable = true;
  # services.clipman.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "kitty";
      startup = [{ command = "firefox"; }];
      keybindings =
        let modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${modifier}+d" = "exec  wofi --show run";
          "${modifier}+Shift+d" = "exec  wofi --show drun";
          ## Screenshot
          "${modifier}+p" = ''exec  grim -g "$(slurp)" - | wl-copy'';
          "${modifier}+Ctrl+p" = ''
            exec  grim -g "$(slurp)" "./screenshots/$(date -Iseconds).png"'';
          "${modifier}+Shift+p" = "exec  grim - | wl-copy";
          "${modifier}+Shift+Ctrl+p" =
            ''exec  grim "./screenshots/$(date -Iseconds).png"'';
        };
    };
    extraConfig = ''
      input * {
        xkb_layout "us"
        xkb_options "compose:rctrl"
      }
    '';
  };

}
