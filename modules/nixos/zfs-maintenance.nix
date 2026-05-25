# Reusable NixOS module: ZFS automatic scrub and trim.
_: {
  flake.nixosModules.zfs-maintenance = {
    services.zfs.autoScrub.enable = true;
    services.zfs.trim.enable = true;
  };
}
