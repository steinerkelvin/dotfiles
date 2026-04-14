let
  c.background = "#282a2e"; # Dark grey
  c.background-alt = "#373b41"; # Charcoal grey
  c.foreground = "#c5c8c6"; # Silver
  c.primary = "#f82a5d"; # Red pink
  c.secondary = "#8abeb7"; # Pale teal
  c.alert = "#a54242"; # Dusty red
  c.disabled = "#707880"; # Slate grey

in
{ pkgs, ... }:

{
  home.file.".i3/polybar.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash

      # Terminate already running bar instances
      killall -q polybar

      # Wait until the processes have been shut down
      while pgrep -x polybar >/dev/null; do sleep 1; done

      # Launch polybar
      polybar bar &
    '';
  };

  services.polybar.enable = true;
  services.polybar.script = "polybar bar &";

  services.polybar.config = {
    "settings" = {
      "screenchange-reload" = true;
      "pseudo-transparency" = true;
    };

    "colors" = {
      background = c.background;
      background-alt = c.background-alt;
      foreground = c.foreground;
      primary = c.primary;
      secondary = c.secondary;
      alert = c.alert;
      disabled = c.disabled;
    };

    "bar/bar" = {
      tray-position = "center";
      width = "100%";
      height = "18pt";
      radius-bottom = 4;
      background = "\${colors.background}";
      foreground = "\${colors.foreground}";
      "line-size" = "3pt";
      "border-bottom-size" = "0pt";
      "border-color" = "#00000000";
      "padding-left" = 0;
      "padding-right" = 1;
      "module-margin" = 1;
      separator = "|";
      "separator-foreground" = "\${colors.disabled}";
      # "font-0" = "Roboto:size=12;2";
      "font-0" = "Inconsolata Nerd Font Propo:size=10;2";
      "modules-left" = "xworkspaces xwindow";
      "modules-right" =
        "filesystem pulseaudio xkeyboard memory cpu wlan eth date";
      "cursor-click" = "pointer";
      "cursor-scroll" = "ns-resize";
      "enable-ipc" = true;
    };

    "module/xworkspaces" = {
      type = "internal/xworkspaces";
      "label-active" = "%name%";
      "label-active-background" = "\${colors.background-alt}";
      "label-active-underline" = "\${colors.primary}";
      "label-active-padding" = 1;
      "label-occupied" = "%name%";
      "label-occupied-padding" = 1;
      "label-urgent" = "%name%";
      "label-urgent-background" = "\${colors.alert}";
      "label-urgent-padding" = 1;
      "label-empty" = "%name%";
      "label-empty-foreground" = "\${colors.disabled}";
      "label-empty-padding" = 1;
    };

    "module/xwindow" = {
      type = "internal/xwindow";
      label = "%title:0:60:...%";
    };

    "module/filesystem" = {
      type = "internal/fs";
      interval = 25;
      "mount-0" = "/";
      "label-mounted" = "%{F${c.primary}}%mountpoint%%{F-} %percentage_used%%";
      "label-unmounted" = "%mountpoint% not mounted";
      "label-unmounted-foreground" = "\${colors.disabled}";
    };

    "module/pulseaudio" = {
      type = "internal/pulseaudio";
      "format-volume-prefix" = "VOL ";
      "format-volume-prefix-foreground" = "\${colors.primary}";
      "format-volume" = "<label-volume>";
      "label-volume" = "%percentage%%";
      "label-muted" = "muted";
      "label-muted-foreground" = "\${colors.disabled}";
    };

    "module/xkeyboard" = {
      type = "internal/xkeyboard";
      "blacklist-0" = "num lock";
      "label-layout" = "%layout%";
      "label-layout-foreground" = "\${colors.primary}";
      "label-indicator-padding" = 2;
      "label-indicator-margin" = 1;
      "label-indicator-foreground" = "\${colors.background}";
      "label-indicator-background" = "\${colors.secondary}";
    };

    "module/memory" = {
      type = "internal/memory";
      interval = 2;
      "format-prefix" = "RAM ";
      "format-prefix-foreground" = "\${colors.primary}";
      label = "%percentage_used:2%%";
    };

    "module/cpu" = {
      type = "internal/cpu";
      interval = 2;
      "format-prefix" = "CPU ";
      "format-prefix-foreground" = "\${colors.primary}";
      label = "%percentage:2%%";
    };

    "network-base" = {
      type = "internal/network";
      interval = 5;
      "format-connected" = "<label-connected>";
      "format-disconnected" = "<label-disconnected>";
      "label-disconnected" =
        "%{F${c.primary}}%ifname%%{F${c.disabled}} disconnected";
    };

    "module/wlan" = {
      "inherit" = "network-base";
      "interface-type" = "wireless";
      "label-connected" = "%{F${c.primary}}%ifname%%{F-} %essid% %local_ip%";
    };

    "module/eth" = {
      "inherit" = "network-base";
      "interface-type" = "wired";
      "label-connected" = "%{F${c.primary}}%ifname%%{F-} %local_ip%";
    };

    "module/date" = {
      type = "internal/date";
      interval = 1;
      # date = "%H:%M";
      "date" = "%Y/%j  W%V %a  %Y-%m-%d %H:%M";
      "date-alt" = "%Y-%m-%d %H:%M:%S";
      label = "%date%";
      "label-foreground" = "\${colors.primary}";
    };

  };

}
