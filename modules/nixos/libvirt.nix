# Reusable NixOS module: libvirtd — QEMU/KVM virtualisation host.
#
# The consumer adds its user to the "libvirtd" group, e.g.
#   users.users.<name>.extraGroups = [ "libvirtd" ];
_: {
  flake.nixosModules.libvirt =
    { pkgs, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };

      environment.systemPackages = [
        pkgs.virt-manager
        pkgs.virt-viewer
      ];
    };
}
