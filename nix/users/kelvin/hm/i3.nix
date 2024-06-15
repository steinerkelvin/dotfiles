{ config, pkgs, ... }:

{
  # i3wm

  home.packages = [
    pkgs.i3
    pkgs.i3status
    pkgs.i3blocks
    pkgs.dmenu
    pkgs.rofi
    pkgs.dunst
    pkgs.maim
    pkgs.feh

    pkgs.picom

    pkgs.autorandr

    pkgs.xdotool
    pkgs.rofimoji
  ];

  xsession.windowManager.i3 =
    let
      mod = "Mod3";
      term = "alacritty";
      cfg = config.xsession.windowManager.i3.config;
    in
    {
    enable = true;
    extraConfig = ''
      # for_window [window_role=".*scratchpad.*"] move scratchpad
      for_window [instance=".*scratchpad.*"] move scratchpad

      # Xmodmap
      exec --no-startup-id ${config.home.homeDirectory}/.nix-profile/bin/xmodmap ${config.home.homeDirectory}/.Xmodmap

      # Autorandr
      exec --no-startup-id autorandr -c

      # Polybar
      # exec --no-startup-id polybar &
      exec_always --no-startup-id ~/.i3/polybar.sh &

      # Show scracthpad on startup
      exec --no-startup-id sh -c "sleep 1; i3-msg 'scratchpad show'"

      # Arrow bindings (buggy)
      # alternative: https://unix.stackexchange.com/questions/166844/mapping-key-bindings
      bindsym --release ${mod}+y  exec --no-startup-id "bash -c \\"sleep 0.25; xdotool key Left\\" "
      bindsym --release ${mod}+u  exec --no-startup-id "bash -c \\"sleep 0.25; xdotool key Down\\" "
      bindsym --release ${mod}+i  exec --no-startup-id "bash -c \\"sleep 0.25; xdotool key Up\\" "
      bindsym --release ${mod}+o  exec --no-startup-id "bash -c \\"sleep 0.25; xdotool key Right\\" "
    '';
    config =
      {
        modifier = "${mod}";
        terminal = "${term}";
        startup = [
          { command = "redshift -l '-20.31:-40.31' -t 5000:2700"; }
          { command = "~/.fehbg"; }
          { command = "alacritty --class 'scratchpad-terminal' -e zsh -c 'ssh-add; $SHELL'"; }
          # { command = "kitty --name 'scratchpad-terminal' --session ~/config/kitty/ssh-add-session.kitty"; }
        ];
        # assigns = {
        #   "scratchpad" = [ { instance="^scratchpad-terminal$"; } ];
        # };
        colors = {
          focused = {
            border = "#cf2952";
            background = "#f82a5d";
            text = "#000000";
            indicator = "#ff91a0";
            childBorder = "#913e53";
          };
        };
        bars = [
          #   {
          #     command = "${pkgs.i3blocks}/bin/i3blocks -c \${HOME}/.i3blocks.conf";
          #   }
        ];
        keybindings = {
          # open terminal
          "${mod}+Return" = "exec ${term}";
          # fallback if `mod` is misconfigured
          "Mod1+Return" = "exec xterm -e bash";

          # commands menu
          "${mod}+d"       = "exec rofi -show run";
          "${mod}+Shift+d" = "exec rofi -show drun";
          "${mod}+x"       = "exec rofi -show window";
          # "${mod}+c"       = "exec rofi -show ssh";
          "${mod}+period"  = "exec rofimoji";
          # fallback commands menu
          "Mod1+d" = "exec ${cfg.menu}";

          # close window
          "${mod}+Shift+q" = "kill";

          # vim-like focus window
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";

          # focus parent
          "${mod}+a" = "focus parent";

          # vim-like move window
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          # split in horizontal orientation
          "${mod}+b" = "split h";
          # split in vertical orientation
          "${mod}+v" = "split v";

          # fullscreen
          "${mod}+f" = "fullscreen toggle";

          # set layout
          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+e" = "layout toggle split";

          # floating mode
          "${mod}+Shift+space" = "floating toggle";

          # resizing
          "${mod}+r" = "mode resize";

          # scratchpad
          "${mod}+Shift+minus" = "move scratchpad";
          "${mod}+minus" = "scratchpad show";

          # worspaces

          "${mod}+space" = "focus mode_toggle";
          "${mod}+1" = "workspace 1";
          "${mod}+2" = "workspace 2";
          "${mod}+3" = "workspace 3";
          "${mod}+4" = "workspace 4";
          "${mod}+5" = "workspace 5";
          "${mod}+6" = "workspace 6";
          "${mod}+7" = "workspace 7";
          "${mod}+8" = "workspace 8";
          "${mod}+9" = "workspace 9";
          "${mod}+0" = "workspace 10";

          "${mod}+Shift+1" = "move container to workspace 1";
          "${mod}+Shift+2" = "move container to workspace 2";
          "${mod}+Shift+3" = "move container to workspace 3";
          "${mod}+Shift+4" = "move container to workspace 4";
          "${mod}+Shift+5" = "move container to workspace 5";
          "${mod}+Shift+6" = "move container to workspace 6";
          "${mod}+Shift+7" = "move container to workspace 7";
          "${mod}+Shift+8" = "move container to workspace 8";
          "${mod}+Shift+9" = "move container to workspace 9";
          "${mod}+Shift+0" = "move container to workspace 10";

          "${mod}+Ctrl+Shift+h" = "move workspace to output left";
          "${mod}+Ctrl+Shift+j" = "move workspace to output down";
          "${mod}+Ctrl+Shift+k" = "move workspace to output up";
          "${mod}+Ctrl+Shift+l" = "move workspace to output right";
          "${mod}+Ctrl+Shift+Left" = "move workspace to output left";
          "${mod}+Ctrl+Shift+Down" = "move workspace to output down";
          "${mod}+Ctrl+Shift+Up" = "move workspace to output up";
          "${mod}+Ctrl+Shift+Right" = "move workspace to output right";

          # i3 management

          "${mod}+Shift+c" = "reload";
          "${mod}+Shift+r" = "restart";
          "${mod}+Shift+e" = ''
            exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"'';

          # screenshot

          "${mod}+p" = "exec maim -s | xclip -sel clip -t image/png";
          "${mod}+Ctrl+p" =
            "exec maim -s > ./screenshots/$(date -Iseconds).png";
          "${mod}+Shift+p" = "exec maim | xclip -sel clip -t image/png";
          "${mod}+Shift+Ctrl+p" =
            "exec maim > ./screenshots/$(date -Iseconds).png";

          # volume control
          "${mod}+F12" =
            "exec pactl set-sink-volume $(pacmd list-sinks | awk '/* index:/{print $3}') +5%";
          "${mod}+F11" =
            "exec pactl set-sink-volume $(pacmd list-sinks | awk '/* index:/{print $3}') -5%";

          # bringhtness control
          "${mod}+F9" = "exec brightness s 10%-";
          "${mod}+F10" = "exec brightness s +10%";

          "${mod}+c" = "exec k-commander";

          # TODO: port rest of custom keybindings
        };
      };
  };

  # Rofi
  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark-hard";
    terminal = "${pkgs.alacritty}/bin/alacritty";
  };
}
