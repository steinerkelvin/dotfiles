# Reusable NixOS module: ZFS root boot — systemd-boot + ZFS by-id devNodes.
# hostId is host-specific and stays in the private host config (ZFS requires a
# unique networking.hostId per machine).
_: {
  flake.nixosModules.zfs-boot = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.devNodes = "/dev/disk/by-id";
  };
}
