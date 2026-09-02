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

      # INVARIANT (HM + NixOS portal-dir mismatch -- nix-community/home-manager#7124):
      # home-manager's xdg.portal module sets NIX_XDG_DESKTOP_PORTAL_DIR to the
      # per-user profile (~/.../share/xdg-desktop-portal/portals) whenever it
      # is enabled by *any* imported HM module (here: dms/niri/nixcord pull it
      # in transitively). xdp scans only that env-var dir, so NixOS-level
      # `xdg.portal.extraPortals` -- which install into the *system* profile --
      # become invisible (`Requested gtk.portal is unrecognized`, gdbus
      # introspect shows no ScreenCast / Settings / FileChooser).
      #
      # Workaround until HM#7124 lands: mirror NixOS extraPortals at the HM
      # layer here. Any portal omitted from this list is lost. The patched
      # packages (UseIn=niri appended via nixpkgs.overlays at the NixOS layer,
      # so xdp 1.20 actually registers backends on niri) flow through because
      # `pkgs.*` here resolves to the same overlaid nixpkgs.
      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
          pkgs.xdg-desktop-portal-wlr
        ];
      };

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
        # X11 bridge — niri is pure Wayland and ships no Xwayland. Spawn
        # xwayland-satellite so X11-only apps have a display; niri 25.05+ then
        # auto-sets DISPLAY for spawned clients. Merges with DMS's own
        # spawn-at-startup (enableSpawn) rather than replacing it.
        spawn-at-startup = [ { command = [ "xwayland-satellite" ]; } ];

        input.keyboard.xkb = {
          layout = "us";
          options = "compose:rctrl,caps:super";
        };

        # Layout tuning for the 5120x1440 G9 ultrawide.
        #
        # Center a narrow focused column so it lands with gutters either side
        # (gives a "two halves" feel without true display split). Two side-by-
        # side columns still tile normally; only single-narrow-column triggers.
        #
        # Preset widths skew small for 5120px-wide -- 0.5 = 2560px is already
        # huge. Defaults to 0.33 (~1707px), Mod+R cycles through.
        layout = {
          center-focused-column = "on-overflow";
          always-center-single-column = true;
          preset-column-widths = [
            { proportion = 0.166; }   # ~853px  -- compact terminal / chat
            { proportion = 0.25; }    # 1280px  -- editor pane
            { proportion = 0.333; }   # ~1707px -- default
            { proportion = 0.5; }     # 2560px  -- "half"
            { proportion = 0.666; }   # ~3413px
          ];
          default-column-width.proportion = 0.333;
        };

        # Per-app window rules. kitty spawns at the 0.25 preset (~1280px on
        # the G9) instead of the global 0.333 default -- terminals don't need
        # editor-pane width, and a smaller default leaves room to tile a
        # browser/editor alongside without a Mod+R cycle every spawn.
        window-rules = [
          {
            matches = [ { app-id = "^kitty$"; } ];
            default-column-width.proportion = 0.25;
          }
        ];

        binds =
          with config.lib.niri.actions;
          {
            "Mod+Return".action = spawn "kitty";
            "Mod+Q".action = close-window;

            "Mod+H".action = focus-column-left;
            "Mod+L".action = focus-column-right;
            # Spillover: walks windows inside the current column, then falls
            # through to the next workspace when at the top/bottom edge.
            # Mod+Page_{Up,Down} below stays as the pure workspace jump.
            "Mod+J".action = focus-window-or-workspace-down;
            "Mod+K".action = focus-window-or-workspace-up;

            "Mod+Shift+H".action = move-column-left;
            "Mod+Shift+L".action = move-column-right;
            "Mod+Shift+J".action = move-window-down-or-to-workspace-down;
            "Mod+Shift+K".action = move-window-up-or-to-workspace-up;

            "Mod+F".action = maximize-column;
            "Mod+Shift+F".action = fullscreen-window;
            # Mod+R cycles preset column widths small -> large -> wrap.
            # Mod+Shift+R cycles backwards so you don't have to wrap around
            # when you just overshot. niri v25.08+ exposes the -back variant
            # natively.
            "Mod+R".action = switch-preset-column-width;
            "Mod+Shift+R".action = switch-preset-column-width-back;
            "Mod+C".action = center-column;
            "Mod+Shift+E".action = quit;

            # Consume/expel windows across columns. A niri column is a vertical
            # stack; these merge a neighbor's window into the current column
            # (consume) or push the current window out into its own column
            # (expel). The direction-aware variants pick which based on layout.
            "Mod+BracketLeft".action = consume-or-expel-window-left;
            "Mod+BracketRight".action = consume-or-expel-window-right;

            # Launcher alt-binding for Hyprland muscle memory. DMS already
            # binds Mod+Space to the same spotlight toggle via its niri module
            # (inputs.dms.homeModules.niri); Mod+D mirrors Hyprland's $mod,D.
            "Mod+D".action = spawn "dms" "ipc" "spotlight" "toggle";

            # Flip DMS light/dark + mirror to xdp Settings so Firefox/Chromium
            # follow via prefers-color-scheme. Script defined in home.packages.
            "Mod+Alt+T".action = spawn "theme-toggle";

            # Hotkey cheatsheet + workspace overview -- niri built-ins.
            # (Hyprland uses `dms ipc hypr toggleBinds/toggleOverview`, which is
            # Hyprland-specific IPC; niri has native equivalents.)
            "Mod+Slash".action = show-hotkey-overlay;
            "Mod+Tab".action = toggle-overview;

            # Screenshots -- niri-flake's DSL doesn't expose the built-in
            # screenshot actions, so spawn grim/slurp like the Hyprland binds.
            "Print".action = spawn "sh" "-c" ''grim -g "$(slurp)" - | wl-copy'';
            "Shift+Print".action = spawn "sh" "-c" ''grim -g "$(slurp)" "$HOME/pictures/$(date -Iseconds).png"'';

            # wl-kbptr — keyboard-driven mouse pointer. Mod+G = tile-grid jump
            # then hjkl split (works on any app); Mod+Shift+G = opencv CV hints
            # (only useful where edge-detection finds targets).
            "Mod+G".action = spawn "wl-kbptr" "-o" "modes=tile,split";
            "Mod+Shift+G".action = spawn "wl-kbptr" "-o" "modes=floating,click";

            # Switch focus between adjacent workspaces.
            "Mod+Page_Down".action = focus-workspace-down;
            "Mod+Page_Up".action = focus-workspace-up;

            # Move the focused column to an adjacent workspace.
            "Mod+Ctrl+J".action = move-column-to-workspace-down;
            "Mod+Ctrl+K".action = move-column-to-workspace-up;
            "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
            "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
          }
          # Workspaces 1-9: focus by index. (niri-flake's DSL doesn't expose
          # move-column-to-workspace with an index argument -- only the
          # relative -down/-up variants, already bound to Mod+Ctrl+J/K above.)
          // builtins.listToAttrs (
            builtins.map
              (i: {
                name = "Mod+${toString i}";
                value.action = focus-workspace i;
              })
              (lib.range 1 9)
          );
      };

      # Hyprland rice — the more-developed path. DMS (spawned via exec-once)
      # provides bar/launcher/notifications; keybinds call `dms ipc` for shell
      # actions and kitty for the terminal.
      wayland.windowManager.hyprland = {
        enable = true;
        # Pinned explicitly: HM 26.05 flipped this default to "lua". We're
        # still getting "hyprlang" only because home.stateVersion is below
        # 26.05, so without this the behavior would change silently whenever
        # stateVersion moves. Migrate deliberately, not as a side effect.
        configType = "hyprlang";
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
        pkgs.wev # xev for Wayland — debug keypress/pointer events
        pkgs.xwayland-satellite # rootless Xwayland for niri (X11-only apps)

        # Pywalfox native companion -- pipes the active wal/matugen palette into
        # Firefox so the browser chrome tracks the DMS theme switch. Install the
        # Firefox extension separately (about:addons -> "Pywalfox"); on first
        # run, `pywalfox install` to register the native messaging manifest and
        # `pywalfox update` after each `wal -i`/matugen apply. The DMS theme
        # toggle above can chain to pywalfox by adding a hook script.
        pkgs.pywalfox-native

        # theme-toggle: flip DMS light/dark via IPC, and mirror the choice
        # into dconf so xdg-desktop-portal Settings (org.freedesktop.appearance
        # color-scheme) reports it to Firefox / Chromium / libadwaita apps.
        # DMS itself does not publish appearance to the portal.
        #
        # We write via `dconf write` rather than `gsettings set` deliberately:
        # NixOS does not expose GSettings schemas globally (nixpkgs#33277), so
        # a bare `gsettings set` from an unwrapped shell errors with
        # "No schemas installed" unless the script is wrapped with
        # XDG_DATA_DIRS pointing at gsettings-desktop-schemas. `dconf write`
        # bypasses the schema lookup -- xdp-gtk reads the same dconf key for
        # its Settings impl, so the portal value updates either way.
        # `programs.dconf.enable = true` lives in modules/nixos/desktop.nix.
        #
        # We re-read `dms ipc theme getMode` after toggling because DMS's IPC
        # `toggle()` return is the *opposite* of the new state (see DMS's
        # Common/Theme.qml:1873).
        (pkgs.writeShellScriptBin "theme-toggle" ''
          set -eu
          dms ipc theme toggle >/dev/null || true
          mode=$(dms ipc theme getMode 2>/dev/null || echo "")
          case "$mode" in
            light) ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'" ;;
            dark)  ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"  ;;
          esac
        '')
      ];
    };
}
