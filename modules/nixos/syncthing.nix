# Reusable NixOS module: Syncthing file sync (default ports opened).
#
# The owning user + data dir are host-specific; the consumer sets the stock
# options:  services.syncthing.user = "alice"; services.syncthing.dataDir = "...";
_: {
  flake.nixosModules.syncthing = {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
    };
  };
}
