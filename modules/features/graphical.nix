# Reusable home-manager module: graphical desktop rice for Wayland tiling-WM
# hosts. The DankMaterialShell desktop shell, per-compositor rice (Hyprland +
# niri keybinds), declarative Discord, and graphical apps.
#
# DMS is spawned per-compositor (niri enableSpawn, Hyprland exec-once), not via
# systemd: switching compositors at the greeter leaves a stale wayland env in the
# systemd user manager, so the DMS service connects to the dead socket and
# crashes. Spawning from each compositor inherits the live WAYLAND_DISPLAY.
#
# Pairs with: homeModules.kitty (the $terminal) and homeModules.wl-kbptr (the
# Super+G binds below invoke the wl-kbptr binary) — import those alongside.
# dgop (DMS's monitoring backend) comes from nixosModules.unstable-packages on
# the host.
#
# niri's own HM module is NOT imported here: niri-flake's NixOS module injects it
# via home-manager.sharedModules on every NixOS host, and niri-flake declares
# programs.niri.finalConfig from both paths, so importing it again collides
# ("option already declared"). The only consumers of this module are NixOS hosts
# (the desktop nixosModule + inputs.niri.nixosModules.niri), which supply the niri
# HM module + config.lib.niri.actions used by programs.niri.settings below. A
# standalone home-manager config that wants this rice must import
# inputs.niri.homeModules.niri itself.
{ inputs, ... }:
{
  flake.homeModules.graphical =
    { config, lib, pkgs, ... }:
    {
      imports = [
        inputs.dms.homeModules.dank-material-shell
        inputs.dms.homeModules.niri # DMS<->niri integration (keybinds/spawn)
        inputs.nixcord.homeModules.nixcord # declarative Equibop/Equicord
      ];

      # DankMaterialShell — Quickshell-based shell (bar, launcher, notifications,
      # lock, control center). Defaults pull matugen/cava/khal/wtype from stable.
      programs.dank-material-shell = {
        enable = true;
        systemd.enable = false; # spawned per-compositor instead (see file header)

        # niri: DMS owns niri's shell-action keybinds + autostart (spawn `dms
        # run`). `includes` (which would also inject DMS binds/colors) is off so
        # it doesn't fight enableKeybinds; our compositor binds are below.
        niri = {
          enableKeybinds = true;
          enableSpawn = true;
          includes.enable = false;
        };
      };

      # niri rice — niri ships NO default binds, so without these the session is
      # unusable (only DMS shell toggles exist). Mod = Super (logo key, and caps
      # lock via caps:super, matching Hyprland). niri is columnar, hence the
      # column/window split on the movement binds.
      programs.niri.settings = {
        input.keyboard.xkb = {
          layout = "us";
          options = "compose:rctrl,caps:super";
        };

        # Center a column that doesn't fill the screen. On the 5120x1440
        # ultrawide a 50% column lands centered with gutters either side --
        # gives a "two halves" feel without true display split. Two side-by-
        # side columns still tile normally; only single-narrow-column triggers
        # the centering.
        layout.center-focused-column = "on-overflow";

        binds =
          with config.lib.niri.actions;
          {
            "Mod+Return".action = spawn "kitty";
            "Mod+Q".action = close-window;

            "Mod+H".action = focus-column-left;
            "Mod+L".action = focus-column-right;
            "Mod+J".action = focus-window-down;
            "Mod+K".action = focus-window-up;

            "Mod+Shift+H".action = move-column-left;
            "Mod+Shift+L".action = move-column-right;
            "Mod+Shift+J".action = move-window-down;
            "Mod+Shift+K".action = move-window-up;

            "Mod+F".action = maximize-column;
            "Mod+Shift+F".action = fullscreen-window;
            "Mod+R".action = switch-preset-column-width;
            "Mod+Shift+E".action = quit;

            # Launcher alt-binding for Hyprland muscle memory. DMS already
            # binds Mod+Space to the same spotlight toggle via its niri module
            # (inputs.dms.homeModules.niri); Mod+D mirrors Hyprland's $mod,D.
            "Mod+D".action = spawn "dms" "ipc" "spotlight" "toggle";

            # Hotkey cheatsheet + workspace overview -- niri built-ins.
            # (Hyprland uses `dms ipc hypr toggleBinds/toggleOverview`, which is
            # Hyprland-specific IPC; niri has native equivalents.)
            "Mod+Slash".action = show-hotkey-overlay-title;
            "Mod+Tab".action = toggle-overview;

            # Screenshots -- niri built-ins (no grim/slurp pipeline needed).
            "Print".action = screenshot;
            "Ctrl+Print".action = screenshot-screen;
            "Alt+Print".action = screenshot-window;

            # wl-kbptr — keyboard-driven mouse pointer. Mod+G = tile-grid jump
            # then hjkl split (works on any app); Mod+Shift+G = opencv CV hints
            # (only useful where edge-detection finds targets).
            "Mod+G".action = spawn "wl-kbptr" "-o" "modes=tile,split";
            "Mod+Shift+G".action = spawn "wl-kbptr" "-o" "modes=floating,click";

            # Move the focused column to an adjacent workspace.
            "Mod+Ctrl+J".action = move-column-to-workspace-down;
            "Mod+Ctrl+K".action = move-column-to-workspace-up;
          }
          # Workspaces 1-9: focus by index + move-column-to-workspace by index.
          // builtins.listToAttrs (
            builtins.concatMap
              (i: [
                { name = "Mod+${toString i}"; value.action = focus-workspace i; }
                { name = "Mod+Shift+${toString i}"; value.action = move-column-to-workspace i; }
              ])
              (lib.range 1 9)
          );
      };

      # Hyprland rice — the more-developed path. DMS (spawned via exec-once)
      # provides bar/launcher/notifications; keybinds call `dms ipc` for shell
      # actions and kitty for the terminal.
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          "$mod" = "SUPER";
          "$terminal" = "kitty";
          "$menu" = "dms ipc spotlight toggle";

          exec-once = [ "dms run" ]; # spawn DMS in Hyprland's live wayland env

          # Pull DMS-written snippets into the generated hyprland.conf. Without
          # these `source` lines, DMS' settings panel writes to ~/.config/hypr/dms/
          # but Hyprland never reads them -- the resolution dropdown etc. silently
          # no-op. The dms flake exposes homeModules.niri for niri integration but
          # no equivalent homeModules.hyprland, so this wiring is by hand.
          # DMS-specific monitor rules in outputs.conf override the catch-all
          # below by output-name match (last specific rule wins per output).
          source = [
            "~/.config/hypr/dms/colors.conf"
            "~/.config/hypr/dms/cursor.conf"
            "~/.config/hypr/dms/layout.conf"
            "~/.config/hypr/dms/outputs.conf"
            "~/.config/hypr/dms/windowrules.conf"
          ];

          monitor = [ ", preferred, auto, auto" ];
          env = [
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
          ];

          general = {
            gaps_in = 5;
            gaps_out = 12;
            border_size = 2;
            layout = "dwindle";
          };

          decoration = {
            rounding = 8;
            blur = {
              enabled = true;
              size = 3;
              passes = 1;
            };
          };

          # Snappy/fast animations (durations in deciseconds; default is ~7).
          animations = {
            enabled = true;
            bezier = [ "snappy, 0.05, 0.9, 0.1, 1.05" ];
            animation = [
              "windows, 1, 2, snappy"
              "windowsOut, 1, 2, snappy, popin 80%"
              "border, 1, 3, default"
              "fade, 1, 2, default"
              "workspaces, 1, 2, snappy"
            ];
          };

          input = {
            kb_layout = "us";
            kb_options = "compose:rctrl,caps:super";
            follow_mouse = 1;
            touchpad.natural_scroll = false;
          };

          bind = [
            "$mod, Return, exec, $terminal"
            "ALT, Return, exec, $terminal" # fallback
            "$mod, D, exec, $menu"
            "$mod, Q, killactive,"
            "$mod, F, togglefloating,"
            "$mod, E, togglesplit," # dwindle
            "$mod SHIFT, E, exit,"

            # DMS shell surfaces (dms ipc <target> <function>; needs DMS running).
            "$mod, Space, exec, dms ipc spotlight toggle" # launcher (also $mod, D)
            "$mod, N, exec, dms ipc notifications toggle"
            "$mod, Comma, exec, dms ipc settings toggle"
            "$mod, V, exec, dms ipc clipboard toggle"
            "$mod, P, exec, dms ipc notepad toggle"
            "$mod, X, exec, dms ipc powermenu toggle"
            "$mod ALT, N, exec, dms ipc night toggle"
            "$mod ALT, L, exec, dms ipc lock lock"
            "$mod, Slash, exec, dms ipc hypr toggleBinds" # keybinds cheatsheet
            "$mod, Tab, exec, dms ipc hypr toggleOverview" # workspace overview

            # wl-kbptr — keyboard-driven mouse pointer. Super+G = tile-grid jump
            # then hjkl split (works on any app); Super+Shift+G = opencv CV hints
            # (only useful where edge-detection finds targets).
            "$mod, G, exec, wl-kbptr -o modes=tile,split"
            "$mod SHIFT, G, exec, wl-kbptr -o modes=floating,click"

            # Move focus (hjkl)
            "$mod, H, movefocus, l"
            "$mod, L, movefocus, r"
            "$mod, K, movefocus, u"
            "$mod, J, movefocus, d"

            # Move window (hjkl)
            "$mod SHIFT, H, movewindow, l"
            "$mod SHIFT, L, movewindow, r"
            "$mod SHIFT, K, movewindow, u"
            "$mod SHIFT, J, movewindow, d"

            # Scratchpad
            "$mod, S, togglespecialworkspace, magic"
            "$mod SHIFT, S, movetoworkspace, special:magic"

            # Screenshots (region -> clipboard / file). On Print; $mod+P is notepad.
            '', Print, exec, grim -g "$(slurp)" - | wl-copy''
            ''SHIFT, Print, exec, grim -g "$(slurp)" "$HOME/pictures/$(date -Iseconds).png"''
          ]
          # Workspaces 1-10 (0 = workspace 10): switch + move-to.
          ++ builtins.concatLists (
            builtins.genList
              (
                i:
                let
                  ws = toString (i + 1);
                  key = toString (if i == 9 then 0 else i + 1);
                in
                [
                  "$mod, ${key}, workspace, ${ws}"
                  "$mod SHIFT, ${key}, movetoworkspace, ${ws}"
                ]
              ) 10
          );

          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];

          windowrulev2 = [
            "suppressevent maximize, class:.*"
          ];
        };
      };

      # Discord — Equibop (Vesktop fork) with Equicord, managed by nixcord. Base
      # Discord/Vencord install disabled; Equibop bundles Equicord.
      programs.nixcord = {
        enable = true;
        discord.enable = false;
        equibop.enable = true;
      };

      # Graphical apps. Terminal + screenshot tools live at the system level
      # (nixosModules.desktop); these are the user-facing GUI set.
      home.packages = [
        pkgs.telegram-desktop
        pkgs.spotify
        pkgs.mpv
        pkgs.zathura
        pkgs.imv
        pkgs.pavucontrol
      ];
    };
}
