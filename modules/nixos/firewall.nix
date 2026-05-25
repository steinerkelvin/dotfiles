# Reusable NixOS module: firewall base — trust tailscale, open the mosh UDP
# range. List options merge across modules, so a host adds its own trusted
# interfaces / open ports additively, e.g.
#   networking.firewall.trustedInterfaces = [ "microvm" ];
#   networking.firewall.allowedTCPPorts = [ 2200 ];
_: {
  flake.nixosModules.firewall =
    { lib, ... }:
    {
      networking.firewall = {
        enable = lib.mkDefault true;
        trustedInterfaces = [ "tailscale0" ];
        # mosh's conventional UDP range
        allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
      };
    };
}
