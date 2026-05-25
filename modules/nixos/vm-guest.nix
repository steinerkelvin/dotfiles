# Reusable NixOS module: profile for libvirt/QEMU VM guests (serial console,
# key-only SSH, nix-ld, passwordless sudo, dev tooling). The host sets
# `system.stateVersion` itself.
_: {
  flake.nixosModules.vm-guest =
    { pkgs, ... }:
    {
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "prohibit-password";
        };
      };

      # Serial console for `virsh console`
      boot.kernelParams = [ "console=ttyS0,115200" ];
      boot.loader.grub.extraConfig = "serial --speed=115200; terminal_input serial; terminal_output serial";

      programs.nix-ld.enable = true;

      security.sudo.wheelNeedsPassword = false;

      environment.systemPackages = [
        pkgs.curl
        pkgs.mosh
        pkgs.bun
        pkgs.uv
        pkgs.python315
      ];

      # mosh's conventional UDP range
      networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
    };
}
