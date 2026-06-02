# Reusable NixOS module: desktop profile — Wayland tiling-WM workstation.
#
# System-level desktop stack: Hyprland + niri sessions, greetd greeter, PipeWire,
# NetworkManager, graphics (Mesa + 32-bit), portals, fonts, Steam. The user-level
# compositor config (DMS shell, keybinds, theming) lives in the home-manager
# `graphical-*` modules.
#
# DEPENDENCY: enabling niri requires the consumer to import niri-flake's NixOS
# module (e.g. inputs.niri.nixosModules.niri) so `programs.niri` exists.
# Unfree is allowed here (nvidia/steam/codecs).
_: {
  flake.nixosModules.desktop =
    { lib, pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      # Wayland compositors — both selectable at the greeter.
      programs.hyprland.enable = true;
      programs.niri.enable = true;

      # Force Electron/Chromium apps onto native Wayland (Ozone). Without this
      # they default to the bundled X11 path; on a niri session with no Xwayland
      # that crashes outright (Spotify's old CEF SIGTRAPs in display init).
      # Setting it session-wide fixes the whole class at once. Harmless on X11.
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # Greeter — minimal TTY greeter listing installed wayland sessions.
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions";
          user = "greeter";
        };
      };

      # NixOS only links a curated set of share/ subdirs into the system path —
      # NOT share/wayland-sessions. Without this, the Hyprland + niri session
      # .desktop files never appear where tuigreet reads them and the greeter
      # lists nothing. Expose it explicitly.
      environment.pathsToLink = [ "/share/wayland-sessions" ];

      # Audio — PipeWire (replaces PulseAudio).
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # Networking — NetworkManager (DMS and desktop tooling expect it).
      networking.networkmanager.enable = true;

      # Graphics — Mesa + 32-bit for Steam/Proton. GPU driver lives in host hardware.
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      # Steam — Proton gaming. Relies on the 32-bit graphics + allowUnfree above.
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = false;
      };
      programs.gamemode.enable = true;

      # Portals — screen share, file pickers. Hyprland portal added by
      # programs.hyprland (its UseIn=Hyprland keeps it preferred there).
      #
      # niri: ScreenCast goes through xdg-desktop-portal-wlr (niri implements
      # wlr-screencopy-unstable-v1). xdp-gnome covers Settings (color-scheme
      # for the prefers-color-scheme portal interface) and the standard
      # FileChooser / Notification / etc set. The explicit pin in
      # xdg.portal.config.niri forces wlr to win for ScreenCast.
      #
      # Why the UseIn patches: xdp 1.20+ only registers an impl backend on a
      # given desktop when the backend's `.portal` manifest claims that
      # desktop via UseIn. None of the upstream manifests list niri, so
      # without these substitutions xdp loads zero backends in a niri session
      # and ScreenCast / Settings / FileChooser silently vanish from the bus
      # (verified via `gdbus introspect` -- the interfaces aren't even
      # exposed). The pin in config.niri only chooses among candidates; it
      # does not bypass UseIn.
      # Patch the manifests globally via an overlay (rather than overrideAttrs
      # inline in extraPortals): programs.hyprland and other modules also
      # pull xdg-desktop-portal-gtk into extraPortals, which would otherwise
      # collide on systemd user units (two store paths providing the same
      # .service file). The overlay replaces the package everywhere.
      nixpkgs.overlays = [
        (final: prev: {
          xdg-desktop-portal-gtk = prev.xdg-desktop-portal-gtk.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              substituteInPlace $out/share/xdg-desktop-portal/portals/gtk.portal \
                --replace-fail 'UseIn=gnome' 'UseIn=gnome;niri'
            '';
          });
          xdg-desktop-portal-gnome = prev.xdg-desktop-portal-gnome.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              substituteInPlace $out/share/xdg-desktop-portal/portals/gnome.portal \
                --replace-fail 'UseIn=gnome' 'UseIn=gnome;niri'
            '';
          });
          xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              substituteInPlace $out/share/xdg-desktop-portal/portals/wlr.portal \
                --replace-fail 'phosh;Hyprland;' 'phosh;Hyprland;niri;'
            '';
          });
        })
      ];

      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
          pkgs.xdg-desktop-portal-wlr
        ];
        config.niri = {
          default = [ "gnome" "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
      };

      hardware.bluetooth.enable = true;

      services.upower.enable = true;
      services.udisks2.enable = true;

      # zram swap — no disk swap, no hibernation.
      zramSwap.enable = true;

      # GTK app settings backend.
      programs.dconf.enable = true;

      fonts.packages = [
        pkgs.noto-fonts
        pkgs.noto-fonts-color-emoji
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.symbols-only
      ];

      # Pin font rendering — slight hinting + native bytecode hinter is the
      # usual sweet spot for hinted fonts (JetBrainsMono, Noto). autohint only
      # helps unhinted fonts and tends to make hinted ones worse.
      fonts.fontconfig = {
        antialias = true;
        hinting = {
          enable = true;
          style = "slight";
          autohint = false;
        };
      };

      # Compositor-adjacent CLI tools. Terminal + rice live in the HM graphical module.
      environment.systemPackages = [
        pkgs.kitty
        pkgs.wl-clipboard
        pkgs.grim
        pkgs.slurp
        pkgs.brightnessctl
        pkgs.playerctl
        pkgs.libnotify
      ];
    };
}
