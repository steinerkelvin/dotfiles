{ config, lib, pkgs, ... }:

{
  # Hyprland

  # TODO: status bar
  # TODO: better launcher

  home.packages = [
    # Launcher/menu
    pkgs.wofi

    # # Clipboard
    # pkgs.wl-clipboard

    # # Screenshot
    # pkgs.slurp
    # pkgs.grim

    # Wayland event viewer
    pkgs.wev
  ];

  programs.waybar.enable = true;

  # services.mako.enable = true;
  # services.clipman.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      # Programs
      "$terminal" = "kitty";
      "$filemanager" = "dolphin";
      "$menu" = "wofi --show drun";

      # Monitors
      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor = ",preferred,auto,auto";

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;

        # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration = {
        rounding = 10;

        # Change transparency of focused and unfocused windows
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";

        # https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "compose:rctrl,caps:super";  # caps:hyper
        kb_rules = "";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad.natural_scroll = false;
      };

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures = { };

      # Per-device config
      # https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs
      device = [ ];

      # https://wiki.hyprland.org/Configuring/Binds/
      bind = [
        "ALT, return, exec, $terminal" # fallback terminal
        "$mod, return, exec, $terminal"
        "$mod, Q, killactive,"
        "$mod, E, exit,"
        # "$mod, E, exec, $fileManager"
        "$mod, F, togglefloating,"
        "$mod, D, exec, $menu"
        "$mod, P, pseudo, # dwindle"
        "$mod, E, togglesplit, # dwindle"

        # Move focus
        "bind = $mod, H, movefocus, l"
        "bind = $mod, L, movefocus, r"
        "bind = $mod, K, movefocus, u"
        "bind = $mod, J, movefocus, d"

        # Move window
        "bind = $mod SHIFT, H, movewindow, l"
        "bind = $mod SHIFT, L, movewindow, r"
        "bind = $mod SHIFT, K, movewindow, u"
        "bind = $mod SHIFT, J, movewindow, d"

        # Move active window to a workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Special workspace (scratchpad)
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ];

      bindm = [
        # Move/resize windows, with mainMod + LMB/RMB and dragging
        "bindm = $mod, mouse:272, movewindow"
        "bindm = $mod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
      ];
    };
  };
}
