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

      # Portals — screen share, file pickers. Hyprland portal added by programs.hyprland.
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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
