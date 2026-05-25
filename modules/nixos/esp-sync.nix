# Reusable NixOS module: ESP sync — rsync /boot to /boot2 for a redundant ESP.
# Pairs with a two-ESP disk layout (mirrored boot disks). Generic; the mount
# points /boot and /boot2 are conventional.
_: {
  flake.nixosModules.esp-sync =
    { pkgs, ... }:
    {
      systemd.services.esp-sync = {
        description = "Sync ESP /boot to /boot2";
        after = [ "local-fs.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.rsync}/bin/rsync -a --delete /boot/ /boot2/";
        };
      };

      systemd.timers.esp-sync = {
        description = "Sync ESP on boot and weekly";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5min";
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };
}
