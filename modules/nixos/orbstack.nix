# Reusable NixOS module: OrbStack VM profile — no bootloader, no firewall, DHCP,
# dev tools. For NixOS guests running under OrbStack on macOS.
_: {
  flake.nixosModules.orbstack =
    { pkgs, ... }:
    {
      # OrbStack handles boot — no bootloader config needed
      boot.loader.grub.enable = false;

      # OrbStack handles networking
      networking.useDHCP = true;

      # No firewall needed in local dev VM
      networking.firewall.enable = false;

      # nix-ld for running unpatched binaries
      programs.nix-ld.enable = true;

      environment.systemPackages = [
        pkgs.curl
        pkgs.wget
        pkgs.mosh
        pkgs.bun
        pkgs.uv
        pkgs.python315
        pkgs.nodejs_22
      ];
    };
}
